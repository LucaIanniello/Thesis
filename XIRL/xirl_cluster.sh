#!/bin/bash
#SBATCH --job-name=xirl_job
#SBATCH --output=xirl_output.txt
#SBATCH --error=xirl_error.txt
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1 
#SBATCH --partition=cuda

# Load Anaconda module (if necessary)
module load anaconda3

# Create and activate the Conda environment if it doesn't exist
ENV_NAME="xirl_env"
if ! conda env list | grep -q "$ENV_NAME"; then
    conda create -y -n "$ENV_NAME" python=3.8
fi
source activate "$ENV_NAME"

# Upgrade pip and install necessary dependencies
pip install --upgrade pip
pip install ipython matplotlib-inline

# Define paths
XIRL_REPO="$HOME/xirl_conda"
TMP_DIR="/tmp/xirl"
DATASET_DIR="$TMP_DIR/datasets"
PRETRAIN_DIR="$TMP_DIR/pretrain_runs"

# Clone or update the xirl_conda repository in home
if [ -d "$XIRL_REPO" ]; then
    echo "Repository xirl_conda already exists, updating..."
    cd "$XIRL_REPO" && git pull
else
    echo "Cloning xirl_conda repository..."
    git clone https://github.com/LucaIanniello/xirl_conda.git "$XIRL_REPO"
    cd "$XIRL_REPO"
fi

# Install project dependencies
pip install -r requirements.txt

# Clone the dataset repository in /tmp/xirl/datasets
mkdir -p "$DATASET_DIR"
if [ -d "$DATASET_DIR/.git" ]; then
    echo "Dataset repository already exists, updating..."
    cd "$DATASET_DIR" && git pull
else
    echo "Cloning dataset repository..."
    git clone https://github.com/LucaIanniello/xirl_dataset.git "$DATASET_DIR"
fi

# Ensure the pretrain directory exists
mkdir -p "$PRETRAIN_DIR"

# Run Pretraining
cd "$XIRL_REPO"
python pretrain_xmagical_same_embodiment.py --algo goal_classifier --embodiment gripper --unique_name 0

# Find the latest created directory inside /tmp/xirl/pretrain_runs/
LATEST_PRETRAIN_PATH=$(ls -dt "$PRETRAIN_DIR"/*/ | head -n 1)

# Ensure we found a valid directory
if [ -z "$LATEST_PRETRAIN_PATH" ]; then
    echo "Error: No pretraining directory found in $PRETRAIN_DIR"
    exit 1
fi

echo "Using pretrained path: $LATEST_PRETRAIN_PATH"

# Run RL training with the correct pretrained path
python rl_xmagical_learned_reward.py --pretrained_path "$LATEST_PRETRAIN_PATH" --seeds 1

# Define the RL output directory
RL_RUNS_DIR="/tmp/xirl/rl_runs"
ZIP_FILE="$HOME/rl_runs.zip"

# Check if rl_runs exists before zipping
if [ -d "$RL_RUNS_DIR" ]; then
    echo "Zipping rl_runs directory..."
    zip -r "$ZIP_FILE" "$RL_RUNS_DIR"
    echo "Zipped file saved as: $ZIP_FILE"
else
    echo "No rl_runs directory found. Skipping zip."
fi

scp -r lucaianniello@legion.polito.it:/home/lucaianniello/rl_runs.zip ~/Downloads/
