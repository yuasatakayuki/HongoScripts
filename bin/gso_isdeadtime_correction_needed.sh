#!/bin/bash

#20090511 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : gso_isdeadtime_correction_needed.sh (gso bgd file)"
echo "returns yes/no which refer is the bgd file should be dead-time corrected." 
echo "this script currently supports LCFIT."
exit
fi

file=$1

method=`getheader.sh $file 1 METHOD`
method=`echo "$method" | sed -e "s/ //g"`

if [ _$method = _ ];
then
echo "no"
exit
fi

ruby << EOF
method="$method"
if(method.include?("LCFIT"))then
print "yes"
else
print "no"
end
EOF
