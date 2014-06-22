#!/bin/bash

#20090305 Takayuki Yuasa
#20100115 Takayuki Yuasa added HS_Target_Name_Long support
#20100125 Takayuki Yuasa sed command fixed

if [ _$1 = _ ];
then
echo "targetname.sh FILE"
exit
fi

if [ ! -f $1 ];
then
echo "input file is not found..."
exit
fi

if [ _"${HS_Target_Name_Long}" = _ ];
then
getheader.sh $1 1 OBJECT | sed -e "s/'//g"  | sed -e 's/\n//g' 
else
echo $HS_Target_Name_Long
fi
