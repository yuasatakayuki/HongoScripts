#!/bin/bash

if [ _$1 = _ ]; then
cat << EOF 1>&2
usage : `basename $0` (fits image file)`

Returns the maximum pixel value of the image.

EOF
exit -1
fi

file=$1
if [ -f $file ]; then
fimgstat $file threshlo=INDEF threshup=INDEF &> /dev/null
pget fimgstat max
else
echo "file not found..." 1>&2
exit
fi
