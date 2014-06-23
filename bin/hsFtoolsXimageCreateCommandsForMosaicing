#!/bin/bash

if [ _$1 = _ ]; then
echo "usage : `basename $0` (size in pixel) (fits image0) (fits image1) ... (fits imageN)" 1>&2
exit -1
fi

sizecommand="/size=$1"
for file in $@; do
if [ -f $file ]; then
cat << EOF
read/fits$sizecommand $file
$sumimagecommand
save_image
EOF
sizecommand=""
sumimagecommand=sum_image
fi
done
cat << EOF
disp
EOF
