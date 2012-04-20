#!/bin/bash

#20090306 Takayuki Yuasa

if [ _$3 = _ ];
then
echo "fits_get_maximum_column_rownumber.sh FILE EXTENSION COLUMN"
exit
fi

tmp=`get_hash_random.pl`

fits_dump_columns.sh ${1} ${2} $3 yes > $tmp

perl << EOF
open(FILE,"$tmp");
@file=<FILE>;close FILE;

@a=split(" ",\$file[0]);
\$max=\$a[1];
\$maxrow=\$a[0];

foreach \$line (@file){
 @a=split(" ",\$line);
 if(\$max<\$a[1]){
  \$max=\$a[1];
  \$maxrow=\$a[0];
 }
}

print \$maxrow;
EOF

rm $tmp
