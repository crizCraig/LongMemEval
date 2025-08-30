#!/bin/bash

# Polychat Unified Experiment Script
# Runs complete generation, evaluation, and scoring pipeline for polychat models
# Uses full-history-session to provide complete conversation context

set -e  # Exit on any error

# Default configuration
MODEL_TYPE="both"  # Options: standard, mem, both
TIMESTAMP=$(date +"%Y%m%d-%H%M")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"
INPUT_FILE="$DATA_DIR/longmemeval_data/longmemeval_s.json"
REF_FILE="$DATA_DIR/longmemeval_data/longmemeval_s.json"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            MODEL_TYPE="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--model standard|mem|both] [--help]"
            echo ""
            echo "Options:"
            echo "  --model standard  Run only gpt-4o-mini-polychat"
            echo "  --model mem       Run only gpt-4o-mini-polychat-mem"
            echo "  --model both      Run both models (default)"
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Run both models"
            echo "  $0 --model standard  # Run only standard model"
            echo "  $0 --model mem       # Run only memory-enhanced model"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Validate model type
if [[ "$MODEL_TYPE" != "standard" && "$MODEL_TYPE" != "mem" && "$MODEL_TYPE" != "both" ]]; then
    echo "❌ Error: Invalid model type '$MODEL_TYPE'"
    echo "   Valid options: standard, mem, both"
    exit 1
fi

echo "🚀 Polychat Experiment Pipeline"
echo "==============================="
echo "Timestamp: $TIMESTAMP"
echo "Model(s): $MODEL_TYPE"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "❌ Error: .env file not found in project root"
    echo "   Please create .env file with POLYCHAT_API_KEY=your_key"
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Oracle data file not found: $INPUT_FILE"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

# Function to run generation for a specific model
run_generation() {
    local model_alias=$1
    local model_name=$2
    local suffix=$3
    
    echo "🚀 Generating responses with $model_alias..."
    
    cd "$SCRIPT_DIR/src/generation"
    python3 run_generation.py \
        --in_file "$INPUT_FILE" \
        --out_dir "$DATA_DIR" \
        --model_name "$model_name" \
        --model_alias "$model_alias" \
        --openai_base_url "https://polychat.co/api" \
        --openai_key "loaded_from_env" \
        --retriever_type "orig-session" \
        --topk_context 50 \
        --history_format "json" \
        --useronly "false" \
        --cot "false" \
        --out_file_suffix "$suffix" \
        --gen_length 200
    
    echo "✅ Generation completed for $model_alias"
}

