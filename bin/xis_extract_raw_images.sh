#!/bin/bash

#xis_extract_raw_images.sh
#20090312 Takayuki Yuasa

pwd=`pwd`
indexof=`indexof.pl "$pwd" "xis/image_analysis"`
if [ $indexof == -1 ];
then
echo "run this script at analysis/xis/image_analysis/ folder."
exit
fi

outputdir=raw_images
logfile=$outputdir/xis_extract_raw_images.sh.log

for n in 0 1 2 3;
do

evtfile=../data/xis${n}_evt.evt
if [ -f $evtfile ];
then
rm -f $outputdir/xis${n}_bin?.img
xselect << EOF 2>&1 | tee -a $logfile

no
read event $evtfile ./
set xybinsize 1
extract image
save image $outputdir/xis${n}_bin1.img

set xybinsize 2
extract image
save image $outputdir/xis${n}_bin2.img

set xybinsize 4
extract image
save image $outputdir/xis${n}_bin4.img

set xybinsize 8
extract image
save image $outputdir/xis${n}_bin8.img

exit

EOF
fi
done


for chip in fi bi;
do

evtfile=../data/${chip}_evt.evt
if [ -f $evtfile ];
then

rm -f $outputdir/${chip}_bin?.img
xselect << EOF 2>&1 | tee -a $logfile

no
read event $evtfile ./
set xybinsize 1
extract image
save image $outputdir/${chip}_bin1.img

set xybinsize 2
extract image
save image $outputdir/${chip}_bin2.img

set xybinsize 4
extract image
save image $outputdir/${chip}_bin4.img

set xybinsize 8
extract image
save image $outputdir/${chip}_bin8.img

exit

EOF
fi

done

