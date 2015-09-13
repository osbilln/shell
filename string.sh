#!/bin/bash
stringZ=abcABC123ABCabc
#       |------|
#       12345678

echo `expr match "$stringZ" 'abc[A-Z]*.2' `
echo `expr "$stringZ" : 'abc[A-Z]*.2'`    
