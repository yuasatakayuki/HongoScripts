#!/bin/bash

#20100407 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : date_to_mjd.sh (date in yyyy-mm-dd)"
exit
fi

aetimecalc input="date" date="$1" &> /dev/null
pget aetimecalc mjd | awk -F. '{print $1}'

