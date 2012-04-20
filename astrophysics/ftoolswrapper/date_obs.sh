#!/bin/bash

#20090310 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "date_obs.sh FILE"
exit
fi

tmp=`getheader.sh $1 1 DATE-OBS`
echo "$tmp" | sed -e "s/'//g"


