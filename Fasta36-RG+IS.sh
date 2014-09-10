#!/bin/bash
#PBS -N Sample_XX
#PBS -A nne-790-ad
#PBS -l walltime=12:00:00
#PBS -l nodes=7:ppn=8
#PBS -q default
#PBS -e Sample_XX-fasta36.stderr
#PBS -o Sample_XX-fasta36.stdout
cd $PBS_O_WORKDIR

#TimeStamp
T="$(date +%s%N)"

source /home/deraspem/Project_CQDM-Production/Tools/Annotation-Pipeline/LoadModules.sh
module load nne-790-ab/fasta/36.3.5e

cd Sample_XX/Assembly/Prodigal/

mkdir blast
lfs setstripe -c 0 -s 4m blast
cd blast/

ln -s /rap/nne-790-ab/projects/Project_CQDM2/Search-Datasets/MERGEM_2013-04-29/All-RG_2013-04-29.tsv .
ln -s /rap/nne-790-ab/projects/Project_CQDM2/Search-Datasets/MERGEM_2013-04-29/All-IS_2013-04-29.tsv .
ln -s /rap/nne-790-ab/projects/Project_CQDM2/Search-Datasets/MERGEM_2013-04-29/RG-prots/All-RG-prot_2013-04-29.pep .
ln -s /rap/nne-790-ab/projects/Project_CQDM2/Search-Datasets/MERGEM_2013-04-29/IS-prots/All-IS-prots.pep .

mpiexec -n 56 fasta36_mpi -q -b 100 -d 100 -E 0.0000000001 -m BB -L ../Proteins.fa All-RG-prot_2013-04-29.pep > MERGEM-RG.blast

mpiexec -n 56 fasta36_mpi -q -b 100 -d 100 -E 0.0000000001 -m BB -L ../Proteins.fa All-IS-prots.pep > MERGEM-IS.blast

Prodigal-SumUp-Blast.pl MERGEM-RG.blast 40 50 50 All-RG_2013-04-29.tsv 5,8,9  > MERGEM-RG.blast.sum.tsv &

Prodigal-SumUp-Blast.pl MERGEM-IS.blast 40 50 50 All-IS_2013-04-29.tsv 1,3 > MERGEM-IS.blast.sum.tsv &

wait

Concat-Mobilome-Resistome.pl MERGEM-RG.blast.sum.tsv MERGEM-IS.blast.sum.tsv ResistomeMobilome-Sum.tsv


cd ../../../

# Time interval in nanoseconds
T="$(($(date +%s%N)-T))"
# Seconds
S="$((T/1000000000))"
# Milliseconds
M="$((T%1000000000/1000000))"

echo "Time in nanoseconds: ${T}"
printf "Time Elapse: %02d:%02d:%02d:%02d.%03d\n" "$((S/86400))" "$((S/3600%24))" "$((S/60%60))" "$((S%60))" "${M}" > time-Sample_XX-fasta36.log

