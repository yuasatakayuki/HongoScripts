#!/bin/bash

#20100602 Takayuki Yuasa

if [ _$1 = _ ]; then
name=`basename $0`
cat << EOF
usage:
$name (file) (variable type;optional)

example:
$name signals.vhdl "unsigned char"

The input file should contain declarations of constant signals.
This script outputs C++ style declaration converted from the input.

Type of variables in the output can be provided via the second arg.
The default type is "unsigned int".
EOF
exit
fi

if [ ! -f $1 ]; then
 echo "file not found...exit"
 exit
fi

file=$1

if [ _$2 = _ ]; then
 type="unsigned int"
else
 type=$2
fi

ruby << EOF
open("$file").each{|line|
 line.chomp!
 a=line.split(" ")
 if(a[1]==nil)then
  next
 end
 name=a[1].gsub(" ","").gsub(/\t/,"")
 b=line.split(":=")
 if(b[-1]==nil)then
  next
 end
 init_val=b[-1].gsub(";","")
 init_val.downcase!
 if(init_val.include?('x"'))then
  init_val="0x"+init_val.gsub('x"',"").gsub('"',"").gsub(" ","").gsub(/\t/,"")
 end
 if(name!="" and init_val!="")then
  print "static const $type #{name} = #{init_val};\n"
 end
}

EOF
