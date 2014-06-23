#!/bin/bash

#20090304 Takayuki Yuasa
#20090901 Takayuki Yuasa added powerspectra in lightcurve_analysis
#20100125 Takayuki Yuasa ana/ changed to analysis/, matome/ changed to summary/

#create suzaku data analysis folder

#Constants
analysisfolder="analysis"
summaryfolder="summary"

if [ _$1 = _ ];
then
echo "give folder name"
echo "Example"
echo " mk_suzaku_data_analysis_folder.sh yydra"
echo " will create :"
cat << EOF
yydra/
yydra/${analysisfolder}/
yydra/${analysisfolder}/xis/
yydra/${analysisfolder}/xis/data/
yydra/${analysisfolder}/xis/scripts/
yydra/${analysisfolder}/xis/spectral_analysis/
yydra/${analysisfolder}/xis/image_analysis
yydra/${analysisfolder}/pin/
yydra/${analysisfolder}/pin/data/
yydra/${analysisfolder}/pin/scripts/
yydra/${analysisfolder}/pin/spectrum_analysis/
yydra/${analysisfolder}/gso/
yydra/data/
EOF

exit

fi

targetname=$1



mkdir ${targetname}/
mkdir ${targetname}/${analysisfolder}/
mkdir ${targetname}/data/
mkdir ${targetname}/data/bgd
mkdir ${targetname}/${summaryfolder}/

for det in xis pin gso;
do

mkdir ${targetname}/${analysisfolder}/$det/
mkdir ${targetname}/${analysisfolder}/$det/data/
mkdir ${targetname}/${analysisfolder}/$det/data/bgd
mkdir ${targetname}/${analysisfolder}/$det/scripts/

mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/tmp
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/lcfiles
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/dumps
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/plots
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/logs
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/scripts
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/analysis
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/extraconditions
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/powerspectra
mkdir ${targetname}/${analysisfolder}/$det/lightcurve_analysis/folded_lcfiles
if [ -d ${targetname}/${analysisfolder}/$det/lightcurve_analysis ];
then
cd ${targetname}/${analysisfolder}/$det/lightcurve_analysis
if [ ! -d gtis ];
then
ln -sf ../spectral_analysis/gtis
fi
cd - &> /dev/null
fi

mkdir ${targetname}/${analysisfolder}/$det/image_analysis/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/tmp
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/raw_images/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/filtered_images/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/band_images/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/flattened_images/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/projection/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/regions/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/${summaryfolder}/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/logs/
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/scripts
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/analysis
mkdir ${targetname}/${analysisfolder}/$det/image_analysis/extraconditions
if [ -d ${targetname}/${analysisfolder}/$det/image_analysis ];
then
cd ${targetname}/${analysisfolder}/$det/image_analysis
if [ ! -d gtis ];
then
ln -sf ../spectral_analysis/gtis
fi
if [ ! -d regions ];
then
ln -s ../image_analysis/regions
fi
cd - &> /dev/null
fi


mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/pis/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/tmp/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/gtis/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/fittings/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/xcm/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/plots/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/responses/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/arfs/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/nxbs/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/cxbs/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/bgds/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/${summaryfolder}/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/logs/
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/scripts
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/analysis
mkdir ${targetname}/${analysisfolder}/$det/spectral_analysis/extraconditions
if [ -d ${targetname}/${analysisfolder}/$det/spectral_analysis ];
then
cd ${targetname}/${analysisfolder}/$det/spectral_analysis/
ln -s ../image_analysis/regions
cd - &> /dev/null
fi

done


mkdir ${targetname}/${analysisfolder}/simultaneous
mkdir ${targetname}/${analysisfolder}/simultaneous/xcm
mkdir ${targetname}/${analysisfolder}/simultaneous/fittings
mkdir ${targetname}/${analysisfolder}/simultaneous/plots
mkdir ${targetname}/${analysisfolder}/simultaneous/matome
mkdir ${targetname}/${analysisfolder}/simultaneous/scripts
mkdir ${targetname}/${analysisfolder}/simultaneous/tmp
mkdir ${targetname}/${analysisfolder}/simultaneous/analysis
cd ${targetname}/${analysisfolder}/simultaneous/
ln -s ../xis/spectral_analysis spec_xis
ln -s ../pin/spectral_analysis spec_pin
ln -s ../gso/spectral_analysis spec_gso
ln -s ../xis/lightcurve_analysis lc_xis
ln -s ../pin/lightcurve_analysis lc_pin
ln -s ../gso/lightcurve_analysis lc_gso

ln -s ../xis/image_analysis img_xis

cd - &> /dev/null
