#!/bin/bash

#20090901 Takayuki Yuasa
#20090902 Takayuki Yuasa

if [ $# != 3 ];
then

echo "fits_filter_eventfile.sh (input event file) (output event file) (filtering command passed to XSELECT)"
echo "example 1: Filtering with PHA range"
echo " fits_filter_eventfile.sh suzaku_pin.evt suzaku_pin_filtered.evt \"filter pha_cut 20 100\""
echo ""
echo "example 2: Filtering with a region file"
echo " fits_filter_eventfile.sh suzaku_pin.evt suzaku_pin_filtered.evt \"filter region source_2arcmin.reg\""
exit

fi

#parameters
inputfile=$1
outputfile=$2
filtercommand="$3"

#delete existing file
rm -f $outputfile

#filtering
xselect << EOF

read event $inputfile ./
extract event

$filtercommand

show filter
extract event
save event $outputfile
yes

exit

EOF
