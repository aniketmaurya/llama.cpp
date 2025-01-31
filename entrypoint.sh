#!/bin/sh
set -e  # Exit immediately if any command fails
set -u  # Exit on undefined variables


MODEL_PATH=${MODEL_PATH:-"/app/models/DeepSeek-R1-UD-IQ1_S.gguf"}

# if model_path is not found, download the model
if [ ! -f "$MODEL_PATH" ]; then
    echo "Downloading model..."
    lightning download model "$MODELHUB_PATH" --download_dir="/app/models"
fi

echo "Starting llama-server..."

# fetch devices automatically in the format of CUDA0,CUDA1
devices=$(nvidia-smi -L | grep -oP 'GPU \K[0-9]+' | awk '{printf "CUDA%d,%s", $1, (NR==NF?"":",")}' | tr -d '\n' | sed 's/,$//' || echo "")
echo "Devices: $devices"

exec /app/llama-server --port 8000 --host 0.0.0.0 --flash-attn --no-webui --no-perf --mlock --n-predict -2 -m "$MODEL_PATH" --device "$devices" "$@"
