#!/bin/sh
#

VERSION="5.0.0";
RELEASE="39";


packages="lunaJSP64x86 lunajmt"
for pkg in $packages
do
  if ( pkginfo -q $pkg ) ; then
    if ( pkgrm $pkg ) ; then
      echo Uninstalled $pkg
    else
      echo Failed to uninstall $pkg
      exit 1;
    fi
  fi
done

packages="lunaJSP64x86 lunajmt"
for pkg in $packages
do
  if ( pkgadd -d $pkg.ds $pkg ) ; then
    echo Installed $pkg
  else
    echo Failed to install $pkg
    exit 1;
  fi
done

cp uninstall_lunaJSP.sh /opt/lunasa/bin/uninstall_lunaJSP.sh
chmod +x /opt/lunasa/bin/uninstall_lunaJSP.sh

echo Installation of the Luna JSP for Luna SA - Release ${VERSION}-${RELEASE} x86 64bit successful.
echo
