#!/bin/bash

# Simple Generation Script for gpt-4o-mini-polychat
# Runs only the generation step for gpt-4o-mini-polychat model
# Uses full-history-session to provide complete conversation context
#
# Usage: ./run_simple_generation.sh [--test] [--mem]
# Options:
#   --test    Use mini dataset (longmemeval_mini.json) for testing
#   --mem     Use memory-enhanced model (appends '-mem' to model alias)

set -e  # Exit on any error

# Parse command line arguments
USE_TEST_DATA=false
USE_MEM_MODEL=false
for arg in "$@"; do
    case $arg in
        --test)
            USE_TEST_DATA=true
            shift
            ;;
        --mem)
            USE_MEM_MODEL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --test    Use mini dataset (longmemeval_mini.json) instead of full dataset"
            echo "  --mem     Use memory-enhanced model (appends '-mem' to model alias)"
            echo "  --help    Show this help message"
            echo ""
            exit 0
            ;;
        *)
            # Unknown option
            ;;
    esac
done

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

# Set input file based on --test flag
if [ "$USE_TEST_DATA" = true ]; then
    INPUT_FILE="$DATA_DIR/longmemeval_data/longmemeval_mini.json"
    echo "🧪 Test mode enabled - using mini dataset"
else
    INPUT_FILE="$DATA_DIR/longmemeval_data/longmemeval_s.json"
fi

TIMESTAMP=$(date +"%Y%m%d-%H%M")

echo "🚀 Running Simple Generation for gpt-4o-mini-polychat"
echo "===================================================="
echo "Timestamp: $TIMESTAMP"
echo "Input file: $INPUT_FILE"
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

# Set model alias based on --mem flag
MODEL_ALIAS="gpt-4o-mini-polychat"
if [ "$USE_MEM_MODEL" = true ]; then
    MODEL_ALIAS="${MODEL_ALIAS}-mem"
    echo "🧠 Memory-enhanced model enabled - using $MODEL_ALIAS"
fi

# Run generation with full-history-session configuration
echo "🚀 Generating responses with $MODEL_ALIAS (full-history-session)..."

cd "$SCRIPT_DIR/src/generation"
python3 run_generation.py \
    --in_file "$INPUT_FILE" \
    --out_dir "$DATA_DIR" \
    --model_name "GPT-4o-mini" \
    --model_alias "$MODEL_ALIAS" \
    --openai_base_url "http://localhost:8080/api" \
    --openai_key "loaded_from_env" \
    --retriever_type "orig-session" \
    --topk_context 1_000_000_000 \
    --history_format "json" \
    --useronly "false" \
    --cot "true" \
    --out_file_suffix "_polychat_test_${MODEL_ALIAS}" \
    --gen_length 200

echo ""
echo "✅ Generation completed successfully!"
echo ""
echo "📁 Output file should be in: $DATA_DIR"
echo "✨ Generation completed at $(date)"
