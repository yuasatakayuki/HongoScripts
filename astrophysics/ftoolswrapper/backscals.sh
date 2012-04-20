#!/bin/bash

#20080818 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "backscals.sh FILE1 FILE2 FILE3..."
exit
fi

for file in $@;
do

getheader.sh $file 1 backscal

done

