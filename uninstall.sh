VERSION="5.0.0";
RELEASE="39";


if [ -f /etc/Chrystoki.conf ] ; then
  cp /etc/Chrystoki.conf /etc/Chrystoki.conf.dssave
  echo "The Chrystoki.conf has been saved as /etc/Chrystoki.conf.dssave"
fi

packages="ssh salogin lunacmu libshim lunaMT ckdemo lunavtl lunalib lunaconf"
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

/bin/rm -f /opt/lunasa/bin/uninstall.sh

if (pkginfo -q lunaJSP64x86 ) ; then
  echo "Would you like to uninstall the Luna JSP for Luna SA? (y/n) "
  read YES_JSP
  if [ $YES_JSP = 'y' ]  || [ $YES_JSP = "yes" ]; then
    sh uninstall_lunaJSP.sh
  else
    echo "If you wish to uninstall the Luna JSP for Luna SA at a later time, simply run uninstall_lunaJSP.sh in the javasp directory."
    echo
  fi
fi

if (pkginfo -q cklog) ; then
  echo "Would you like to uninstall the SDK for Luna SA? (y/n) "
  read YES_SDK
  if [ $YES_SDK = 'y' ]  || [ $YES_SDK = "yes" ]; then
    sh uninstall_lunasdk.sh
  else
    echo "If you wish to uninstall the SDK for Luna SA at a later time, simply run uninstall_lunasdk.sh in the SDK directory."
    echo
  fi
fi

echo Uninstallation of the Luna SA Client Software - Release ${VERSION}-${RELEASE} x86 64bit complete.
echo
