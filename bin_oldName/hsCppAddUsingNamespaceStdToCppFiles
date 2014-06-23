#!/bin/bash

#20100604 Takayuki Yuasa

if [ _$1 = _ ]; then
echo "give file to be processed...exit"
exit
fi

if [ ! -f $1 ]; then
echo "file not found...exit"
exit
fi

file=$1

backupfile=${file}.before_conversion
cp $file $backupfile

ruby << EOF
index=0
i=0
has_using_namespace_std=false
open("$backupfile").each{|line|
 i=i+1
 if(line.include?("#include "))then
  index=i
 end
 if(line.include?("using namespace std;"))then
  has_using_namespace_std=true
 end
}

f=open("$file","w")

i=0
open("$backupfile").each{|line|
 if(i==index and has_using_namespace_std==false)then
  f.print "using namespace std;\n"
 end
 f.print line
 i=i+1
}

f.close()

EOF
