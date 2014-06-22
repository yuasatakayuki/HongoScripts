#!/bin/bash

#20090901 Takayuki Yuasa
#20090902 Takayuki Yuasa

if [ _$6 = _ ];
then

echo "fits_search_periodicity.sh (event file) (output fits file prefix) (output plot prefix) (approximated period in sec) (number of phases per period) (search resolution in sec) (search period width in sec)"
exit

fi

windowfile=$hongoscriptsdir/astrophysics/etc/xronos_nowindow.wi

infile=$1
outputprefix=$2
plotprefix=$3
period=$4
numberofphasesperperiod=$5
resolution=$6
searchperiod=$7

numberoftrials=`calc "($searchperiod/$resolution)"`

#files
psfile=${plotprefix}.ps

#create directory
mkdir -p `dirname $outputprefix` &> /dev/null
mkdir -p `dirname $plotprefix` &> /dev/null

#delete qdp files
delete_qdp_files.sh ${outputprefix}.qdp
delete_qdp_files.sh ${plotprefix}.qdp

#calculate power spectrum
efsearch \
 cfile1=$infile \
 window=$windowfile \
 sepoch=INDEF \
 dper=$period \
 nphase=$numberofphasesperperiod \
 nbint=INDEF \
 dres=$resolution \
 nper=$numberoftrials \
 outfile="${outputprefix}.fes" \
 plot=yes \
 plotdev="/xw" << EOF

we $plotprefix
hard $psfile/cps

EOF

pushd `dirname $plotprefix`

ps2pdf `basename $psfile`

popd
