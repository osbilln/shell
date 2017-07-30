#!/bin/sh
#
VERSION="5.0.0";
RELEASE="39";

packages="lunajsp lunajmt"
for pkg in $packages
do
  if ( swlist $pkg 2>/dev/null 1>/dev/null ) ; then
    if ( swremove -v $pkg ) ; then
      echo Uninstalled $pkg
    else
      echo Failed to uninstall $pkg
    fi
  fi
done

/bin/rm -f /opt/lunasa/bin/unin_jsp.sh

echo Uninstallation of the Luna JSP for Luna SA - Release ${VERSION}-${RELEASE} complete.
echo
