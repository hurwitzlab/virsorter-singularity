#!/bin/bash

#module load tacc-singularity

set -u

FASTA=""
OUT_DIR="$PWD/virsorter-out"
DATASET="VIRSorter"
VIRSORTER_DATA_DIR=""
MIN_GENES_PER_CONTIG=2
BIN=$(cd $(dirname $0) && pwd)
SCRIPT_DIR="$BIN/../scripts"

function USAGE() {
    printf "Usage:\n  %s -f FASTA\n\n" "$(basename "$0")"

    echo "Required arguments:"
    echo " -f FASTA"
    echo " -v VIRSORTER_DATA_DIR"
    echo
    echo "Options:"
    echo " -d DATASET ($DATASET)"
    echo " -g MIN_GENES_PER_CONTIG ($MIN_GENES_PER_CONTIG)"
    echo " -o OUT_DIR ($OUT_DIR)"
    echo
    exit "${1:-0}"
}

[[ $# -eq 0 ]] && USAGE 1

while getopts :d:f:g:o:v:h OPT; do
    case $OPT in
        d)
            DATASET="$OPTARG"
            ;;
        f)
            FASTA="$OPTARG"
            ;;
        g)
            MIN_GENES_PER_CONTIG="$OPTARG"
            ;;
        h)
            USAGE
            ;;
        o)
            OUT_DIR="$OPTARG"
            ;;
        v)
            VIRSORTER_DATA_DIR="$OPTARG"
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument."
            exit 1
            ;;
        \?)
            echo "Error: Invalid option: -${OPTARG:-""}"
            exit 1
    esac
done

#
# Trust, but verify
#
if [[ -z "$FASTA" ]]; then
    echo "-f FASTA is required"
    exit 1
fi

if [[ ! -f "$FASTA" ]]; then
    echo "-f \"$FASTA\" is not a file"
    exit 1
fi

if [[ -z "$VIRSORTER_DATA_DIR" ]]; then
    echo "-v VIRSORTER_DATA_DIR is required"
    exit 1
fi

if [[ ! -d "$VIRSORTER_DATA_DIR" ]]; then
    echo "-v \"$VIRSORTER_DATA_DIR\" is not a directory"
    exit 1
fi

if [[ $MIN_GENES_PER_CONTIG -lt 1 ]]; then
    echo "-g MIN_GENES_PER_CONTIG must be greater than 0"
    exit 1
fi

#
# Confirm options
#
echo "FASTA                \"$FASTA\"" 
echo "OUT_DIR              \"$OUT_DIR\""
echo "VIRSORTER_DATA_DIR   \"$VIRSORTER_DATA_DIR\""
echo "MIN_GENES_PER_CONTIG \"$MIN_GENES_PER_CONTIG\""
echo "DATASET              \"$DATASET\""

if [[ -d "$OUT_DIR" ]]; then
    rm -rf $OUT_DIR/*
else 
    mkdir -p "$OUT_DIR"
fi

#
# Clean input
#
FASTA_DIR="$OUT_DIR/fasta"
[[ ! -d "$FASTA_DIR" ]] && mkdir -p "$FASTA_DIR"

echo "Copying \"$FASTA\" to \"$FASTA_DIR\""
cp "$FASTA" "$FASTA_DIR"
INPUT="$FASTA_DIR/$(basename "$FASTA")"
perl -i -pe '/^>/ && s/[^a-zA-Z0-9_>\n-]/_/g' "$INPUT"
dos2unix "$INPUT"

#
# Call genes
#
echo "Finding circular DNA, calling genes"
$SCRIPT_DIR/find_circular.py -f "$FASTA" -o "$FASTA_DIR" -g "$MIN_GENES_PER_CONTIG" -d "$DATASET"

PRODIGAL_DIR="$OUT_DIR/prodigal"
[[ ! -d "$PRODIGAL_DIR" ]] && mkdir -p "$PRODIGAL_DIR"
prodigal -i "$INPUT" -a "$PRODIGAL_DIR/proteins.fa" -o "$PRODIGAL_DIR/prodigal.out"
