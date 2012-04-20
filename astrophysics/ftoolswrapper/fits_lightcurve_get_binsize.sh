#!/bin/bash

#20090306 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "fits_lightcurve_get_binsize.sh FILE"
exit
fi

tmp=`get_hash_random.pl`

nrows=`getheader.sh $1 1 NAXIS2`
fits_get_cell_value.sh $1 1 TIME `calc $nrows-1`-$nrows > $tmp

perl << EOF
open(FILE,"$tmp");
@file=<FILE>;close FILE;
print \$file[1]-\$file[0];
EOF

rm $tmp
