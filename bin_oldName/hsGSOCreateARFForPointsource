#!/bin/bash

#20091219 Takayuki Yuasa
#20100115 Takayuki Yuasa copied from pin version

if [ _$5 = _ ];
then
echo "gso_create_auxiliary_response_file_for_pointsource.sh (spectrum file) (attitude file) (target RA) (target Dec) (output directory)"
echo "Output ARF file will be saved as (output directory)/offaxis_gso.arf"
exit
fi

#parameters
infile=$1
attitudefile=$2
ra=$3
dec=$4
outputdir=$5

outputprefix=$outputdir/offaxis
outputfile=${outputprefix}_gso.arf

#execute hxdarfgen
rm -f $outputfile

hxdarfgen \
$outputprefix \
hxd_arf_pinid=65 hxd_arf_gsoid=16 \
hxd_teldef=CALDB \
attitude=$attitudefile \
hxd_arfdb_name=CALDB \
input_pi_name=$infile \
point_ra=$ra point_dec=$dec 

