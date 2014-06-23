#!/bin/bash

if [ _$3 = _ ];
then
echo "fits_dump_columns.sh FILE EXTENSION COLUMN(comma-separated) WITH_ROW_NUMBER(yes/no;optional) ROW_RANGE(optional;e.g. 100-200)"
exit
fi

if [ _$4 = _yes ];
then
showrow=yes
else
showrow=no
fi

if [ _$5 = _ ];
then
rows="-"
else
rows=$5
fi

tmp=`get_hash_random.pl`

fdump ${1}+${2} STDOUT columns=$3 rows=$rows prhead=no showcol=no showunit=no showrow=${showrow} showscale=no align=yes page=no clobber=yes > $tmp
num=`file_linenumber.sh $tmp`
num=`calc $num-2`
tail -$num $tmp 

rm $tmp
