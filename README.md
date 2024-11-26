# homer-uniqmap-nf

Checkout http://homer.ucsd.edu/homer/data/uniqmap/ for pre-built uniqmaps
Human: hg19 hg38
Mouse: mm9 mm10
Fly: dm3 dm6

## Running this pipeline

```sh
nextflow run Functional-Genomics-Lab/homer-uniqmap-nf -profile utd_ganymede --fasta https://raw.githubusercontent.com/nf-core/test-datasets/nascent/reference/GRCh38_chr21.fa
```
