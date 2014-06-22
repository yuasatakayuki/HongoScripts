#!/bin/bash

#xis_extract_raw_images.sh
#20090312 Takayuki Yuasa

if [ _$3 = _ ];
then
echo "xis_extract_filtered_images.sh (input event file) (output image file) (region file) (extra condition file;optional)"
exit
fi

pwd=`pwd`
indexof=`indexof.pl "$pwd" "xis/image_analysis"`
if [ $indexof == -1 ];
then
echo "run this script at analysis/xis/image_analysis/ folder."
exit
fi

evtfile=$1
outputdir=`dirname $2`
outputfile=`basename $2`
regionfile=$3

if [ _$4 = _ ];
then
extra=""
else
extra=`cat $4`
fi

logfile=$outputdir/`basename $outputfile`.log

mkdir -p $outputdir

xselect << EOF 2>&1 | tee -a $logfile

no
read event $evtfile ./

filter region $regionfile
$extra

set xybinsize 1
extract image
save image $outputdir/$outputfile
save image $outputdir/`basename $outputfile .img`_bin1.img

set xybinsize 2
extract image
save image $outputdir/`basename $outputfile .img`_bin2.img

set xybinsize 4
extract image
save image $outputdir/`basename $outputfile .img`_bin4.img

set xybinsize 8
extract image
save image $outputdir/`basename $outputfile .img`_bin8.img

exit


EOF
