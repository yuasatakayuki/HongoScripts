#!/bin/bash

#20090902 Takayuki Yuasa
#20090903 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "qdp_sanitize_filename.sh (file name string to be sanitized)"
exit
fi

filename=$1


ruby << EOF
str="$filename"
array=str.split(".")

size=array.length

if(size==1)then
 print str
 exit
end

if(size==2 && (array[size-1]!="pco" && array[size-1]!="qpd"))then
 print "#{array[0]}_#{array[1]}"
 exit
end

#if(size==2)then
# print "#{array[0]}_#{array[1]}"
#end

for i in 0...(array.length-2)
 print "#{array[i]}_"
end
if(array[size-1]!="pco" && array[size-1]!="qpd")then
 #not qdp suffix. so all dots should be removed
 print "#{array[array.length-2]}_#{array[array.length-1]}"
else
 #qdp's suffix. so the last block should be connected with a dot
 print "#{array[array.length-2]}.#{array[array.length-1]}"
end

EOF
