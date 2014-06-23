#!/bin/bash

#20090408 Takayuki Yuasa

if [ _$1 = _ ];
then

echo "usage : suzaku_fovdsp.sh (suzaku fits file) (target name;optional) (ra of object;optional) (dec of object;optional)"
exit

fi

file=$1
dbFile=$HEADAS/refdata/gnrl_refr_cat_0031.fits.gz

if [ ! -f $dbFile ]; then
echo "INTEGRAL Catalog is not found in $HEADAS/refdata"
echo "Trying to download..."
cd $HEADAS/refdata
wget http://www.isdc.unige.ch/integral/catalog/31/`basename $dbFile`
if [ ! -f `basename $dbFile` ]; then
echo "Download failed..."
exit
fi
cd -
fi

if [ -f $file ];
then
ea1=`mean_ea1.sh $file`
ea2=`mean_ea2.sh $file`
ea3=`mean_ea3.sh $file`

if [ _$4 = _ ];
then
target=`targetname.sh $file`
ra_obj=`ra_obj.sh $file`
dec_obj=`dec_obj.sh $file`
else
target=$2
ra_obj=$3
dec_obj=$4
fi


fovdsp << EOF
Suzaku
$ra_obj
$dec_obj
$target
$ea1
$ea2
$ea3
$dbFile
/none
/xs
EOF

else
echo "file not found...exit"
exit
fi
