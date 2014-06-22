#!/bin/bash

#20090414 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : pin_find_flat_responsefile.sh (epoch)"
exit
fi

nominal=flat
epoch=$1

if [ _$CALDB = _ -o ! -d $CALDB ];
then
echo "please set CALDB environmental variable"
echo "also, please check if CALDB is truely located there"
echo "e.g. export CALDB=/net/suzaku/process/caldb/2008-10-20"
exit
fi

hxdcpf=${CALDB}/data/suzaku/hxd/cpf/
response=`ls $hxdcpf/ae_hxd_pin${nominal}e${epoch}*rsp | tail -1`

if [ ! -f $response ];
then
echo "No response file was found in $hxdcpf"
exit
fi

echo $response
