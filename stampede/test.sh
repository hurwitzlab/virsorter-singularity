#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J vslichen
#SBATCH --mail-type BEGIN,END,FAIL
#SBATCH --mail-user kyclark@email.arizona.edu

module load tacc-singularity

set -u

DATA="/work/05066/imicrobe/iplantc.org/data/virsorter/virsorter-data"
LICHEN_DIR="$WORK/data/lichen"
WORK_DIR="$LICHEN_DIR/virsorter"
INPUT="$LICHEN_DIR/Peltigera_aphthosa_scaffolds.fasta"

[[ -d "$WORK_DIR" ]] && rm -rf "$WORK_DIR"

singularity exec virsorter.img wrapper_phage_contigs_sorter_iPlant.pl --data-dir=$DATA -w=$WORK_DIR -f=$INPUT
