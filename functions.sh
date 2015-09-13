#!/bin/sh
# Functions for general usage.
#
# A. Cin


# Sed in-place: edits the file in question.
sedi() {
  sed -i.sed "$1" "$2"
  RET=$?
  if [ $RET = 0 ] ; then
    /bin/rm -f "$2.sed"
  fi
  return $RET
}
# 
# Mac OS X sed problems:
#   Char classes: can't use \w, use [_a-zA-Z0-9] instead
#   Repetition:   mac wants .+, unix wants .\+, use ..* instead
#   Arguments: -i requires an argument on mac, optional on unix
#

debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "`date +%Y/%m/%d_%H:%M:%S` | $1";
    fi
}

die() {
  if [[ "$1" = "" ]] ; then
    echo "Exiting program due to error."
  else
    echo $1
  fi
  exit 1
}
