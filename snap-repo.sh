#!/bin/bash

if [[ $# -gt 0 ]]; then
    
    # Define some version and os info so we can later construct the path
    # Defaults can be overridden by cli
    OS="centos"
    MAJORVER="6"
    MINORVER="0"
    ARCH="x86_64"
    
    # Base path to where you are storing the repo. Typically this is an http site.
    BASEPATH="/var/www/html/repo"
    
    # Grabs command line parameters for linking files
    for i in "$@"
    do
        case $i in
            --repo=* | -r=*)
            # Which repo do you want to edit? Usually base, updates, extras, etc
            REPO=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
            ;;
            --source=* | -s=*)
            # What source do you want to use as your snapshot? (trunk, staging, prod)
            SRC=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
            ;;
            # What is the destination? (trunk, staging, prod)
            --destination=* | -d=*)
            DEST=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
            ;;
            # What is the Major OS Version? (4, 5, 6)
            --osreleasever=* | -e=*)
            MAJORVER=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
            ;;
            # What is the Architecture? (i386, x86_64)
            --arch=* | -a=*)
            ARCH=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
            ;;
            # What is the Architecture? (i386, x86_64)
            --os=* | -o=*)
            OS=`echo $i | sed 's/[-a-zA-Z0-9]*=//'`
            ;;
            *)
            # unknown option
            echo "Unknown option! Please specify: $0 --repo=<base,updates,extras> --source=<trunk,stage,prod> --destination=<trunk,stage,prod> [--osreleasever=<5,6> --arch=<i386,x86_64> --os=<centos,rhel>]"
            exit 1
            ;;
        esac
    done
    
    
    # Generates the path where packages and repo files get stored using os, version, and architecture.
    LOCALREPOPATH="$BASEPATH"
    
    echo "Starting snapshot of $REPO-$SRC to $REPO-$DEST for $OS version $MAJORVER $ARCH"
    # Generates the linked repo to create snapshoted branches
    # cleans the current destination repo so we have a clean place
    echo "Cleaning $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH to prep for linking"
    rm -rf $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH/*

    # creates hard links from source repo to destination repo. Saves space as well so you can have a lot of branches
    echo "creating snapshot of $LOCALREPOPATH/$REPO-$SRC/$OS/$MAJORVER/$ARCH/* to $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH/ with hard links"
    cp -alvf $LOCALREPOPATH/$REPO-$SRC/$OS/$MAJORVER/$ARCH/* $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH/

    # removes the repomod stuff so we can ensure that does not get overwritten by another branch
    echo "removing links to repomod stuff"
    rm -rf $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH/repodata/*

    # copies the repomod stuff so we can hold the db for the linked files.
    echo "copying repomod stuff into $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH/"
    cp -avf $LOCALREPOPATH/$REPO-$SRC/$OS/$MAJORVER/$ARCH/repodata $LOCALREPOPATH/$REPO-$DEST/$OS/$MAJORVER/$ARCH/

    echo "snapshot of $REPO-$SRC to $REPO-$DEST for $OS version $MAJORVER $ARCH completed"

else
    echo "Please specify: $0 --repo=<base,updates,extras> --source=<trunk,stage,prod> --destination=<trunk,stage,prod> [--osreleasever=<5,6> --arch=<i386,x86_64> --os=<centos,rhel>]"
fi
