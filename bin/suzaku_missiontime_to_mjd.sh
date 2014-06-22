#!/bin/bash

#20090309 Takayuki Yuasa

#create suzaku data analysis folder

if [ _$1 = _ ];
then

echo "usage : suzaku_missiontime_to_mjd.sh SUZAKU_MISSION_TIME"
echo "e.g. : suzaku_missiontime_to_mjd.sh 261772624.392920"
exit

fi

aetimecalc mission $1 &> /dev/null
echo `pget aetimecalc mjd`
