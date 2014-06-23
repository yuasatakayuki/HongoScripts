#! /bin/bash

if [ _$1 = _ ];
then
echo "usage $0 FILE"
exit
else

if [ ! -f $1 ];
then
echo "file not found..."
exit
fi

ruby << EOF
nline=0
open("$1").each { |line|
 nline=nline+1
}
print "#{nline}\n"

EOF
fi
