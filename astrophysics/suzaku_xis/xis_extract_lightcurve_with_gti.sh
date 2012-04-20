#!/bin/bash

#20090608 Takayuki Yuasa
#20090714 Takayuki Yuasa yaxis label fixed, extra condition bug fix

if [ _$5 = _ ];
then
cat << EOF
usage :
xis_extract_lightcurve_with_gti.sh \\
                      (1:event file) \\
                      (2:region file) \\
                      (3:GTI file) \\
                      (4:output file prefix) \\
                      (5:bin size in a unit of sec) \\
                      (6:extra_condition_file;optional)

note : output pdf file is created as (output file prefix).pdf
EOF
exit
fi

################################
#parameter set
################################
evt_file=$1
region_file=$2
gti_file=$3
outputprefix=$4
outputdir=`dirname $4`
binsize=$5

#default pha cut 137-2740 means a filtering with 0.5-10keV in energy
default_pha_cut="137 2740"

#extra condition file
#also apply default pha_cut
tmp_pha_cut=`get_hash_random.pl`
echo "filter pha_cut $default_pha_cut" > $tmp_pha_cut
if [ _$6 != _ ];
then
	if [ -f $6 ];
	then
		condition=`cat $tmp_pha_cut $6`
	else
		condition=`cat $tmp_pha_cut`
	fi
else
	condition=`cat $tmp_pha_cut`
fi
rm $tmp_pha_cut

#check
if [ -f $region_file ];
then
echo "region file found...OK"
else
echo "region file not found...exit"
exit
fi

#create directory
if [ ! -d `dirname $outputprefix` ];
then
mkdir -p `dirname $outputprefix`
fi

#log file
logfile=${outputprefix}.log
tmp=`get_hash_random.pl`
touch $logfile
touch $tmp

#########
#function
#########
function create_lc() {
#input function_in_file
#input function_out_lc
function_out_lc_lc=${function_out_lc}.lc
function_out_lc_ps=${function_out_lc}.ps
function_out_lc_pco=${function_out_lc}.pco
function_out_lc_qdp=${function_out_lc}.qdp

rm -f $function_out_lc_lc
rm -f $function_out_lc_ps $function_out_lc_pdf
rm -f $function_out_lc_pco $function_out_lc_qdp

tstart=`getheader.sh $function_in_file 0 TSTART`

xselect << EOF 2>&1 | tee $tmp

no

read event $function_in_file ./
filter time file $gti_file
filter region $region_file
$condition
extract event
set binsize $binsize
extract curve exposure=0.0
save curve $function_out_lc_lc
exit
no

EOF
cat $tmp >> $logfile
cps=`grep counts/sec $tmp | awk '{print $8}'`

#get pha min max from evtlc
phalowcut=`getheader.sh $function_out_lc_lc 1 phalcut`
phahighcut=`getheader.sh $function_out_lc_lc 1 phahcut`
energy_lowcut=`xis_pi_to_energy.sh $phalowcut`
energy_lowcut=`ruby -e "puts sprintf('%.1f',$energy_lowcut)"`
energy_highcut=`xis_pi_to_energy.sh $phahighcut`
energy_highcut=`ruby -e "puts sprintf('%.1f',$energy_highcut)"`

xselect << EOF 2>&1 | tee $tmp

no

read event $function_in_file ./
filter time file $gti_file
filter region $region_file
$condition
extract event
set binsize $binsize
extract curve exposure=0.0
plot curve
/NULL
ti off
cs 1.3
lwidth 3
lwidth 3 on 1..50
la ot
la t
la f `targetname.sh $function_in_file` / `basename $function_in_file` / $binsize s bin / ${energy_lowcut}-${energy_highcut} keV
la x TIME s (TSTART=$tstart or `suzaku_missiontime_to_utc.sh $tstart`)
la y Counts s\u-1\d
mark 17 on 2
r y 0 `calc $cps*1.6`
we $function_out_lc
hard $function_out_lc_ps/cps
exit

exit
no

EOF
pushd `dirname $function_out_lc` &> /dev/null
ps2pdf `basename $function_out_lc_ps`
popd &> /dev/null
}
#end of create_lc()

################################
#execution
################################
rm -f $logfile

##event lc
function_in_file=${evt_file}
function_out_lc=${outputprefix}_bin${binsize}
create_lc

#cleaning
rm $tmp

################################
#log
################################
