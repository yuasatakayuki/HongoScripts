#!/bin/bash

#20100718 Takayuki Yuasa updated for simultaneous multiple-process execution 
#20110122 Takayuki Yuasa modified to use fkeyprint
#20110124 Takayuki Yuasa branch for string/number

if [ _$3 = _ ];
then
echo "usage getheader.sh file extension keyword"
exit
fi

file=$1
ext=$2
keyword=`ruby -e "print '$3'.downcase"`

if [ ! -f $file ]; then
exit
fi

ruby << EOF
str= '`fkeyprint ${file}+$ext $keyword exact=yes 2>/dev/null | grep "=" | tail -1 | sed -e "s/'//g"`'
if(str.include?("'"))then
	#string
	a=str.split("'")
	print a[1].strip
else
	#number etc
	print str.split("=")[1].split("/")[0].strip
end
EOF