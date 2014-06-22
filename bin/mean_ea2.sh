#!/bin/bash

if [ _$1 = _ ];
then
echo "mean_ea2.sh FILE"
exit
fi

getheader.sh $1 0 mean_ea2


