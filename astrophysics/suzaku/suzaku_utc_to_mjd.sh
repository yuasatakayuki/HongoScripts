#!/bin/bash

#20090309 Takayuki Yuasa

#create suzaku data analysis folder

if [ _$1 = _ ];
then

echo "usage : suzaku_utc_to_mjd.sh UTC"
echo "e.g. : suzaku_utc_to_mjd.sh 2009-03-05T13:20:00"
exit

fi

aetimecalc << EOF &> /dev/null
date
$1
EOF

pget aetimecalc mjd
