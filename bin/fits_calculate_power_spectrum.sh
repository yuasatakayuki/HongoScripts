#!/bin/bash

#20090901 Takayuki Yuasa
#20091003 Takayuki Yuasa bug in argument interpretation fixed

if [ _$5 = _ ];
then

echo "fits_calculate_power_spectrum.sh (input event file) (output fits file prefix) (output plot prefix) (bin time in sec) (calculation interval duration in sec) (number of interval per plotted frame;optional)"
exit

fi

windowfile=$hongoscriptsdir/astrophysics/etc/xronos_nowindow.wi

infile=$1
outputprefix=$2
plotprefix=$3
bin=$4
interval=$5

if [ _$6 = _ ];
then
nintfm=100000
else
nintfm=$6
fi

#files
psfile=${plotprefix}.ps

#number of bins in an interval
#see "fhelp powspec"
nbint=`calc "$interval/$bin"`

#create directory
mkdir -p `dirname $outputprefix` &> /dev/null
mkdir -p `dirname $plotprefix` &> /dev/null

#delete qdp files
delete_qdp_files.sh ${outputprefix}.qdp
delete_qdp_files.sh ${plotprefix}.qdp

#calculate power spectrum
powspec \
 cfile1="$infile" \
 window=$windowfile \
 dtnb=$bin \
 nbint=$nbint \
 nintfm=$nintfm \
 rebin=0 \
 plot=yes \
 plotdev="/xw" \
 outfile="${outputprefix}.fps" << EOF

we $plotprefix
hard $psfile/cps

EOF

#convert ps to pdf
pushd `dirname $plotprefix`

ps2pdf `basename $psfile`

popd
