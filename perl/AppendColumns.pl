#!/usr/bin/perl

use strict;
use warnings;

my %buffer;

open (CURRENTFILE, shift) || die ("Could not open file <br> $!");
while (<CURRENTFILE>){ 
    chomp $_;
    my @current = split(/\t/, $_);
    my $input = $_;
#    $input =~ s/\t/;/g; 
#    $input =~ s/\s/_/g;
    $buffer{$current[0]}=$input;
}
close(CURRENTFILE);

open (CURRENTFILE, shift) || die ("Could not FILELIST file <br> $!");
while (<CURRENTFILE>){
          chomp $_;
          print $_;
          my @current = split(/\t/, $_);
          if(exists($buffer{$current[0]})){
                       print "\t$buffer{$current[0]}\n";
           } else {
                       print "\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\n";
           }
}

