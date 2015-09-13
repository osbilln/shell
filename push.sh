#!/bin/sh
#
# Pushes changed files to a target server.
#
# Usage:
#
#  ./push.sh [naehas@test2:/usr/java/acin-dashboard/]
#

SKIP="-name .svn -prune -o -name downloads -prune -o "
OTHER_SKIPS=''
if [[ -f lastUpload ]] ; then 
  CHANGED=`find webapps $SKIP -type f -newer lastUpload  \! -name 'n*hib*.xml'  \! -name .DS_Store \! -name \*.swp \! -name \*.original.\* -print`
else
  echo 'From 2 hours ago'
  CHANGED=`find webapps $SKIP -type f -newerct '2 hours ago' \! -name 'n*hib*.xml' \! -name .DS_Store \! -name \*.swp \! -name \*.original.\* -print`
fi
echo $CHANGED
if [[ "x$CHANGED" = "x" ]] ; then
  echo 'No files'
  exit 1
fi

DEST=$1
if [[ $DEST = "" ]] ; then 
  DEST='naehas@test2:/usr/java/acin-dashboard/'
fi

FILES=""
for F in $CHANGED ; do

  /bin/echo -n "Include $F [Y(default)/n]? "
  read USE_IT
  case $USE_IT in
    n|N) ;;
    *) FILES="$FILES $F"
       ;;
  esac
done

if [[ "x$FILES" != "x" ]] ; then 
  echo "Transferring: "
  echo "  $FILES"
  echo
  echo "to $DEST"
  rsync -CauR --progress $FILES $DEST
fi

touch lastUpload
echo "                                   `date`"
