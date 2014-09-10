#!/bin/bash
#PBS -N Prodigal-All
#PBS -A nne-790-ad
#PBS -l walltime=6:00:00
#PBS -l nodes=1:ppn=8
#PBS -q default
#PBS -e Prodigal-All.stderr
#PBS -o Prodigal-All.stdout
cd $PBS_O_WORKDIR

source /rap/nne-790-ab/projects/Project_CQDM2/Tools/Annotation-Pipeline/LoadModules.sh
module load nne-790-ab/fasta/36.3.5e
module load nne-790-ab/prodigal/2.6
module load apps/ruby/1.9.3-p385


#TimeStamp
T="$(date +%s%N)"

curDir=$(pwd)

function waitProc(){
    procName=$1
    procNum=$2

    numT=$(ps -C $procName | tail -n +2 | wc -l)
    echo "$procName : $numT -ge $procNum" >> $curDir/Prodigal-All.log
    while [ $numT -ge $procNum ]
    do
        echo "Inside loop : $procName : $numT -ge $procNum" >> $curDir/Prodigal-All.log
        sleep 25
        numT=$(ps -C $procName | tail -n +2 | wc -l)
    done
}

dirList=$(for i in $(find . -name Contigs.fasta); do dirname $i; done | uniq)

for i in $(echo $dirList)
do
    cd $i
    Extract-Contigs-Length.rb ">500" Contigs.fasta &
    cd $curDir
    waitProc "ruby" 8
done

waitProc "ruby" 1

for i in $(echo $dirList)
do
    cd $i
    if [ -d Prodigal ]
    then
        rm -rf Prodigal
    fi
    mkdir Prodigal
    cd Prodigal/
    prodigal -q -p meta -i ../Contigs-gt-500.fasta -a Proteins.fa -d Genes.fa -f gff -o Contigs.gff &
    cd $curDir
    waitProc "prodigal" 8
done

waitProc "prodigal" 1

for i in $(echo $dirList)
do
    cd $i/Prodigal/
    if [ -d single-gff ]
    then
        rm -rf single-gff
    fi
    mkdir single-gff
    lfs setstripe -s 1m -c 1 single-gff
    cd single-gff
    split-gff.rb ../Contigs.gff &
    cd $curDir
done

wait


# Time interval in nanoseconds
T="$(($(date +%s%N)-T))"
# Seconds
S="$((T/1000000000))"
# Milliseconds
M="$((T%1000000000/1000000))"

echo "Time in nanoseconds: ${T}"
printf "Time Elapse: %02d:%02d:%02d:%02d.%03d\n" "$((S/86400))" "$((S/3600%24))" "$((S/60%60))" "$((S%60))" "${M}" > time-Prodigal-All.log
