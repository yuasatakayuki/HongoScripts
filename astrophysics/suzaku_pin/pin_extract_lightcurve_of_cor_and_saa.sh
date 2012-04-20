#!/bin/bash

#20090306 Takayuki Yuasa

#pin_extract_lightcurve_of_cor_and_saa.sh

if [ _$2 = _ ];
then
cat << EOF
usage :
pin_extract_lightcurve_of_cor_and_saa.sh (EHK file) (output filename prefix)

note : output files will be created like (output file prefix)_cor.lc and (output file prefix)_saa.lc
EOF
exit
fi

################################
#parameter set
################################
ehkfile=$1
outputprefix=$2

################################
#execution
################################
corlc=${outputprefix}_cor.lc
fcurve infile=$ehkfile gtifile="none" outfile="$corlc" timecol="TIME" columns="COR" binsz=100 lowval=INDEF highval=INDEF binmode="Rate" clobber=yes

saalc=${outputprefix}_saa.lc
fcurve infile=$ehkfile gtifile="none" outfile="$saalc" timecol="TIME" columns="SAA_HXD" binsz=100 lowval=INDEF highval=INDEF binmode="Rate" clobber=yes

################################
#log
################################
