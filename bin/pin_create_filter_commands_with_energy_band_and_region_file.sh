#!/bin/bash

#20090901 Takayuki Yuasa
#20100406 Takayuki Yuasa

if [ _$3 = _ ];
then

echo "pin_create_filter_commands_with_energy_band.sh (output filter command text file) (energy cut low in keV;or none) (energy cut high in keV;or none)"
exit

fi

#parameters
outputfile=$1
elow=$2
ehigh=$3

#delete existing file
rm -f $outputfile

#filtering condition
if [ $elow != "none" -a $ehigh != "none" ];
then
phalow=`pin_energy_to_pi.sh $elow`
phahigh=`pin_energy_to_pi.sh $ehigh`
echo "filter pha_cut $phalow $phahigh" > $outputfile
echo "!this means ${elow} keV to ${ehigh} keV" >> $outputfile
fi

