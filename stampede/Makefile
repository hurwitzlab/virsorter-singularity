.PHONY = lichen lichen_clean mmetsp

SINGULARITY = /usr/local/bin/singularity
IMG = virsorter.img
VIRSORTER = $(SINGULARITY) run $(IMG)
VIRSORTER_DATA_DIR = ~/work/virsorter-data
DATA = /work/05066/imicrobe/iplantc.org/data/virsorter/virsorter-data

lichen: lichen_clean
	$(VIRSORTER) --data-dir $(DATA) -w $(WORK)/data/lichen/virsorter -f $(WORK)/data/lichen/Peltigera_aphthosa_scaffolds.fasta 

mmetsp:
	./wrapper_phage_contigs_sorter_iPlant.pl -w ~/work/mmetsp/ -f ~/work/mmetsp/MMETSP0105.nt.fa --data-dir=~/work/virsorter-data/

lichen_clean:
	find $(WORK)/data/lichen -type d -name virsorter -exec rm -rf {} \;

test:
	sbatch test.sh

local_clean:
	rm -rf ~/work/lichen/virsorter2

local:
	./run.sh -f ~/work/lichen/Peltigera_aphthosa_scaffolds_small.fasta -o ~/work/lichen/virsorter2 -v $(VIRSORTER_DATA_DIR)
