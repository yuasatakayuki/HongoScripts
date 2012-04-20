#!/bin/bash

#20101015 Takayuki Yuasa

if [ _$1 = _ ]; then
echo "gso_get_latest_arf.sh (GSO file; spectrum or event file)"
exit -1
fi

file=$1

#check existence
if [ ! -f $file ]; then
echo "File not found..."
exit -1
fi


#check nominal position
nom=`nom_pnt.sh $file`

#return
if [ $nom = HXD ]; then
echo "ae_hxd_gsohxnom_crab_20100526.arf"
else
echo "ae_hxd_gsoxinom_crab_20100526.arf"
fi
