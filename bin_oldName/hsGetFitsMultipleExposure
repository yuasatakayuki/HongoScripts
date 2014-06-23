#!/bin/bash

if [ _$1 = _ ];
then
echo "exposures.sh FILE1 FILE2 FILE3..."
exit
fi

for file in $@;
do

getheader.sh $file 1 exposure

done

