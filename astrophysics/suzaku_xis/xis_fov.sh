#!/bin/bash

#################################################################
# Read header information from the given FITS header and print  #
# the XIS FoV region file.                                      #
#                                                               #
# [HISTORY]                                                     #
# 2010.03.05 M. Tsujimoto : Coded from scratch.                 # 
# 2010.05.17 M. Tsujimoto : Use fkeyprint instrad of imhead.    # 
#                                                               #
#################################################################


##############################
###    Global variables    ###
##############################
### Global variables
xis_sides=1067.2128 # in arcsec
xis_scale=1.0422    # in arcsec
pi=3.141592

### Commands & options
cat="/bin/cat"
sh="/bin/sh"
#sh="${cat}"     # For debugging purpose.
#
awk="/usr/bin/awk"
#grep="/bin/egrep"
grep=`which egrep`
#sed="/bin/sed"
sed=`which sed`

if [ "${HEADAS}"x = ""x ] ; then
    echo "This script requires HEADAS to be ready."
    exit 1
else
    fkeyprint="${HEADAS}/bin/fkeyprint"
fi


##############################
###      Subroutines       ###
##############################
# Print help
show_help()
{
    ${cat} <<EOF
[USAGE] 
) ${0##*/} FITS_FILE 

EOF
}


##############################
###      Main Routine      ###
##############################
# Check command-line.
if [ $# != 1 ] ; then
    show_help
    exit 1
fi


# Get information.
ra=`${fkeyprint} $1\[0\] RA_NOM exact=yes | ${grep} '^RA_NOM' | ${awk} '{print $3}'`
dec=`${fkeyprint} $1\[0\] DEC_NOM exact=yes | ${grep} '^DEC_NOM' | ${awk} '{print $3}'`
pa=`${fkeyprint} $1\[0\] PA_NOM exact=yes | ${grep} '^PA_NOM' | ${awk} '{print $3}' `
inst=`${fkeyprint} $1\[0\] INSTRUME exact=yes | ${grep} '^INSTRUME' | ${awk} '{print $2}' | ${sed} "s/'//"   `


# Print result.
${cat} <<EOF
global color=magenta
fk5
box(${ra},${dec},${xis_sides}",${xis_sides}",${pa})
EOF

if [ "${inst}"x  = "XIS0"x ] ; then
    ra_ad=`echo ${ra} ${dec} ${pa} ${xis_scale} ${pi} | ${awk} '{printf("%.6f",$1-(512-110)*$4*cos($3*$5/180)/3600/cos($2*$5/180))}'`
    dec_ad=`echo ${ra} ${dec} ${pa} ${xis_scale} ${pi} | ${awk} '{printf("%.6f",$2+(512-110)*$4*sin($3*$5/180)/3600)}'`
    x_ad=`echo 150 70 ${xis_scale} | awk '{print ($1-$2)*$3}'`
    ${cat} <<EOF
-box(${ra_ad},${dec_ad},${x_ad}",${xis_sides}",${pa})
EOF
fi

exit 0
