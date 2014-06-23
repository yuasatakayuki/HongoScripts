#!/bin/bash

#20100809 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "cdelt1.sh FILE"
exit
fi

i=`fits_has_header_keyword.sh $1 cdelt1`
if [ _$i != _ ]; then
getheader.sh $1 $i cdelt1
fi
