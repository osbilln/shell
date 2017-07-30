#!/bin/sh
#

configurator=/usr/lunasa/bin/configurator

check_configurator()
{
  if [ ! -f ${configurator} ]; then
    echo "ERROR: Unable to find the configurator."
    echo "       Please make sure the client is installed prior to installing"
    echo "       this package."
  fi
}

f_default()
{ 
  echo "Setting default settings"
  $configurator setValue -q -s Misc -e Apache -v 1 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e LibPath -v /usr/lib/libCryptoki2.so > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e EngineInit -v 1:10:11 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e FORK_CHECK -v 0 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e DisableRsa -v 0 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e DisableDsa -v 1 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e DisableRand -v 1 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e NO_FORK_FINALIZE -v 0 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e NO_NORM_FINALIZE -v 0 > /dev/null 
  $configurator setValue -q -s EngineLunaCA3 -e EnableSessionMutex -v 1 > /dev/null 
} 
 
if [ "$1" = "optimize" ]; then
  echo "optimize has been deprecated" 
elif [ "$1" = "remove" ]; then 
  echo "remove has been deprecated" 
elif [ "$1" = "default" ]; then 
  check_configurator 
  f_default 
else 
  echo "OptimizeApache.sh default    <-- write default settings to file Chrystoki.conf" 
  exit 1
fi




