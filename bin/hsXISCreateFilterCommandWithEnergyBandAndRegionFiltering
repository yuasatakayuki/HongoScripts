#!/bin/bash

#20090901 Takayuki Yuasa

if [ _$4 = _ ];
then

echo "xis_create_filter_commands_with_energy_band_and_region_file.sh (output filter command text file) (region file; or none) (energy cut low in keV;or none) (energy cut high in keV;or none)"
exit

fi

#parameters
outputfile=$1
regionfile=$2
elow=$3
ehigh=$4

#delete existing file
rm -f $outputfile

#filtering condition
if [ $elow != "none" -a $ehigh != "none" ];
then
phalow=`xis_energy_to_pi.sh $elow`
phahigh=`xis_energy_to_pi.sh $ehigh`
echo "filter pha_cut $phalow $phahigh" > $outputfile
echo "!this means ${elow} keV to ${ehigh} keV" >> $outputfile
fi

if [ $regionfile != "none" ];
then

if [ ! -f $regionfile ];
then
echo "region file not found...exit"
exit
fi

echo "filter region $regionfile" >> $outputfile
fi
