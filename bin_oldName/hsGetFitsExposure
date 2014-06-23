#!/bin/bash

#20090522 Takayuki Yuasa updated

if [ _$1 = _ ];
then
echo "exposure.sh FILE (value)"
exit
fi

file=$1
tmp=`get_hash_random.pl`.fits
ln -s $file $tmp

if [ _$2 = _ ];
then

i=`fits_has_header_keyword.sh $tmp EXPOSURE`

if [ _$i != _ ]; then
getheader.sh $tmp $i exposure
fi

else

setheader.sh $tmp 0 exposure $2
setheader.sh $tmp 1 exposure $2
setheader.sh $tmp 2 exposure $2

fi


rm -r $tmp
