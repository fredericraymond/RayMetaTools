#!/usr/bin/perl

use strict;
use warnings;

#open (FILELIST, shift) || die ("Could not FILELIST file <br> $!");
my @filelist = <>;
#close (FILELIST);

my %taxon;
my $file;
my $TaxonName;

my $column = 1; ### no de la colonne - 1

foreach $file (@filelist){
     open (CURRENTFILE, $file) || die ("Could not open $file <br> $!");
     while (<CURRENTFILE>){
          my @current = split(/\t/, $_);
#         if($current[0] =! /^@/){
               $taxon{$current[0]}="True";
#          }
     }
     close(CURRENTFILE);
}

my @TaxonList = keys %taxon;

#foreach my $tax (@TaxonList){
#	print "$tax\n";
#}


foreach $file (@filelist){
     my %TaxonCurrent;
     open (CURRENTFILE, $file) || die ("Could not FILELIST file <br> $!");
     while (<CURRENTFILE>){
          chomp $_;
          $_ =~ s/\t$//;
          my @current = split(/\t/, $_);
#          if($current[0] =! /^@/){
	       if(exists($TaxonCurrent{$current[0]})){
		       if ($current[$column]>$TaxonCurrent{$current[0]}){
		               $TaxonCurrent{$current[0]}=$current[$column];
			}
		} else {
			$TaxonCurrent{$current[0]}=$current[$column];
		}
#          }
     }
     close (CURRENTFILE);
     foreach $TaxonName (@TaxonList){
          if (exists $TaxonCurrent{$TaxonName}) {
               if ($taxon{$TaxonName} eq "True"){
                    $taxon{$TaxonName}=$TaxonCurrent{$TaxonName};
               } else {
                     $taxon{$TaxonName}=$taxon{$TaxonName} . "\t" . $TaxonCurrent{$TaxonName};
               }
          } else {
               if ($taxon{$TaxonName} eq "True"){
                    $taxon{$TaxonName}="0";
               } else {
                     $taxon{$TaxonName}=$taxon{$TaxonName} . "\t 0";
               }
          }
     }
}

print "Sample\t";
foreach $file (@filelist){
        chomp $file;
        print "$file\t";
}
print "\n";

foreach $TaxonName (@TaxonList){
     print "$TaxonName\t$taxon{$TaxonName}\n";
}

