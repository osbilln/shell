#!/bin/sh
#
VERSION="5.0.0";
RELEASE="39";

packages="lunaSAMP javaSAMP cklog"
for pkg in $packages
do
  if ( pkginfo -q $pkg ) ; then
    if ( pkgrm $pkg ) ; then
      echo Uninstalled $pkg
    else
      echo Failed to uninstall $pkg
    fi
  fi
done

/bin/rm -f /opt/lunasa/bin/uninstall_lunasdk.sh

echo Uninstallation of the Luna SA Software Development Kit - Release ${VERSION}-${RELEASE} x86 64bit complete.
echo
