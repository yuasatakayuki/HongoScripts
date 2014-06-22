#!/bin/bash

if [ _$1 = _ ]; then
name=`basename $0`
echo "usage : $name (xis fits file; event or PI file)"
exit
fi

file=$1

if [ ! -f $file ]; then
echo "not found..."
exit -1
fi

xisn=`instrume.sh $file`
if [ _$xisn != _ -a ${xisn:0:3} = "XIS" ]; then
n=${xisn:3}

calmask=`ls $CALDB/data/suzaku/xis/bcf/ae_xi${n}_calmask_*.fits 2> /dev/null| tail -1`
if [ _$calmask != _ ]; then
echo $calmask
fi
fi
