#!/bin/bash

#20090308 Takayuki Yuasa

if [ _$4 = _ ];
then
echo "pin_extract_cleaned_event.sh (HXD unfiltered file) (hxd/hk directory) (auxil directory) (output filename of PIN cleaned events)"
exit
fi

uffile=$1
hxdhk=$2
auxil=$3
outfilename=$4

hxdhkfile=`ls $hxdhk/ae*.hk`
hxdgtifile=`ls $hxdhk/ae*tel*.gti`

hkfile=`ls $auxil/ae*.hk`
ehkfile=`ls $auxil/ae*.ehk`
timfile=`ls $auxil/ae*.tim`

if [ -f $hkfile -a -f $hxdhkfile -a -f $ehkfile -a -f $hxdgtifile ];
then
echo "all files are found"
else
echo "needed hk files are not found"
echo "please check whether auxil directory and HXD hk directory are correctly provided"
exit
fi

#################################
#time assignment
#################################
tmp_hxdtime_out=`get_hash_random.pl`.evt

hxdtime \
input_name=$uffile \
create_name=$tmp_hxdtime_out \
tim_filename=$timfile \
hklist_name=$hxdhkfile \
leapfile=$HEADAS/refdata/leapsec.fits \
read_iomode=create \
time_change=y \
grade_change=n \
pi_pmt_change=n \
pi_pin_change=n \
gtimode=y gti_time=S_TIME \
time_convert_mode=4 \
use_pwh_mode=n \
num_event=-1 \
event_freq=1000000 \
anl_verbose=-1 anl_profile=yes

#check
if [ ! -f $tmp_hxdtime_out ];
then
echo "Error : hxdtime was not successfully executed"
echo "outputfile $tmp_hxdtime_out was not created"
exit
fi


#################################
#PI assignment
#################################

hkfilelist=`get_hash_random.pl`
ls $hxdhkfile $ehkfile > $hkfilelist

hxdpi \
input_name=$tmp_hxdtime_out \
hklist_name= @$hkfilelist \
read_iomode=overwrite \
time_change=n grade_change=n \
pi_pmt_change=y pi_pin_change=y \
gtimode=n gti_time=S_TIME \
rand_seed=7 rand_skip=0 \
use_pwh_mode=n num_event=-1 \
event_freq=1000000 anl_verbose=-1 anl_profile=yes \
hxd_pinghf_fname=CALDB hxd_pinlin_fname=CALDB \
hxd_gsoght_fname=CALDB hxd_gsolin_fname=CALDB


#################################
#Grade filtering
#################################
hxdgrade \
input_name=$tmp_hxdtime_out \
hxdgrade_psdsel_fname=CALDB \
hxdgrade_pinthres_fname=CALDB \
leapfile=CALDB \
hxdgrade_psdsel_criteria=2.1 \
read_iomode=overwrite \
time_change=n \
grade_change=y \
pi_pmt_change=n pi_pin_change=n \
gtimode=n gti_time=S_TIME \
use_pwh_mode=n num_event=-1 \
event_freq=1000000 anl_verbose=-1 anl_profile=yes


#################################
#filter with hk file
#################################
tmp=`get_hash_random.pl`.evt
xselect << EOF

no
read event $tmp_hxdtime_out ./
read hk
./
$hkfile
yes
select hk
AOCU_HK_CNT3_NML_P==1

extract event
save event $tmp

exit

EOF

#filter with ehk
tmp2=`get_hash_random.pl`.evt
xselect << EOF

no
read event $tmp ./
read hk
.
$ehkfile
yes
select hk
ELV>5 && SAA_HXD.eq.0 && T_SAA_HXD>500 && COR>6
extract event

save event $tmp2

exit

EOF


#filter with hxdhk
tmp3=`get_hash_random.pl`.evt
xselect << EOF

no
read event $tmp2 ./
read hk
.
$hxdhkfile
yes
select hk
HXD_DTRATE<3 && HXD_HV_W0_CAL>700 && HXD_HV_W1_CAL>700 && HXD_HV_W2_CAL>700 && HXD_HV_W3_CAL>700 && HXD_HV_T0_CAL>700 && HXD_HV_T1_CAL>700 && HXD_HV_T2_CAL>700 && HXD_HV_T3_CAL>700 
extract event

save event $tmp3

exit

EOF


#################################
#filter with mkf file
#################################
tmp_mkf=`get_hash_random.pl`
wget http://suzaku.gsfc.nasa.gov/docs/suzaku/analysis/pin_mkf.sel
mv pin_mkf.sel $tmp_mkf

tmp_cleanedevent=`get_hash_random.pl`.evt
xselect << EOF

no
read event $tmp3 ./
select mkf @$tmp_mkf
$auxil

filter time file $hxdgtifile

filter column
"DET_TYPE=1:1"

extract event
save event
$tmp_cleanedevent
yes

exit

EOF


#################################
#write header keywords
#################################
#DETECTOR NAME
fparkey fitsfile="$tmp_cleanedevent+0" value="WELL_PIN" keyword="DETNAM" comm="detector name" add=no
fparkey fitsfile="$tmp_cleanedevent+1" value="WELL_PIN" keyword="DETNAM" comm="detector name" add=no

#TIME RESOLUTION
fparkey fitsfile="$tmp_cleanedevent+0" value="6.1E-05" keyword="TIMEDEL" comm="finest time resolution (time between frames)" add=no
fparkey fitsfile="$tmp_cleanedevent+1" value="6.1E-05" keyword="TIMEDEL" comm="finest time resolution (time between frames)" add=no


#################################
#create final output file
#################################
#cleaning
rm -f $tmp $tmp2 $tmp3
rm -f $tmp_hxdtime_out $tmp_mkf
#move tmp to outfilename
mv $tmp_cleanedevent $outfilename

