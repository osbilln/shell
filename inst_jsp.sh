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
      exit 1;
    fi
  fi
done

packages="lunajsp lunajmt"
for pkg in $packages
do
  if ( swinstall -v -s `pwd`/$pkg.dep $pkg) ; then
    echo Installed $pkg 
  else
    echo Failed to install $pkg
    exit 1;
  fi
done

cp unin_jsp.sh /opt/lunasa/bin/unin_jsp.sh
chmod +x /opt/lunasa/bin/unin_jsp.sh

echo Installation of the Luna JSP for Luna SA - Release ${VERSION}-${RELEASE} successful.
echo
