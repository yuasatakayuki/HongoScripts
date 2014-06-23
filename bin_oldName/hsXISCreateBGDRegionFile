#!/bin/bash

#20090313 Takayuki Yuasa
#20090706 Takayuki Yuasa copied from xis_create_region_file_for.sh

if [ _$2 = _ ];
then
echo "xis_create_bgd_region_file_for.sh (input fits file) (output region filename) (inner radius in arcsec;optional, default=180) (outer radius;option, default=270)"
exit
fi

inputfile=$1
outputfile=$2

mkdir `dirname $outputfile` &> /dev/null

if [ _$3 = _ ];
then
r_in=180
else
r_in=$3
fi

if [ _$4 = _ ];
then
r_out=270
else
r_out=$4
fi


tmp=`get_hash_random.pl`

ra=`ra_obj.sh $inputfile`
dec=`dec_obj.sh $inputfile`

cat << EOF > $tmp
# Region file format: DS9 version 4.0
# Filename: FILENAME
global color=green font="helvetica 10 normal" select=1 highlite=1 edit=1 move=1 delete=1 include=1 fixed=0 source
fk5
annulus(${ra},${dec},${r_in}",${r_out}")
EOF

mv $tmp $outputfile
