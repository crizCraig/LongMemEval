import sys
import json
import numpy as np
import re
import os


if len(sys.argv) != 3:
    print('Usage: python print_qa_metrics.py in_file ref_file')
    exit()

in_file = sys.argv[1]
ref_file = sys.argv[2]
in_data = [json.loads(line) for line in open(in_file).readlines()]
ref_data = json.load(open(ref_file))
ref_data = {x['question_id']: x for x in ref_data}

# Extract timestamp from filename
filename = os.path.basename(in_file)
timestamp_match = re.search(r'(\d{8}-\d{4})', filename)
timestamp = timestamp_match.group(1) if timestamp_match else 'unknown'

all_acc, task_acc, abstention_acc = [], [], []
type2acc = {t: [] for t in ['single-session-user', 'single-session-preference', 'single-session-assistant', 'multi-session', 'temporal-reasoning', 'knowledge-update']}
for entry in in_data:
    ref_entry = ref_data[entry['question_id']]
    # Removed hardcoded model assertion - accept any model
    type2acc[ref_entry['question_type']].append(1 if entry['autoeval_label']['label'] else 0)
    if '_abs' in entry['question_id']:
        abstention_acc.append(1 if entry['autoeval_label']['label'] else 0)

# Calculate metrics
metrics = {}
metrics['evaluation_results_by_task'] = {}
for k, v in type2acc.items():
    accuracy = round(np.mean(v), 4)
    count = len(v)
    metrics['evaluation_results_by_task'][k] = {'accuracy': accuracy, 'count': count}

# Print to console and build task_acc
print('\nEvaluation results by task:')
for k, v in type2acc.items():
    accuracy = metrics['evaluation_results_by_task'][k]['accuracy']
    count = metrics['evaluation_results_by_task'][k]['count']
    print('\t{}: {} ({})'.format(k, accuracy, count))
    all_acc += v
    task_acc.append(np.mean(v))

# Calculate summary metrics after building task_acc
metrics['task_averaged_accuracy'] = round(np.mean(task_acc), 4)
metrics['overall_accuracy'] = round(np.mean([1 if entry['autoeval_label']['label'] else 0 for entry in in_data]), 4)
metrics['abstention_accuracy'] = round(np.mean(abstention_acc), 4) if abstention_acc else 0.0
metrics['abstention_count'] = len(abstention_acc)
metrics['total_questions'] = len(in_data)
metrics['timestamp'] = timestamp
metrics['input_file'] = filename
metrics['model_used'] = in_data[0]['autoeval_label']['model'] if in_data else 'unknown'

print('\nTask-averaged Accuracy:', metrics['task_averaged_accuracy'])
print('Overall Accuracy:', metrics['overall_accuracy'])
print('Abstention Accuracy:', metrics['abstention_accuracy'], f'({metrics["abstention_count"]})')

# Save metrics to file with timestamp and model info
model_suffix = ""
if "polychat_mem" in filename:
    model_suffix = "_polychat_mem"
elif "polychat" in filename:
    model_suffix = "_polychat"

metrics_filename = f'qa_metrics_{timestamp}{model_suffix}.json'
metrics_path = os.path.join(os.path.dirname(in_file), metrics_filename)

with open(metrics_path, 'w') as f:
    json.dump(metrics, f, indent=2)

print(f'\nMetrics saved to: {metrics_path}')
