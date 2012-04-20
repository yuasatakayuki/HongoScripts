#!/bin/bash

#20090304 Takayuki Yuasa

#pin_merge_gtis.sh "infile1+2" "infile2+2" outfile 

if [ _$3 = _ ];
then
echo "usage : pin_merge_gtis.sh \"infile1+2\" \"infile2+2\" outfile"
exit
fi

mgtime ingtis="$1,$2" outgti="!$3" merge="AND" 

#log
cat << EOF > ${3}.log
current directory = `pwd`
mgtime ingtis="$1,$2" outgti="$3" merge="AND"
EOF
