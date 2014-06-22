#!/bin/bash

#20090609 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : pin_check_nxb_version.sh (nxb file to be checked)"
cat << EOF
Returned values are:
 QuickNXB     : quick NXB
 TunedNXB     : tuned NXB
 NotAnNXBFile : when file is not an nxb file
EOF
exit
fi

file=$1

#check if the file exsits
if [ ! -f $file ];
then
echo "file not found...exit"
exit
fi

#TYPE    METHOD        METHODV
#quick   PINUDLCUNIT   2.0preYYYYMMDD
#tuned   LCFITDT       2.0verYYMM

method=`getheader.sh $file 1 method | awk '{print $1}'`
methodv=`getheader.sh $file 1 methodv`

#echo $method

if [ _$method = _PINUDLCUNIT ];
then
echo "QuickNXB"
exit
fi

if [ _$method = _LCFITDT ];
then
echo "TunedNXB"
exit
fi

echo "NotAnNXBFile"
exit
