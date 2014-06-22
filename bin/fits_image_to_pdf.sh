#!/bin/bash

#20090313 Takayuki Yuasa

if [ _$2 = _ ];
then
echo "fits_image_to_pdf.sh (input fits image file) (output pdf filename) ("radec";optional)"
exit
fi

inputfile=$1
outputfile=$2

if [ _$3 = _radec ];
then
coordinate=fk5
else
coordinate=galactic
fi

tiff=`get_hash_random.pl`.tiff
gif=`get_hash_random.pl`.gif
region=`get_hash_random.pl`.reg

if [ `indexof.pl "$inputfile" "xis"` > -1 ];
then
xis_create_detector_region.sh $inputfile $region
tmp=`get_hash_random.pl`
exposure=`exposure.sh $inputfile`
exposureks=`calc $exposure/1000`
title="XIS `targetname.sh $inputfile` $exposureks"ks
sed -e "s/XIS/$title/g" $region > $tmp
mv $tmp $region
regionoption="-region $region"
else
regionoption=""
fi



ds9 -geometry 500x500+10+10 $inputfile $regionoption \
-view info np -view panner no -view magnifier no \
-view buttons no -width 512 -height 512 \
-zoom to fit -cmap grey -cmap invert yes \
-grid yes -grid system wcs -grid sky $coordinate \
-grid skyformat degrees -grid view grid yes \
-grid view axes numbers yes -grid view axes yes \
-grid type numerics interior -grid type publication \
-height 550 \
-saveimage tiff $tiff -quit

if [ -f $tiff ];
then
convert $tiff $gif
convert $gif $outputfile
fi
rm -f $tiff $gif $region
