#!binbash
#SBATCH --job-name=xirl_job
#SBATCH --output=xirl_output.txt
#SBATCH --error=xirl_error.txt
#SBATCH --time=020000
#SBATCH --mem=16G
#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu1  # Se usi GPU, altrimenti rimuovi questa riga

# Carica il modulo Conda (se necessario)
module load anaconda3

# Crea e attiva l'ambiente Conda se non esiste già
ENV_NAME=xirl_env
if ! conda env list  grep -q $ENV_NAME; then
    conda create -y -n $ENV_NAME python=3.8
fi
source activate $ENV_NAME

# Installa le dipendenze solo se non sono già presenti
pip install --upgrade pip
pip install ipython matplotlib-inline

# Controlla se la cartella del repository esiste
if [ -d $HOMExirl_conda ]; then
    echo Repository xirl_conda già presente, aggiornamento...
    cd $HOMExirl_conda
    git pull
else
    echo Clonazione repository xirl_conda...
    git clone httpsgithub.comLucaIannielloxirl_conda.git $HOMExirl_conda
    cd $HOMExirl_conda
fi

pip install -r requirements.txt

# Prepara la directory temporanea per il dataset
mkdir -p tmpxirldatasets

# Controlla se il dataset è già presente
if [ -d tmpxirldatasetsxirl_dataset ]; then
    echo Dataset già presente, nessuna clonazione necessaria.
else
    echo Clonazione dataset...
    git clone httpsgithub.comLucaIannielloxirl_dataset.git tmpxirldatasets
fi

# Esegui gli script Python
python pretrain_xmagical_same_embodiment.py --algo goal_classifier --embodiment gripper --unique_name 5

python rl_xmagical_learned_reward.py --pretrained_path tmpxirlpretrain_runsdataset=xmagical_mode=same_algo=goal_classifier_embodiment=gripper_uid=8bd1f3dc-a2e8-4c8b-85bc-899b485be4d9 --seeds 1
