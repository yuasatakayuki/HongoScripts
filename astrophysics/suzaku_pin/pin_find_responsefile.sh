#!/bin/bash

#20090305 Takayuki Yuasa

#This script finds appropriate response
#file for a PIN spectrum from CALDB automatically.

#epoch
#nominal position

if [ _$2 = _ ];
then
echo "usage : pin_find_responsefile.sh (nominal position:hxd/xis) (epoch:1-6)"
exit
fi

nominal=$1
epoch=$2

if [ _$CALDB = _ -o ! -d $CALDB ];
then
echo "please set CALDB environmental variable"
echo "also, please check if CALDB is truely located there"
echo "e.g. export CALDB=/net/suzaku/process/caldb/2008-10-20"
exit
fi

if [ $nominal = hxd ];
then
nom=hxnom
elif [ $nominal = flat ];
then
nom=flat
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
