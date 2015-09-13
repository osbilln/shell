#!/bin/sh
#
VERSION="5.0.0";
RELEASE="39";

packages="cklog javaSAMP lunasamp"
for pkg in $packages
do
  if ( swlist $pkg 2>/dev/null 1>/dev/null ) ; then
    if ( swremove -v $pkg ) ; then
      echo Removed $pkg
    else
      echo Failed to remove $pkg
    fi
  fi
done

/bin/rm -f /opt/lunasa/bin/uninst_lunasdk.sh

echo Uninstallation of the Luna SA Software Development Kit - Release ${VERSION}-${RELEASE} complete.
echo
