#!/bin/bash

if [ _$1 = _ ];
then
echo "mean_ea3.sh FILE"
exit
fi

getheader.sh $1 0 mean_ea3


