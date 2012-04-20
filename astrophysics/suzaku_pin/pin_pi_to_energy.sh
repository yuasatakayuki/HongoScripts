#!/bin/bash

#20090312 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : pin_pi_to_energy.sh (PI))"
exit
fi

calc "($1)*0.375"
