#!/bin/bash

# Simple Evaluation Script
# Runs evaluation on generated results file
# Automatically determines reference file based on results filename
#
# Usage: ./run_simple_evaluation.sh <results_file_path> [--model MODEL_ALIAS]
# Options:
#   --model   Evaluation model alias (default: gpt-4o-mini)

set -e  # Exit on any error

# Parse command line arguments
RESULTS_FILE=""
EVAL_MODEL="gpt-4o-mini"

while [[ $# -gt 0 ]]; do
    case $1 in
        --model)
            EVAL_MODEL="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 <results_file_path> [OPTIONS]"
            echo ""
            echo "Arguments:"
            echo "  <results_file_path>  Path to the generated results file to evaluate"
            echo ""
            echo "Options:"
            echo "  --model MODEL_ALIAS  Evaluation model alias (default: gpt-4o-mini)"
            echo "  --help               Show this help message"
            echo ""
            echo "Example:"
            echo "  $0 /path/to/results_file.json --model gpt-4o-mini"
            echo ""
            exit 0
            ;;
        -*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            if [ -z "$RESULTS_FILE" ]; then
                RESULTS_FILE="$1"
            else
                echo "Error: Multiple result files specified. Only one file is allowed."
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if results file was provided
if [ -z "$RESULTS_FILE" ]; then
    echo "❌ Error: Results file path is required"
    echo "Usage: $0 <results_file_path> [--model MODEL_ALIAS]"
    exit 1
fi

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

echo "🔍 Running Simple Evaluation"
echo "============================="
echo "Results file: $RESULTS_FILE"
echo "Evaluation model: $EVAL_MODEL"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "❌ Error: .env file not found in project root"
    echo "   Please create .env file with required API keys"
    exit 1
fi

if [ ! -f "$RESULTS_FILE" ]; then
    echo "❌ Error: Results file not found: $RESULTS_FILE"
    exit 1
fi

# Determine reference file based on results filename
if [[ "$RESULTS_FILE" == *"longmemeval_mini"* ]]; then
    REF_FILE="$DATA_DIR/longmemeval_data/longmemeval_mini.json"
    echo "🧪 Detected mini dataset - using mini reference file"
elif [[ "$RESULTS_FILE" == *"longmemeval_s"* ]]; then
    REF_FILE="$DATA_DIR/longmemeval_data/longmemeval_s.json"
    echo "📊 Detected full dataset - using full reference file"
else
    echo "❌ Error: Cannot determine dataset type from filename"
    echo "   Filename should contain 'longmemeval_mini' or 'longmemeval_s'"
    exit 1
fi

if [ ! -f "$REF_FILE" ]; then
    echo "❌ Error: Reference file not found: $REF_FILE"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo "Reference file: $REF_FILE"
echo ""

# Run evaluation
echo "🚀 Running evaluation with $EVAL_MODEL..."

cd "$SCRIPT_DIR/src/evaluation"
python3 evaluate_qa.py \
    "$EVAL_MODEL" \
    "$RESULTS_FILE" \
    "$REF_FILE"

echo ""
echo "✅ Evaluation completed successfully!"
echo ""
echo "📁 Results file should be: ${RESULTS_FILE}.eval-results-${EVAL_MODEL}"
echo "✨ Evaluation completed at $(date)"
