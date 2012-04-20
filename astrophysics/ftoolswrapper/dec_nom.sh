#!/bin/bash

#20100809 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "dec_nom.sh FILE"
exit
fi

i=`fits_has_header_keyword.sh $1 dec_nom`
if [ _$i != _ ]; then
getheader.sh $1 $i DEC_NOM
fi
