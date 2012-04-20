#!/bin/bash

#20090901 Takayuki Yuasa
#20090902 Takayuki Yuasa

if [ _$9 = _ ];
then

cat << EOF
xis_search_periodicity.sh \\
                  (1:input event file)     \\
                  (2:output fits file prefix)   \\
                  (3:output plots file prefix)   \\
                  (4:region file;or none)  \\
                  (5:energy low in keV;  or none) \\
                  (6:energy high in keV; or none) \\
                  (7:approximated period in sec) \\
                  (8:number of phases per period) \\
                  (9:search resolution in sec) \\
                  (10:search period width in sec)
EOF

exit
fi

inputfile=$1
outputprefix=$2
plotprefix=$3
regionfile=$4
elow=$5
ehigh=$6
period=$7
numberofphasesperperiod=$8
resolution=$9
searchwidth=${10}

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

#calculate power spectrum
fits_search_periodicity.sh $tmpeventfile $outputprefix $plotprefix $period $numberofphasesperperiod $resolution $searchwidth

#delete temporary files
rm -f $tmpeventfile $tmpconditionfile
