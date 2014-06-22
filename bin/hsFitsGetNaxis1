#!/bin/bash

keyword=naxis1

#20100809 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "$keyword.sh FILE"
exit
fi

i=`fits_has_header_keyword.sh $1 $keyword`
if [ _$i != _ ]; then
getheader.sh $1 $i $keyword
fi
