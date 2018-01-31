#!/usr/bin/env python3
"""docstring"""

import argparse
import os
import re
import sys
from Bio import SeqIO

# --------------------------------------------------
def get_args():
    """get args"""
    parser = argparse.ArgumentParser(description='Argparse Python script')
    parser.add_argument('-f', '--fasta', help='Input FASTA file',
                        metavar='FASTA', type=str, required=True)
    parser.add_argument('-o', '--outdir', help='Output directory',
                        metavar='DIR', type=str, default='')
    parser.add_argument('-d', '--dataset', help='Dataset name',
                        metavar='STR', type=str, default='VIRSorter')
    parser.add_argument('-g', '--numgenes', help='Min. num genes per contig',
                        metavar='INT', type=int, default=2)
    return parser.parse_args()

# --------------------------------------------------
def main():
    """main"""
    args = get_args()
    fasta = args.fasta
    outdir = args.outdir
    dataset = args.dataset

    if not os.path.isfile(fasta):
        print('"{}" is not a file'.format(fasta))
        sys.exit(1)

    if not outdir:
        outdir = os.path.dirname(fasta)

    if not os.path.isdir(outdir):
        os.makedirs(outdir)

    basename, ext = os.path.splitext(os.path.basename(fasta))
    outfile = os.path.join(outdir, basename + '.circ' + ext)
    out_fh = open(outfile, 'w')
    num_found = 0

    for i, record in enumerate(SeqIO.parse(fasta, "fasta")):
        seq = str(record.seq)
        prefix = seq[:10]
        regex = re.compile('(.+)(' + prefix + '.*?)$')
        match = regex.search(seq)
        if match:
            sequence, suffix = match.groups()
            if suffix == seq[:len(suffix)]:
                num_found += 1
                print('{}/{}\n'.format(num_found, i + 1))

                # copy the first 1000 bases to the end to ensure
                # we don't lose an ORF across the boundary
                #record.seq(seq + seq[:1000])
                #SeqIO.write(record, out_fh, "fasta")
                out_fh.write('\n'.join(['>' + record.id, seq + seq[:1000]]))

    print('Done, found {} circular sequence{}.\n'.format(
        num_found, '' if num_found == 1 else 's'))

# --------------------------------------------------
if __name__ == '__main__':
    main()
