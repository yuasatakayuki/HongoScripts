#!/bin/bash

if [ _$2 = _ ];
then
 echo "usage : mkxsp_result.sh PSFILE LOGFILE";
 exit
fi

ps=$1
log=$2
dir=`dirname $ps`
outps=$dir/`basename $ps .ps`_speclog.ps
outpdf=$dir/`basename $ps .ps`_speclog.pdf
tmp=mkxsp_result.tmp
tmp2=mkxsp_result.tmp2

a2ps.pl $2 > $tmp
rm $tmp2 2> /dev/null
psmerge.sh $tmp2 $ps $tmp
psnup -2 -s0.63 $tmp2 > $outps
ps2pdf $outps

rm $tmp $tmp2
