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
      exit1;
    fi
  fi
done

for pkg in $packages
do
  if ( swinstall -v -s `pwd`/$pkg.dep $pkg) ; then
    echo Installed $pkg successfully
  else
    echo Error installing $pkg
    exit 1;
  fi
done

cp unin_sdk.sh /opt/lunasa/bin/unin_sdk.sh
chmod +x /opt/lunasa/bin/unin_sdk.sh

echo Installation of the Luna SA Software Development Kit - Release ${VERSION}-${RELEASE} successful.
echo
