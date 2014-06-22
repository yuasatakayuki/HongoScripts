#!/bin/bash

#20090318 Takayuki Yuasa
#20090526 Takayuki Yuasa cpd deleted (xspec no window mode)
#20090707 Takayuki Yuasa title option, background scaling according to BACKSCAL
#20100125 Takayuki Yuasa yes is added after exit command of XSPEC

if [ _$1 = _ ];
then

cat << EOF
xis_create_check_spectra_plot.sh \\
 (event pi file) \\
 (nxb pi file; or none) \\
 (cxb pi file; or none) \\
 (bgd pi file; or none) \\
 (response file) \\
 (auxiliary response file; or none) \\
 (output pdf filename) \\
 (title;optional, default=OBJECT)
EOF
exit

fi

#parameter set
evtfile=$1
nxbfile=$2
cxbfile=$3
bgdfile=$4
rmf=$5
arf=$6
outputpdf=$7
if [ _"$8" = _"" ];
then
title=`targetname.sh $evtfile`
else
title=$8
fi

outputps=`dirname $outputpdf`/`basename $outputpdf .pdf`.ps
xcm=`dirname $outputpdf`/`basename $outputpdf .pdf`.xcm
qdp=`dirname $outputpdf`/`basename $outputpdf .pdf`.qdp
qdpbase=`dirname $outputpdf`/`basename $outputpdf .pdf`
delete_qdp_files.sh $qdp

#get evt exposure
if [ ! -f $evtfile ];then
 echo "evt pi file not found...exit"
 exit
fi
backscal_evt=`backscal.sh $evtfile`

#nxb rescaling
if [ ! $nxbfile = none ];then
 if [ ! -f $nxbfile ];then
  echo "nxb file not found...exit"
  exit
 fi
 backscal_nxb=`backscal.sh $nxbfile`
 exposure_nxb=`exposure.sh $nxbfile`
 nxbfile_scaled=`get_hash_random.pl`.pi
 cp $nxbfile $nxbfile_scaled
 exposure.sh $nxbfile_scaled `calc "$exposure_nxb*$backscal_nxb/$backscal_evt"`
 nxbfile=$nxbfile_scaled
fi

#cxb rescaling
if [ ! $cxbfile = none ];then
 if [ ! -f $cxbfile ];then
  echo "cxb file not found...exit"
  exit
 fi
 backscal_cxb=`backscal.sh $cxbfile`
 exposure_cxb=`exposure.sh $cxbfile`
 cxbfile_scaled=`get_hash_random.pl`.pi
 cp $cxbfile $cxbfile_scaled
 exposure.sh $cxbfile_scaled `calc "$exposure_cxb*$backscal_cxb/$backscal_evt"`
 cxbfile=$cxbfile_scaled
fi

#bgd rescaling
if [ ! $bgdfile = none ];then
 if [ ! -f $bgdfile ];then
  echo "bgd file not found...exit"
  exit
 fi
 backscal_bgd=`backscal.sh $bgdfile`
 exposure_bgd=`exposure.sh $bgdfile`
 bgdfile_scaled=`get_hash_random.pl`.pi
 cp $bgdfile $bgdfile_scaled
 exposure.sh $bgdfile_scaled `calc "$exposure_bgd*$backscal_bgd/$backscal_evt"`
 bgdfile=$bgdfile_scaled
fi
         
#xspec nowindow mode
export PGPLOT_TYPE=""


xis_create_xcm_for.sh $evtfile $nxbfile $cxbfile $bgdfile $rmf $arf $xcm

exposure=`exposure.sh $evtfile`
exposure=`calc $exposure/1000`ks

cat << EOF >> $xcm

iplot
cs 1.3
fo ro
ti of
la t
la f $title / $exposure
lwidth 3
lwidth 3 on 1..50
la x Energy keV
la y Counts s\u-1\d keV\u-1
we $qdpbase
hard $outputps/cps
quit

exit
yes

EOF

xspec < $xcm

rm $nxbfile_scaled $cxbfile_scaled $bgdfile_scaled

cd `dirname $outputpdf`
pwd
ps2pdf `basename $outputps`
cd - &> /dev/null
