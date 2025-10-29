# LongMemEval for PolyChat

## Usage 

### Sanity test
./run_simple_generation.sh --mem --test


### Run with memory
./run_simple_generation.sh --mem



e.g.
./run_simple_evaluation.sh /Users/craigquiter/src/LongMemEval/data/longmemeval_s.json_testlog_top1000000000context_jsonformat_useronlyfalse_20250831-1655_polychat_test_gpt-4o-mini-polychat-mem

LLM-gen readme:

## 🚀 Unified Experiment Script

**New single script approach:**

```bash
./run_polychat_experiment.sh [--model standard|mem|both]
```

### Options:
- `--model standard` - Run only gpt-4o-mini-polychat
- `--model mem` - Run only gpt-4o-mini-polychat-mem  
- `--model both` - Run both models (default)
- `--help` - Show usage information

### Examples:
```bash
# Run both models (default)
./run_polychat_experiment.sh

# Run only standard polychat
./run_polychat_experiment.sh --model standard

# Run only memory-enhanced polychat  
./run_polychat_experiment.sh --model mem
```

## 📝 Legacy Individual Scripts (Optional)

If you prefer step-by-step execution:

```bash
cd src/generation && ./run_polychat_generation.sh
cd ../evaluation && ./run_polychat_evaluation.sh
./run_polychat_scoring.sh
```

## Prerequisites

1. **Environment Setup**
   ```bash
   conda activate longmemeval-lite
   ```

2. **API Key Configuration**
   Create `.env` file in project root:
   ```
   POLYCHAT_API_KEY=your_actual_polychat_api_key
   ```

3. **Data Files**
   Ensure `data/longmemeval_data/longmemeval_oracle.json` exists

## Models Tested

- **gpt-4o-mini-polychat**: Standard polychat model
- **gpt-4o-mini-polychat-mem**: Memory-enhanced with `x-polychat-memory: on` header

## Configuration

- **Retriever Type**: `orig-session` (full-history-session)
- **Context**: Up to 50 sessions with complete conversation history
- **Format**: JSON format for structured conversation data
- **Length**: 200 tokens per response

## Output Files

Each run generates timestamped files:

1. **Generation**: `longmemeval_oracle.json_testlog_*_polychat_fullhistory_TIMESTAMP`
2. **Evaluation**: `*.eval-results-gpt-4o-mini-polychat*`  
3. **Metrics**: `qa_metrics_TIMESTAMP_polychat*.json`

## Usage Examples

### Quick Test
```bash
# Run everything at once
./run_polychat_pipeline.sh
```

### Step by Step  
```bash
# Generate responses
cd src/generation && ./run_polychat_generation.sh

# Evaluate responses  
cd ../evaluation && ./run_polychat_evaluation.sh

# Calculate metrics
./run_polychat_scoring.sh
```

## Results Comparison

The scoring script automatically compares standard vs memory-enhanced performance and shows improvement metrics.

## Troubleshooting

- **401/403 Errors**: Check POLYCHAT_API_KEY in .env file
- **File Not Found**: Ensure you're in the LongMemEval project root
- **Permission Denied**: Run `chmod +x *.sh` to make scripts executable
