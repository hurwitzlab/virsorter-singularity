#!/bin/bash

set -u

FASTA=""
OUT_DIR="$PWD/virsorter-out"
DATASET="VIRSorter"
MIN_GENES_PER_CONTIG=2

function USAGE() {
    printf "Usage:\n  %s -f FASTA\n\n" "$(basename "$0")"

    echo "Required arguments:"
    echo " -f FASTA"
    echo
    echo "Options:"
    echo " -d DATASET ($DATASET)"
    echo " -g MIN_GENES_PER_CONTIG ($MIN_GENES_PER_CONTIG)"
    echo " -o OUT_DIR ($OUT_DIR)"
    echo
    exit "${1:-0}"
}

[[ $# -eq 0 ]] && USAGE 1

while getopts :d:f:g:o:h OPT; do
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
        :)
            echo "Error: Option -$OPTARG requires an argument."
            exit 1
            ;;
        \?)
            echo "Error: Invalid option: -${OPTARG:-""}"
            exit 1
    esac
done

echo "FASTA \"$FASTA\" OUT_DIR \"$OUT_DIR\""

[[ ! -d "$OUT_DIR" ]] && mkdir -p "$OUT_DIR"

#
# Clean input IDs
#
perl -i -pe '/^>/ && s/[^a-zA-Z0-9_>\n-]/_/g' "$FASTA"
#dos2unix "$FASTA" # add this
