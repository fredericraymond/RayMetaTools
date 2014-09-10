#!/bin/bash

##
## Summarizes sequencing, assembly and annotation results for CQDM project
## By Frederic Raymond 2013-06-03
## Use :
## SequencingStatistics.sh directory
##
## Can be used within a for loop
## Example : 
## for i in $(ls|grep SilverRay|grep -v SAMPLE|grep -v std); do SequencingStatistics.sh $i;done
##
## Uses the Assembly directory created by SilverRay
## Does not include header
## Header should be :
## Assembly	Nucleotides_sequenced	Number_of_Contigs	Total_length_Assembly	Average_Contig_length	N50	Median_contig	Largest_contig	NB_Genes	NB_RG	NB_IS	NB_Contigs_withRG-IS
##

i=$1

echo -n $i
grep "Summary" $i/NumberOfSequences.txt -A 3|tail -n 1|sed 's/ //g'|awk -F ":" '{printf "\t" $2 "\t"}'
grep "Contigs >= 500" -A 6 $i/OutputNumbers.txt |tail -n 6|sed 's/ //g'|awk -F ":" '{printf $2 "\t"}'
grep ">" $i/Prodigal/Genes.fa |wc -l|awk -F ":" '{printf $1 "\t"}'
wc -l $i/Prodigal/blast/MERGEM-RG.blast.sum.tsv|awk '{printf $1 "\t"}'
wc -l $i/Prodigal/blast/MERGEM-IS.blast.sum.tsv|awk '{printf $1 "\t"}'
grep IS $i/Prodigal/blast/ResistomeMobilome-Sum.tsv |wc -l|awk '{printf $1 "\t"}'
##wc -l $i/Assembly/Prodigal/blast/MERGEM-RG.blast40pIdentity.sum.tsv|awk '{printf $1 "\t"}'
##wc -l $i/Assembly/Prodigal/blast/MERGEM-IS.blast.40pIdentity.sum.tsv|awk '{printf $1 "\t"}'
#grep IS $i/Assembly/Prodigal/blast/ResistomeMobilome-Sum-40pIdentity.tsv |wc -l|awk '{printf $1 "\t"}'

echo;
#perl ~/perl/MakeGroupsForIS-RG_v3.pl $i/Assembly/Prodigal/blast/MERGEM-RG.blast.sum.tsv $i/Assembly/Prodigal/blast/MERGEM-IS.blast.sum.tsv|wc -l|awk '{printf $1 "\n"}'
