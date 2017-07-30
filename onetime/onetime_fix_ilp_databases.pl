#!/usr/bin/perl


use warnings;
use strict;
use English;


my $baseDir = "/usr/java/";
$ENV{'SOURCE'} = 'base-ilp';
$ENV{'DBHOST'} = 'prodcluster';

sub replaceDatabase($$) {
    my $DIR = shift;
    my $type = shift;

    my $configFile = $baseDir . $DIR . "/conf/Catalina/localhost/ilp.xml";
    open(FILE, $configFile) or die "Cannot open $configFile: $!";
    while (<FILE>) {
        my $line = $_;
        if ($line =~ /jdbc:mysql:\/\/localhost/) {
            chomp($line);
            print "line=$line\n";
            my $start = index($line, "<value>") + length("<value>jdbc:mysql://localhost/");
            my $end = index($line, "</value>");
            my $db = substr($line, $start, $end - $start);
            $db =~ s/^(.+)_staging$/$1/;
            print "start=$start, end=$end, db=$db\n";
            $ENV{'DATABASE'}=$db;
            $ENV{'instanceType'}=$type;
            $ENV{'path'}=$DIR;
            my @output = `/home/naehas/bin/set_database_info`;
            print @output;
            last;
        }
    }
    close(FILE);
}

sub main() {
    my $DIR = "";
    open(PRODS, "/home/naehas/conf/prods.cfg") or die "Cannot open prods.cfg: $!";
    while(<PRODS>) {
        $DIR = $_;
        chomp($DIR);
        print "Processing Prod Dir, $DIR\n";
        replaceDatabase($DIR, "PROD");
    }
    close(PRODS);

    $baseDir = "/usr/java/staging/";

    open(STAGINGS, "/home/naehas/conf/stagings.cfg") or die "Cannot open stagings.cfg: $!";
    while(<STAGINGS>) {
        $DIR = $_;
        chomp($DIR);
        print "Processing Staging Dir, $DIR\n";
        replaceDatabase($DIR, "STAGING");
    }
    close(STAGINGS);
}

main;
