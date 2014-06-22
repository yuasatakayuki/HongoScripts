#!/bin/bash

#20090309 Takayuki Yuasa

#create suzaku data analysis folder

if [ _$1 = _ ];
then

echo "usage : suzaku_mjd_to_utc.sh MJD"
echo "e.g. : suzaku_mjd_to_utc.sh 54573.774539167"
exit

fi

aetimecalc << EOF &> /dev/null
mjd
$1
EOF

pget aetimecalc date
