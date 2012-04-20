#!/bin/bash

#20080818 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "totalcounts.sh FILE1 FILE2 FILE3..."
exit
fi

for file in $@;
do

getheader.sh $file 1 totcts

done

