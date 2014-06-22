#!/bin/bash

#20090308 Takayuki Yuasa

#check current folder
wd=`get_current_foldername`
if [ _$wd != _gso ];
then

cat << EOF
usage : gso_barycentric_correction_auto.sh (ra; optional) (dec; optional)

Run this command in gso/ folder with no argument.

New event and NXB files will be created in data/ folder
by processing existing event and NXB files.
EOF

exit
fi

#############################################
# parameter setting
#############################################
gsoevtfile=data/gso_evt.evt
if [ ! -f $gsoevtfile ];
then
echo "gso event file ($pinevtfile) is not found...exit"
exit
fi

if [ _$2 = _ ];
then
ra=`ra_obj.sh $gsoevtfile`
dec=`dec_obj.sh $gsoevtfile`
else
ra=$1
dec=$2
fi
echo "Target (RA,DEC)=(${ra},${dec})"

orbfile=`ls auxil/ae*.orb 2> /dev/null`
if [ _$orbfile = _ ];
then
echo "orbit file is not found in auxil/ folder...exit"
exit
fi

#############################################
# function
#############################################
function doCorrection(){
#barycentric correction
cp $evtfile $outputfile
aebarycen filelist=$outputfile orbit=$orbfile ra=$ra dec=$dec leapfile=CALDB 
}

#############################################
# body
#############################################
evtfile=data/gso_evt.evt
outputfile=data/gso_evt_barycentric_correction.evt
doCorrection

evtfile=data/gso_nxb.evt
outputfile=data/gso_nxb_barycentric_correction.evt
doCorrection

evtfile=data/pseudo.evt
outputfile=data/pseudo_barycentric_correction.evt
doCorrection
