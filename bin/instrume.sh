#!/bin/bash

if [ _$1 = _ ];
then
echo "instrume.sh FILE (value)"
exit
fi

if [ _$2 = _ ];
then

tmp=`getheader.sh $1 1 instrume`
echo "$tmp" | sed -e "s/'//g"

else

setheader.sh $1 1 instrume $2

fi


