#!/bin/bash

#20090306 Takayuki Yuasa

if [ _$4 = _ ];
then
echo "fits_get_cell_value.sh FILE EXTENSION COLUMN_NAME ROW_NUMBER"
exit
fi

tmp=`get_hash_random.pl`

fdump ${1}+${2} STDOUT columns="$3" rows="$4" prhead=no showcol=no showunit=no showrow=no showscale=no align=yes page=no clobber=yes > $tmp

num=`file_linenumber.sh $tmp`
num=`calc ${num}-2`
tail -$num $tmp 

rm $tmp
