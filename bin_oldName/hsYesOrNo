#!/bin/bash

#20090331 Takayuki Yuasa
#20090714 Takayuki Yuasa configurable prompt

trap "echo 'no';exit" 2

if [ $# -eq 0 ];
then
prompt="yes/no > "
else
prompt=$1
fi


while read -p "$prompt" line;
do
if [ _$line = _yes ];
then
echo "yes"
exit
fi

if [ _$line = _no ];
then
echo "no"
exit
fi
 
done

