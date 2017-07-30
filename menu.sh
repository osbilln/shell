#!/bin/bash

echo menu test program
stop=0                              # reset loop termination flag
while test $stop -eq 0              # loop until done
do
    cat << ENDOFMENU                # display meu
    1   : print the date.
    2, 3: print the current working directory.
    4   : exit
ENDOFMENU
    echo
    echo 'your choice? '          # prompt
    read reply                      # read response
    echo
    case $reply in                  # process response
        "1")
            date                    # display date
            ;;
        "2"|"3")
            pwd                     # display working directory
            ;;
        "4")
            stop=1                  # set loop termination flag
            ;;
        *)                          # default
            echo illegal choice     # error
            ;;
    esac
done
