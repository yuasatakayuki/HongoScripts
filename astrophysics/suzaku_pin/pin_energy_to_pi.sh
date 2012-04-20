#!/bin/bash

#20090312 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : pin_energy_to_pi.sh (energy in keV)"
exit
fi

calc "int($1/0.375)"
