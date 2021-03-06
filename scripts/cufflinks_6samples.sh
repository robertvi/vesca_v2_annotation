#$ -S /bin/bash
#$ -N cufflinks_6samples
#$ -o logs/$JOB_NAME.$JOB_ID.$TASK_ID.out
#$ -e logs/$JOB_NAME.$JOB_ID.$TASK_ID.err
#$ -cwd
#$ -l h_vmem=6G
#$ -l mem_free=6G
#$ -l virtual_free=6G
#$ -l h_rt=999:00:00
#$ -l h=blacklace03.blacklace|blacklace04.blacklace|blacklace05.blacklace
#$ -t 1-6
#$ -tc 6

# wait for corresponding tophat job to complete
#$ -hold_jid_ad tophat_6samples

# assemble RNA seq data using tophat/cufflinks

set -eu
set -o pipefail

export PATH=${PATH}:/home/vicker/programs/bowtie2-2.2.3
export PATH=${PATH}:/home/vicker/programs/samtools-1.1
export PATH=${PATH}:/home/vicker/programs/cufflinks-2.2.1.Linux_x86_64

ref=./refseq/unmasked.fa

#process largest files first
fastq1=$(ls -1S ./tophat_mildew/*/*_R1.fq | head -n ${SGE_TASK_ID} | tail -n 1)
fastq2=$(echo ${fastq1} | sed 's/_R1/_R2/g')
sample=$(echo ${fastq1} | cut -d '/' -f 3)
outdir=tuxedo/${sample}

echo sample is ${sample}, fastqs are ${fastq1} ${fastq2}, outdir is ${outdir}

mkdir -p ${outdir}

/home/vicker/programs/cufflinks-2.2.1.Linux_x86_64/cufflinks\
    --min-isoform-fraction 0.1\
    --pre-mrna-fraction 0.15\
    --min-intron-length 50\
    --max-intron-length 2000\
    --small-anchor-fraction 0.09\
    --min-frags-per-transfrag 10\
    --max-multiread-fraction 0.05\
    --frag-bias-correct ${ref}\
    -o ${outdir}\
    ${outdir}/accepted_hits.bam
