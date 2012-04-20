#!/bin/bash

#20090526 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : go_suzaku_simultaneous_pin_gso_checkplot.sh (obsid) (folder name;optional, default=OBSID) (tag name;optional, default=cleanedevent)"
exit
fi


########################################
#parameter set
########################################
obsid=$1

if [ _$2 = _ ];
then
foldername=$obsid
else
foldername=$2
fi

if [ _$3 = _ ];
then
tagname=cleanedevent
else
tagname=$2
fi

topdir=`pwd`

logfile="$topdir/$foldername/pin_gso_checkplot.log"
mkdir -p `dirname $logfile`
touch $logfile

suzaku_create_analysis_folder.sh $foldername 2>/dev/null | tee -a $logfile

if [ ! -d $logfile ];
then
touch $logfile
fi

cat << EOF 2>&1 | tee -a $logfile
########################################
# go_suzaku_simultaneous_pin_gso_checkplot.sh
# `dateyymmdd_hhmm`
########################################
EOF

cat << EOF 2>&1 | tee -a $logfile
########################################
#download data
########################################
EOF
cd $topdir/$foldername/data
pwd 2>&1 | tee -a $logfile
suzaku_download_data_indicating_obsid.sh $obsid 2>&1 | tee -a $logfile
if [ ! -d $obsid ];
then
echo "data could not be downloaded..."
exit
fi

cd $topdir/$foldername/data/bgd
pwd 2>&1 | tee -a $logfile
pin_download_nxbs.sh 2>&1 | tee -a $logfile
gso_download_nxbs.sh 2>&1 | tee -a $logfile

pinnxb=`ls ae*pin* 2> /dev/null`
gsonxb=`ls ae*gso* 2> /dev/null`

cat << EOF 2>&1 | tee -a $logfile
########################################
#unzip large files
########################################
EOF
cd $topdir/$foldername/data/$obsid/hxd/event_uf
pwd 2>&1 | tee -a $logfile
gzip -d *gz 2>&1 | tee -a $logfile


cat << EOF 2>&1 | tee -a $logfile
########################################
#pin
########################################
EOF
if [ _$pinnxb != _ ];
then

cd $topdir/$foldername/analysis/pin
pwd 2>&1 | tee -a $logfile
echo "Linking Event" 2>&1 | tee -a $logfile
pin_link_event.sh ../../data/$obsid 2>&1 | tee -a $logfile

#check
if [ ! -f data/pin_nxb.evt ];
then
echo "nxb file not found...exit" 2>&1 | tee -a $logfile
exit
fi

cd $topdir/$foldername/analysis/pin/lightcurve_analysis
pwd 2>&1 | tee -a $logfile
echo "go_pin_lightcurve.sh" 2>&1 | tee -a $logfile
go_pin_lightcurve.sh << EOF  2>&1 | tee -a $logfile
$tagname
EOF

cd $topdir/$foldername/analysis/pin/spectral_analysis
pwd 2>&1 | tee -a $logfile
echo "go_pin_spec.sh" 2>&1 | tee -a $logfile
go_pin_spec.sh << EOF  2>&1 | tee -a $logfile
$tagname
none
EOF

fi

cat << EOF 2>&1 | tee -a $logfile
########################################
#gso
########################################
EOF
if [ _$gsonxb != _ ];
then

cd $topdir/$foldername/analysis/gso
pwd 2>&1 | tee -a $logfile
echo "Linking Event" 2>&1 | tee -a $logfile
gso_link_event.sh ../../data/$obsid 2>&1 | tee -a $logfile

#check
if [ ! -f data/gso_nxb.evt ];
then
echo "nxb file not found...exit" 2>&1 | tee -a $logfile
exit
fi

cd $topdir/$foldername/analysis/gso/lightcurve_analysis
pwd 2>&1 | tee -a $logfile
echo "go_gso_lightcurve.sh" 2>&1 | tee -a $logfile
go_gso_lightcurve.sh << EOF  2>&1 | tee -a $logfile
$tagname
EOF

cd $topdir/$foldername/analysis/gso/spectral_analysis
pwd 2>&1 | tee -a $logfile
echo "go_gso_spec.sh" 2>&1 | tee -a $logfile
go_gso_spec.sh << EOF  2>&1 | tee -a $logfile
$tagname
EOF

fi

cat << EOF 2>&1 | tee -a $logfile
########################################
#summary
########################################
EOF
cd $topdir/
pwd 2>&1 | tee -a $logfile
#pin/gso spec
pinspec=`ls $foldername/analysis/pin/spec*/plots/cle*/*pdf`
gsospec=`ls $foldername/analysis/gso/spec*/plots/cle*/*pdf`

#pin/gso lc
pinlc=`ls $foldername/analysis/pin/lig*/lc*/cle*/*bin600*saa*pdf`
gsolc=`ls $foldername/analysis/gso/lig*/lc*/cle*/*bin1000*saa*pdf`

pdftk $pinspec $gsospec $pinlc $gsolc cat output summary_pin_gso.pdf
mkdir $foldername/analysis/simultaneous/plots/$tagname &> /dev/null
mv summary_pin_gso.pdf $foldername/analysis/simultaneous/plots/$tagname

echo "summary plot was saved to $foldername/analysis/simultaneous/plots/$tagname/summary_pin_gso.pdf"
