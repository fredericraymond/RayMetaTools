#!/usr/bin/perl -w
# author : maxime déraspe
# email : maxime@deraspe.net
#

use strict; use warnings;

use Bio::SearchIO;
use Bio::Search::Result::BlastResult;
use Bio::SeqIO;
use Bio::Seq;
use Bio::SeqFeature::Generic;


my $usage = "
Usage : Prodigal-SumUp-Blast.pl <blast results> <% ident> <cov Query> <cov Subject> <dbinfo> <Column 1,2,3>

Note : Query in blast has to be prodigal proteins output and Subject mergem db - with the tabular info file given.

Dependency : Bio::Perl for parsing blast output

";

my $blastfile = shift or die $usage;
my $p_id = shift or die $usage;
my $cov_q = shift or die $usage;
my $cov_s = shift or die $usage;
my $dbtsv = shift;
my $columns = shift;


if($p_id<1){
    $p_id*=100;
}
if($cov_q<1){
    $cov_q*=100;
}
if($cov_s<1){
    $cov_s*=100;
}

my $blast = Bio::SearchIO->new (-format => 'blast',
                                -file => $blastfile);


my %proteins;                   # contig-xx_prot -> bits score and gene name
my $query_name;
my $hit_name;                   # nom du hit (se trouve à être la prot. du genome/microbiome si rev.search avec les RGs)
my $ident;                      # identité prot.
my $coverageQ=0;
my $coverageS=0;


while (my $result = $blast->next_result){

    $query_name = $result->query_name();

    # When the query come from prodigal output description is serated by #
    # contig_protnum # start # end # strand # prodigal description 
    my @location = split(/\#/, $result->query_description());

    while (my $hit = $result->next_hit){
        $hit_name = $hit->name();

        while (my $hsp = $hit->next_hsp){

            $ident = sprintf("%.2f", $hsp->percent_identity());
            $coverageQ = ($hsp->length('total')/$hit->length()) * 100;
            $coverageQ = sprintf("%.2f", $coverageQ);
            $coverageS = ($hsp->length('total')/$result->query_length()) * 100;
            $coverageS = sprintf("%.2f", $coverageS);

            if ($hsp->percent_identity >= $p_id && $coverageQ >= $cov_q && $coverageS >= $cov_s){
                if (exists ($proteins{ $query_name })){
                    if ($proteins{ $query_name }{ bits } < $hsp->bits()){

                        $proteins{ $query_name }{ location } = \@location;
                        $proteins{ $query_name }{ bits } = $hsp->bits();
                        $proteins{ $query_name }{ gene } = $hit_name;
                        $proteins{ $query_name }{ identity } = $ident;
                        $proteins{ $query_name }{ coverageQ } = $coverageQ;
                        $proteins{ $query_name }{ coverageS } = $coverageS;
                    }

                }else{

                    $proteins{ $query_name }{ location } = \@location;
                    $proteins{ $query_name }{ bits } = $hsp->bits();
                    $proteins{ $query_name }{ gene } = $hit_name;
                    $proteins{ $query_name }{ identity } = $ident;
                    $proteins{ $query_name }{ coverageQ } = $coverageQ;
                    $proteins{ $query_name }{ coverageS } = $coverageS;
                }
            }
        }
    }
}


## PRINT summary output
foreach my $key (sort(keys %proteins)){
    my @prot_id = split(/\|/, $proteins{$key}{gene});
    my @tmp_name = split /_/, $key;
    my $contig_name = $tmp_name[0];
    my $protnum = $tmp_name[1];
    my @loc = @{$proteins{$key}{ location }};
    if (defined $dbtsv && $dbtsv ne "" && $columns ne ""){
        my $gene = `cat $dbtsv |grep $prot_id[0]| grep -w $prot_id[1] | grep -w $prot_id[2]`;
        chomp($gene);
        my @genetab = split(/\t/, $gene);
        chomp($columns);
        my @c = split(",",$columns);
        my $info = "";
        foreach (@c) {
            $info = "$info\t$genetab[$_]";
        }
        print "$contig_name\t$protnum\t$loc[1]\t$loc[2]\t$loc[3]$info\t$proteins{$key}{identity}\t$proteins{$key}{coverageQ}\t$proteins{$key}{coverageS}\n";
    }else{
        print "$contig_name\t$protnum\t$loc[1]\t$loc[2]\t$loc[3]\t$proteins{$key}{gene}\t$proteins{$key}{identity}\t$proteins{$key}{coverageQ}\t$proteins{$key}{coverageS}\n";
    }
}

