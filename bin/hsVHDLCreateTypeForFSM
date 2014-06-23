#!/bin/bash

#20100601 Takayuki Yuasa

if [ _$2 = _ ];  then
name=`basename $0`
cat << EOF
usage : 
$name (file) (state variable name)

example :
$name fsm.vhdl fsm_state

The input file should contain an FSM VHDL code.
This script extract states used in the FSM, and
then outputs type declaration for the states.
EOF
exit
fi

if [ ! -f $1 ]; then
 echo "file not found...exit"
 exit
fi

file=$1
variable=$2

cat << EOF
type ${variable}s is (
EOF

grep when $file | grep "=>" | awk '{print " "$2","}'

cat << EOF
);
EOF
