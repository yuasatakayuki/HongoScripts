#!/bin/bash

#20090902 Takayuki Yuasa

if [ _$9 = _ ];
then

cat << EOF
xis_calculate_folded_lightcurve.sh \\
                  (1:input event file) \\
                  (2:output fits file prefix)   \\
                  (3:output plot file prefix)   \\
                  (4:region file;or none)  \\
                  (5:energy low in keV;  or none) \\
                  (6:energy high in keV; or none) \\
                  (7:folding period in sec) \\
                  (8:number of bins per phase) \\
                  (9:numer of bins per interval) \\
                  (10:number of intervals per frame;optional)

EOF
exit

fi

#parameters
windowfile=$hongoscriptsdir/astrophysics/etc/xronos_nowindow.wi

inputfile=$1
outputprefix=$2
plotprefix=$3
regionfile=$4
elow=$5
ehigh=$6
period=$7
numberofbinsperphase=$8
numberofbinsperinterval=$9

if [ _${10} = _ ];
then
numberofintervalsperframe=1000000
else
numberofintervalsperframe=${10}
fi

tmpeventfile=`get_hash_random.pl`.evt

#filtering condition
tmpconditionfile=`get_hash_random.pl`
xis_create_filter_commands_with_energy_band_and_region_file.sh $tmpconditionfile $regionfile $elow $ehigh
#check if the condition file is successfully created
if [ ! -f $tmpconditionfile ];
then
echo "filter condition is not correct...exit"
exit
fi

#event selection
fits_filter_eventfile.sh $inputfile $tmpeventfile "`cat $tmpconditionfile`"

#calculate folded lightcurve
fits_calculate_folded_lightcurve.sh $tmpeventfile $outputprefix $plotprefix $period $numberofbinsperphase $numberofbinsperinterval $numberofintervalsperframe

#delete temporary files
rm -f $tmpeventfile $tmpconditionfile
