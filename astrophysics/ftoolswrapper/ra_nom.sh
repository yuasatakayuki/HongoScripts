#!/bin/bash

#20100809 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "ra_nom.sh FILE"
exit
fi

if [ ! -f $1 ]; then
echo "ERROR in ra_nom" 1>&2
exit
fi

i=`fits_has_header_keyword.sh $1 ra_nom`

if [ _$i != _ ]; then
getheader.sh $1 $i RA_NOM
fi