# Function to find the most recent generation file for a model type
find_latest_file() {
    local pattern=$1
    local latest_file=$(ls -t "$DATA_DIR"/*${pattern}* 2>/dev/null | head -1)
    echo "$latest_file"
}

# Function to evaluate a hypothesis file
run_evaluation() {
    local hyp_file=$1
    local model_alias=$2
    
    if [ ! -f "$hyp_file" ]; then
        echo "❌ Error: Hypothesis file not found: $hyp_file"
        return 1
    fi
    
    echo "🔍 Evaluating $(basename "$hyp_file")..."
    
    cd "$SCRIPT_DIR/src/evaluation"
    python3 evaluate_qa.py "$model_alias" "$hyp_file" "$REF_FILE"
    
    echo "✅ Evaluation completed for $model_alias"
}

# Function to find the most recent evaluation file for a model type
find_latest_eval_file() {
    local pattern=$1
    local latest_file=$(ls -t "$DATA_DIR"/*${pattern}*.eval-results* 2>/dev/null | head -1)
    echo "$latest_file"
}

# Function to calculate metrics for an evaluation file
run_scoring() {
    local eval_file=$1
    local model_name=$2
    
    if [ ! -f "$eval_file" ]; then
        echo "❌ Error: Evaluation file not found: $eval_file"
        return 1
    fi
    
    echo "📊 Calculating metrics for $(basename "$eval_file")..."
    
    cd "$SCRIPT_DIR/src/evaluation"
    python3 print_qa_metrics.py "$eval_file" "$REF_FILE"
    
    echo "✅ Metrics calculated for $model_name"
}

# Function to process a single model
process_model() {
    local model_type=$1
    local model_alias=""
    local model_name="GPT-4o-mini"
    local suffix=""
    local file_pattern=""
    
    if [ "$model_type" == "standard" ]; then
        model_alias="gpt-4o-mini-polychat"
        suffix="_polychat_fullhistory_${TIMESTAMP}"
        file_pattern="polychat_fullhistory"
    elif [ "$model_type" == "mem" ]; then
        model_alias="gpt-4o-mini-polychat-mem"
        suffix="_polychat_mem_fullhistory_${TIMESTAMP}"
        file_pattern="polychat_mem_fullhistory"
    else
        echo "❌ Error: Invalid model type in process_model: $model_type"
        return 1
    fi
    
    echo ""
    echo "🎯 Processing $model_alias"
    echo "=========================="
    
    # Step 1: Generation
    echo "📝 Step 1: Generation"
    run_generation "$model_alias" "$model_name" "$suffix"
    echo ""
    
    # Step 2: Evaluation
    echo "🔍 Step 2: Evaluation"
    local hyp_file=$(find_latest_file "$file_pattern")
    if [ -n "$hyp_file" ] && [ -f "$hyp_file" ]; then
        run_evaluation "$hyp_file" "$model_alias"
    else
        echo "❌ Error: Could not find generation file for $model_alias"
        return 1
    fi
    echo ""
    
    # Step 3: Scoring
    echo "📊 Step 3: Scoring"
    local eval_file=$(find_latest_eval_file "$file_pattern")
    if [ -n "$eval_file" ] && [ -f "$eval_file" ]; then
        run_scoring "$eval_file" "$model_alias"
    else
        echo "❌ Error: Could not find evaluation file for $model_alias"
        return 1
    fi
}

# Main execution
echo "🎯 Starting polychat experiment..."
echo ""

# Process models based on selection
if [ "$MODEL_TYPE" == "both" ]; then
    process_model "standard"
    process_model "mem"
elif [ "$MODEL_TYPE" == "standard" ]; then
    process_model "standard"
elif [ "$MODEL_TYPE" == "mem" ]; then
    process_model "mem"
fi

echo ""
echo "🎉 Experiment Complete!"
echo "======================="
echo ""
echo "📁 Generated metrics files:"
ls -la "$DATA_DIR" | grep "qa_metrics.*polychat" | grep "$TIMESTAMP" || echo "   No metrics files found"
echo ""

# Show comparison if both models were run
if [ "$MODEL_TYPE" == "both" ]; then
    echo "📊 Performance Summary:"
    STANDARD_METRICS=$(ls -t "$DATA_DIR"/qa_metrics_*polychat.json 2>/dev/null | grep "$TIMESTAMP" | head -1)
    MEM_METRICS=$(ls -t "$DATA_DIR"/qa_metrics_*polychat_mem.json 2>/dev/null | grep "$TIMESTAMP" | head -1)
    
    if [ -f "$STANDARD_METRICS" ] && [ -f "$MEM_METRICS" ]; then
        echo "🟢 Standard Polychat:"
        python3 -c "import json; data=json.load(open('$STANDARD_METRICS')); print(f'   Overall Accuracy: {data[\"overall_accuracy\"]:.1%}')"
        
        echo "🧠 Memory-Enhanced Polychat:"
        python3 -c "import json; data=json.load(open('$MEM_METRICS')); print(f'   Overall Accuracy: {data[\"overall_accuracy\"]:.1%}')"
        
        echo "💡 Memory Enhancement Impact:"
        python3 -c "
import json
std_data = json.load(open('$STANDARD_METRICS'))
mem_data = json.load(open('$MEM_METRICS'))
diff = mem_data['overall_accuracy'] - std_data['overall_accuracy']
print(f'   Improvement: {diff:+.1%}')
"
    fi
fi

echo ""
echo "✨ Experiment completed successfully at $(date)"
