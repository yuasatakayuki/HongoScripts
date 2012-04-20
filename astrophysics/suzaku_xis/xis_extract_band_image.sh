#!/bin/bash

#xis_extract_band_image.sh
#20090713 Takayuki Yuasa

if [ _$3 = _ ];
then
cat << EOF
usage : 
xis_extract_band_image.sh \\
               (input event file)            \\
               (output image file prefix)    \\
               (red energy range lower limit; in keV)    \\
               (red energy range upper limit; in keV)    \\
               (green energy range lower limit; in keV)    \\
               (green energy range upper limit; in keV)    \\
               (blue energy range lower limit; in keV)    \\
               (blue energy range upper limit; in keV)    \\
               (region file;or none)                      \\
               (extra condition file;optional)
               
Output files are :
 \${prefix}_binX_R.img for Red-band image
 \${prefix}_binX_G.img for Green-band image
 \${prefix}_binX_B.img for Blue-band image
 
EOF
exit
fi

pwd=`pwd`
indexof=`indexof.pl "$pwd" "xis/image_analysis"`
if [ $indexof == -1 ];
then
echo "run this script at analysis/xis/image_analysis/ folder."
exit
fi

evtfile=$1
outputdir=`dirname $2`
outputfileprefix=`basename $2`
red_lower_e=$3
red_upper_e=$4
green_lower_e=$5
green_upper_e=$6
blue_lower_e=$7
blue_upper_e=$8

if [ _$9 != _ ];
then
  if [ -f $9 ];
  then
   regionfilter="filter region $9"
  fi
fi

if [ _${10} = _ ];
then
extra=""
else
extra=`cat ${10}`
fi

logfile=$outputdir/`basename $outputfileprefix`_bandimage.log

mkdir -p $outputdir &> /dev/null

if [ ! -f $logfile ];
then
touch $logfile
fi

##############
#loop red,green,blue
##############
for n in 1 2 4 8;
do
phacutrange_red="`xis_energy_to_pi.sh $red_lower_e` `xis_energy_to_pi.sh $red_upper_e`"
phacutrange_green="`xis_energy_to_pi.sh $green_lower_e` `xis_energy_to_pi.sh $green_upper_e`"
phacutrange_blue="`xis_energy_to_pi.sh $blue_lower_e` `xis_energy_to_pi.sh $blue_upper_e`"

xselect << EOF 2>&1 | tee -a $logfile

no
read event $evtfile ./

$regionfilter
$extra
set xybinsize $n

filter pha_cut $phacutrange_red
extract image
save image $outputdir/`basename $outputfileprefix .img`_bin${n}_R.img

filter pha_cut $phacutrange_green
extract image
save image $outputdir/`basename $outputfileprefix .img`_bin${n}_G.img

filter pha_cut $phacutrange_blue
extract image
save image $outputdir/`basename $outputfileprefix .img`_bin${n}_B.img

exit


EOF

done
