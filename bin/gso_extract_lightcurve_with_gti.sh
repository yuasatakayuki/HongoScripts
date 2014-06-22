#!/bin/bash

#20090510 Shin'ya Yamada
#20090512 Takayuki Yuasa pure pseudo, pseudo !filter pha_cut fixed
#20090527 Takayuki Yuasa added energy cut in default

#pin_extract_spectrum_with_gti.sh

if [ _$6 = _ ];
then
cat << EOF
usage :
pin_extract_lightcurve_with_gti.sh \\
                      (1:cleaned event file) \\
                      (2:NXB file) \\
                      (3:pseudo event file) \\
                      (4:GTI file) \\
                      (5:output file prefix) \\
                      (6:bin size in a unit of sec) \\
                      (7:extra_condition_file;optional)

note : output pdf file is created as (output file prefix).pdf
EOF
exit
fi

################################
#parameter set
################################
evt_file=$1
nxb_file=$2
pse_file=$3
gti_file=$4
outputprefix=$5
outputdir=`dirname $5`
binsize=$6

#default pha cut 26-100 means a filtering with 50-200keV in energy
default_pha_cut="26 100"

#extra condition file
#also apply default pha_cut
tmp_pha_cut=`get_hash_random.pl`
echo "filter pha_cut $default_pha_cut" > $tmp_pha_cut
if [ _$7 != _ ];
then
if [ -f $7 ];
then
condition=`cat $tmp_pha_cut $7`
condition_for_pseudo=`sed -e 's/\(filter\ *pha_\)/!\1/g' $7`
fi
else
condition=`cat $tmp_pha_cut`
condition_for_pseudo=""
fi
rm $tmp_pha_cut

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
#input function_out_lc<br />
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
set phaname PI_SLOW
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
xselect << EOF 2>&1 | tee $tmp

no

read event $function_in_file ./
set phaname PI_SLOW
filter time file $gti_file
$condition
extract event
set binsize $binsize
extract curve exposure=0.0
plot curve
ti off
cs 1.3
lwidth 3
lwidth 3 on 1..50
la ot
la t
la f `targetname.sh $function_in_file` / `basename $function_in_file` / $binsize s bin 
la x TIME s (TSTART=$tstart or `suzaku_missiontime_to_utc.sh $tstart`)
mark 17 on 2
r y 0 `calc $cps*1.6`
we $function_out_lc
hard $function_out_lc_ps/cps
exit

exit
no

EOF
cd `dirname $function_out_lc`
ps2pdf `basename $function_out_lc_ps`
cd -
}
#end of create_lc()

################################
#execution
################################
rm -f $logfile

##event lc
function_in_file=$evt_file
function_out_lc=${outputprefix}_evt_bin${binsize}
create_lc

function_in_file=$nxb_file
function_out_lc=${outputprefix}_nxb_bin${binsize}
create_lc

##pseudo
###create pure pseudo
tmp_purepseudo=pure_pseudo.evt
rm -f $tmp_purepseudo &> /dev/null
fselect infile=${pse_file}+1 outfile=$tmp_purepseudo expr="GRADE_HITPAT<=1&&GRADE_QUALTY==0" histkw=yes

###replace condition variable
condition=$condition_for_pseudo

###execute pseudo extraction
function_in_file=$tmp_purepseudo
function_out_lc=${outputprefix}_pse_bin${binsize}
create_lc


#cleaning
rm $tmp
rm $tmp_purepseudo

################################
#log
################################
