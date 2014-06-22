 #!/bin/bash

#20090510 Shinya Yamada
#20090527 Takayuki Yuasa change to accept extra condition

pwd=`pwd`
if [ `basename $pwd` != lightcurve_analysis ];
then
echo "run this script at analysis/gso/lightcurve_analysis/ folder."
exit
fi

if [ _$1 != _ ];
then
if [ -f $1 ];
then
extraconditionfile=$1
echo "Extra condition file $extraconditionfile is used"
else
echo "Extra condition file $extraconditionfile not found...exit"
exit
fi
fi

read -p "input tag name > " tag
# display before input


if [ _$tag = _ ];
then
echo "tag name empty...exit"
exit
fi


mkdir lcfiles/${tag} &> /dev/null
mkdir gtis/${tag} &> /dev/null


#merge gtis
pin_merge_gtis.sh \
../data/gso_evt.evt+2 \
../data/gso_nxb.evt+2 \
gtis/${tag}/cleaned_evt_nxb_merged.gti


for binsize in 1000;
#for binsize in 100 300 600 900;
do

gso_extract_lightcurve_with_gti.sh \
../data/gso_evt.evt \
../data/gso_nxb.evt \
../data/pseudo.evt \
gtis/${tag}/cleaned_evt_nxb_merged.gti \
lcfiles/${tag}/gso_evt ${binsize} $extraconditionfile

gso_lightcurve_correct_deadtime_and_nxb.sh \
lcfiles/${tag}/gso_evt_evt_bin${binsize}.lc \
lcfiles/${tag}/gso_evt_nxb_bin${binsize}.lc \
lcfiles/${tag}/gso_evt_pse_bin${binsize}.lc \
lcfiles/${tag}/gso_evt_bin${binsize}_corrected_for_dt_nxb \
../auxil/ae*.ehk

done
