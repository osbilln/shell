#!/bin/sh
#
VERSION="5.0.0";
RELEASE="39";

packages="lunacmu libshim ssh salogin lunamt ckdemo lunavtl lunalib lunaconf"
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

/bin/rm -f /opt/lunasa/bin/uninst.sh

if (swlist lunajsp 2>/dev/null 1>/dev/null ) ; then
  echo "Would you like to uninstall the Luna JSP for Luna SA? (y/n) "
  read YES_JSP
  if [ $YES_JSP = 'y' ]  || [ $YES_JSP = "yes" ]; then
    sh unin_jsp.sh
  else
    echo "If you wish to uninstall the Luna JSP for Luna SA at a later time, simply run unin_jsp.sh in the javasp directory."
    echo
  fi
fi

if (swlist cklog 2>/dev/null 1>/dev/null ) ; then
  echo "Would you like to uninstall the SDK for Luna SA? (y/n) "
  read YES_SDK
  if [ $YES_SDK = 'y' ]  || [ $YES_SDK = "yes" ]; then
    sh unin_sdk.sh
  else
    echo "If you wish to uninstall the SDK for Luna SA at a later time, simply run unin_sdk.sh in the SDK directory."
    echo
  fi
fi

echo Uninstallation of the Luna SA Client Software - Release ${VERSION}-${RELEASE} complete.
echo
