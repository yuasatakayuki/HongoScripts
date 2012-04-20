#!/bin/bash

#20090304 Takayuki Yuasa

#create suzaku data analysis folder

if [ _$1 = _ ];
then

echo "usage : suzaku_utc_to_missiontime.sh UTC"
echo "e.g. : suzaku_missiontime_to_utc.sh 2009-03-05T13:20:00"
exit

fi

aetimecalc << EOF &> /dev/null
date
$1
EOF

pget aetimecalc mission
