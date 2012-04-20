#!/bin/bash

#20090305 Takayuki Yuasa

#This script finds appropriate response
#file for a PIN spectrum from CALDB automatically.

if [ _$1 = _ ];
then
echo "usage : pin_find_responsefile_auto.sh (target file; e.g. PIN spectrum file)"
exit
fi

infile=$1

nominal=`getheader.sh $1 0 NOM_PNT`
epoch=`pin_get_epoch_of.sh $1`

if [ _$CALDB = _ -o ! -d $CALDB ];
then
echo "please set CALDB environmental variable"
echo "also, please check if CALDB is truely located there"
echo "e.g. export CALDB=/net/suzaku/process/caldb/2008-10-20"
exit
fi

if [ _$nominal = _'HXD' ];
then
nom=hxnom
else
nom=xinom
fi

hxdcpf=${CALDB}/data/suzaku/hxd/cpf/
response=`ls $hxdcpf/ae_hxd_pin${nom}e${epoch}*rsp | tail -1`

if [ ! -f $response ];
then
echo "No response file was found in $hxdcpf"
exit
fi

echo $response
