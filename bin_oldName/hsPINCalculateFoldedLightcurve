#!/bin/bash

#20090902 Takayuki Yuasa
#20100406 Takayuki Yuasa

if [ _$8 = _ ];
then

cat << EOF
pin_calculate_folded_lightcurve.sh \\
                  (1:input event file) \\
                  (2:output fits file prefix)   \\
                  (3:output plot file prefix)   \\
                  (4:energy low in keV;  or none) \\
                  (5:energy high in keV; or none) \\
                  (6:folding period in sec) \\
                  (7:number of bins per phase) \\
                  (8:numer of bins per interval) \\
                  (9:number of intervals per frame;optional)

EOF
exit

fi

#parameters
windowfile=$hongoscriptsdir/astrophysics/etc/xronos_nowindow.wi

inputfile=$1
outputprefix=$2
plotprefix=$3
elow=$4
ehigh=$5
period=$6
numberofbinsperphase=$7
numberofbinsperinterval=$8

if [ _${9} = _ ];
then
numberofintervalsperframe=1000000
else
numberofintervalsperframe=${10}
fi

tmpeventfile=`get_hash_random.pl`.evt

#filtering condition
tmpconditionfile=`get_hash_random.pl`
pin_create_filter_commands_with_energy_band_and_region_file.sh $tmpconditionfile $elow $ehigh
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
