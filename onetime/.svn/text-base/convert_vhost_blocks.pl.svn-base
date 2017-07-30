#!/usr/bin/perl

use warnings;
use strict;
use English;

use Getopt::Long;
use File::Basename;

my $gsvProgramName = basename($0);
my $gsvSourceConfFile = "";
my $gsvMapFile = "";
my %ghUrlToInstanceArray = (); 
my $gsvLogDir = "";
my $gsvLogFile = "";
my $VHOST_HOME = "";

sub usage() {
    print "usage: $gsvProgramName --conf <conf> --map <map> --logDir <logDir> [--vhost <VHOST_HOME>]\n";
    print "        conf    Path to source httpd.conf file to parse.\n";
    print "        map     Path to map file for url > [type, path].\n";
    print "        logDir  Path to directory to spit out logs and vhost files.\n";
    print "        vhost    (optional) If present, outputs vhost files to dirs and links them to VHOST_HOME directory.\n";
    exit 1;
}

sub processMap() {
    open(MAP, "$gsvMapFile") or die "Cannot open map, $gsvMapFile : $!";
    while (<MAP>) {
        chomp(my $line = $_);
        my @ary = split(/ /, $line);
        if ($#ary != 2) { #if last index of array is not 2, ie ary.size != 3
            print "ERROR: Line not formatted correctly in map: $line\n";
            exit 1;
        } else {
            my $url = $ary[0];
            my @fields = ($ary[1], $ary[2]);
            if (! $ghUrlToInstanceArray{$url}) {
                $ghUrlToInstanceArray{$url}=\@fields;    
            } else {
                print "ERROR: url already present in array for line=".$line."\n";
                exit 1;
            }    
        }
    }
    close(MAP);
    
    #debugging
#   foreach my $key (keys %ghUrlToInstanceArray) {
#       my $aryPtr = $ghUrlToInstanceArray{$key};
#       my @ary = @$aryPtr;
#       print "key=$key and value[0]=".$ary[0]." value[1]=".$ary[1]."\n";
#   }
}

sub appendStringToFile($$) {
    my $svString = shift;
    my $outputFile = shift;
    
    open(OUTFILE, ">>$outputFile") or die "Cannot open vhost $outputFile : $!";
    print OUTFILE $svString;
    close(OUTFILE);    
}

sub debug($) {
    my $line = shift;
    appendStringToFile("DEBUG: $line", $gsvLogFile);
}

#   type    STAGING|PROD
#   path    ncdm07-ilp
#   block   the virtualhost block string
sub complete($$$) {
    my $svType = shift;
    my $svPath = shift;
    my $svBlock = shift;
    
    my $svPrefix = "/usr/java/staging";
    # we're actually dumping all of these into the /usr/java/staging copy so it commits.
    #if ($svType =~ /^STAGING$/) {
    #    $svPrefix = "/usr/java/staging";
    #}
    
    my $vhostFile = $svType.".".$svPath.".vhost";
    my $vhostFileHome = $svPrefix."/".$svPath;
    my $svHardCopy = $vhostFileHome."/".$vhostFile;
    my $svLink = $VHOST_HOME."/".$vhostFile;
    stat($vhostFileHome);
    if (! -d _) {
        appendStringToFile("WARN: $vhostFileHome does not exist.\n", $gsvLogFile);
        return;
    }
    stat($svHardCopy);
    if (! -e _ && $VHOST_HOME !~ /^$/) {
        appendStringToFile($svBlock, $svHardCopy);
        my $lnStatement = "sudo /bin/ln -s $svHardCopy $svLink";
        appendStringToFile($lnStatement."\n", $gsvLogFile);
        my @output = `$lnStatement`;
        if ($? != 0) {
            appendStringToFile("ERROR in link: $!\n", $gsvLogFile);
            for (my $i = 0; $i <= $#output; $i++) {
                appendStringToFile($output[$i]."\n", $gsvLogFile);
            }
            return;
        }
        
        my $svBaseIlpConfigFile = $vhostFileHome."/"."base-ilp.cfg";
        open(CFG, ">>$svBaseIlpConfigFile") or die "Cannot open config file, $svBaseIlpConfigFile : $!";
        print CFG "export VHOST_HOME=\"/etc/httpd/vhosts/\"\n";
        close(CFG);
    } elsif (! -e _ && $VHOST_HOME =~ /^$/) {
        # debug mode
    } else {
        print "WARN: $svHardCopy already exists. Skipping.";
        return;
    }
    
}

