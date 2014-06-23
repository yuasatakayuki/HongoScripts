#!/bin/bash

#20090313 Takayuki Yuasa

if [ _$2 = _ ];
then
echo "xis_create_detector_region.sh (xis fits file) (output region file)"
exit
fi

inputfile=$1
outputfile=$2
aemkreg -xis `mean_ea1.sh $inputfile` `mean_ea2.sh $inputfile` `mean_ea3.sh $inputfile` > $outputfile
