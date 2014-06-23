#!/bin/bash

#20100802 Takayuki Yuasa

if [ _$1 = _ ];then
echo "usage : `basename $0` (depth)"
exit
fi

depth=$1

ruby << EOF
pwd="`pwd`"
array=pwd.split('/')
line=array[-1]
for n in 1...$depth do
line=array[-1-n]+"/"+line
end
print line+"\n"
EOF


