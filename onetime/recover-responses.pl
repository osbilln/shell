#!/usr/bin/perl

use English;
use strict;
use warnings;

use Getopt::Long;
use File::Basename;

my $PROGRAM_NAME = basename($0);


sub usage() {
    print "usage: $PROGRAM_NAME --responseLog <responseLog> --field <fieldName> [--field <fieldName>]*\n";
    print "       responseLog   Name of the file you wish to parse.\n";
    print "       field         Name of the field you wish to pull from responses.\n";
    print "                     You can enter as many fields as you like.\n";
    print "\n";
    print "example: $PROGRAM_NAME --responseLog response.log --field firstName --field lastName\n";
    exit 1;
}

sub clearHash($) {
    my $hashPtr = shift;
    foreach my $key (keys(%{$hashPtr})) {
        $hashPtr->{$key} = "";
    }
}

sub main() {
    my @fieldNames = ();
    my $responseLog = "";
    
    GetOptions(
        "responseLog=s"     =>  \$responseLog,
        "field=s"           =>  \@fieldNames
    );    
    
    if ($responseLog =~ /^$/) {
        usage();
    }
    if ($#fieldNames < 0) {
        usage();
    }
    
    my %fieldHash;
    foreach my $field (@fieldNames) {
        $fieldHash{$field} = "";
    }
    
    my $outfile = $PROGRAM_NAME . ".out";
    open(FILE, "$responseLog") or die "Cannot open $responseLog: $!";
    open(OUT, ">$outfile") or die "Cannot open outfile, $outfile: $!";
    print OUT "ID";
    foreach my $field (@fieldNames) {
        print OUT "\t$field";
    }
    print OUT "\n";
    
    my $currentResponseId = 0;
    while(<FILE>) {
#        2007-11-12 12:49:39,241 - Unexpected inputs for Response ID=161:
#        lastName: BLOOMHUFF
#        firstName: AMY
        chomp(my $line = $_);
        if ($line =~ /- Unexpected inputs for Response ID=(\d+):$/) {
            my $newId = $1;
            foreach my $field (@fieldNames) {
                if ($fieldHash{$field} !~ /^$/) {
                    # we're checking to see if any of the required fields are present
                    # if any are, then print the entire line out
                    print OUT "$currentResponseId";
                    foreach my $outField (@fieldNames) {
                        print OUT "\t" . $fieldHash{$outField};
                    }
                    print OUT "\n";
                    last;
                }
            }
            clearHash(\%fieldHash);
            $currentResponseId = $newId;
            
        } elsif ($line =~ /^\s+(\w+): (\w+)\s*$/) {
            $fieldHash{$1} = $2;
        }
    }
    close(OUT);
    close(FILE);
    
}

main;