sub processConf() {
    open(CONF, "$gsvSourceConfFile") or die "Cannot open conf, $gsvSourceConfFile : $!";
    my $bvInBlock = 0;
    my $bvValidBlock = 0;
    my $svCurrentBlock = "";
    my $svCurrentType = "";
    my $svCurrentPath = "";
    my $svLineNumber = 0;
    while (<CONF>) {
        $svLineNumber++;
        chomp(my $currentConfLine = $_);
        if (!$bvInBlock && $currentConfLine =~ /^<VirtualHost \*:80>/) {
            #start recording VirtualHost block
            debug "Found start of VirtualHost block, line ".$svLineNumber."\n";
            $svCurrentBlock = $currentConfLine."\n";
            $bvInBlock = 1;
        } elsif ($bvInBlock) {
            $svCurrentBlock = $svCurrentBlock.$currentConfLine."\n";
            
            if ($currentConfLine =~ /^ServerName (.+)$/ && !$bvValidBlock) {
                my $svPossibleUrl = $1;
                debug "Found VirtualHost block with url=$svPossibleUrl at line $svLineNumber\n";
               
                #test to see if url is in map, if so valid block = 1
                my $aryPtr = $ghUrlToInstanceArray{$svPossibleUrl};
                if ($aryPtr) {
	                my @ary = @$aryPtr;
                    if ($ary[0] !~ /^$/ && $ary[1] !~ /^$/) {
                        $bvValidBlock = 1;
                        $svCurrentType = $ary[0];
                        $svCurrentPath = $ary[1];
                    }                    
                }
                #if not, drop out of the block, clear variables
            } elsif ($currentConfLine =~ m|^</VirtualHost>|) {
                #end of block
                debug "Found end of vhost block at line $svLineNumber\n";
                my $outFile = "";
                if ($bvValidBlock) {
	                #print block out as file
	                $outFile = $gsvLogDir."/".$svCurrentType.".".$svCurrentPath.".vhost";
                
                    #print outfile to ilp dir and link back to VHOST_HOME dir
                    complete($svCurrentType, $svCurrentPath, $svCurrentBlock);
	                
                } else {
                    #print block to log file
                    $svCurrentBlock = $svCurrentBlock."\n";
                    $outFile = $gsvLogFile;
                }
                appendStringToFile($svCurrentBlock, $outFile);
                #done with this block, reset
                $bvInBlock = 0;
                $bvValidBlock = 0;
                $svCurrentBlock = "";
                $svCurrentType = "";
                $svCurrentPath = "";
            }
        } 
    }   
    close(CONF);
}

sub main() {    
    my $svTmpConf = "";
    my $svTmpMap = "";
    my $svTmpLog = "";
    my $svVHost = "";
    
    GetOptions(
       "conf=s"         =>  \$svTmpConf,
       "map=s"          =>  \$svTmpMap,
       "logDir=s"       =>  \$svTmpLog,
       "vhost_home=s"   =>  \$svVHost
    );
    
    if ($svTmpConf =~ /^$/ || $svTmpMap =~ /^$/ || $svTmpLog =~ /^$/) {
        usage();
    }
    
    stat($svTmpConf);
    die "Conf file, $svTmpConf, does not exist." unless -e _;
    
    stat($svTmpMap);
    die "Map file, $svTmpMap, does not exist." unless -e _;
    
    stat($svTmpLog);
    die "Log dir, $svTmpLog, not directory." unless -d _;
    
    if ($svVHost !~ /^$/) {
        stat($svVHost);
        die "VHOST_HOME, $svVHost, not directory." unless -d _;
    }
    
    $gsvSourceConfFile = $svTmpConf;
    $gsvMapFile = $svTmpMap;
    $gsvLogDir = $svTmpLog;
    $VHOST_HOME = $svVHost;
    
    print "Running with conf=".$gsvSourceConfFile." map=".$gsvMapFile." logDir=".$gsvLogDir." VHOST_HOME=".$VHOST_HOME."\n";
    $gsvLogFile = $gsvLogDir."/".$gsvProgramName.".log";
    
    #zero out log file
    open (LOG, ">$gsvLogFile") or die "Error opening log file, $gsvLogFile (to zero out): $!";
    print LOG "";
    close(LOG);
    
    processMap();
    
    processConf();

    print "DONE!\n\n";
}

main;