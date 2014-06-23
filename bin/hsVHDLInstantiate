#!/bin/bash

#20100601 Takayuki Yuasa

if [ _$1 = _ ]; then
name=`basename $0`
cat << EOF
usage:
$name (file)

The input file should contain component declaration
or entity declaration of a vhdl module. This script
extract signal names, and then connect them to signals
that have the same names as the entities.
EOF
exit
fi

if [ ! -f $1 ]; then
 echo "file not found...exit"
 exit
fi

file=$1

ruby << EOF
flag=false
signals=[]
connections=[]
componentname=""
open("$file").each {|line|
 head=line.split(" ")[0]
 if(head==nil)then
  next
 end
 if(flag==true and (!head.include?("--")) and (!head.include?(")")) and (!head.include?("end")) )then
  a=line.split(" ")[0].split(":")
  connections.push("#{a[0]} => #{a[0]},")
  line=line.downcase
  line2=line.gsub(":in",": in").gsub(":out",": out")
  b=line2.split(" in ")[-1].split(" out ")[-1]
  if(!b.include?(";"))then
   b[b.length-1,1]=";"
  end
  signals.push("signal #{a[0]} : #{b}")
 end
 if(line.include?("component ") and flag==false)then
  componentname=line.split(" ")[1]
 end
 if(line.include?("entity ") and flag==false)then
  componentname=line.split(" ")[1]
 end
 if(line.include?("port") and line.include?("("))then
  flag=true
 end
}

print_signals=signals.join()
print_connections=connections.join("\n ")
i=print_connections.rindex(",")
print_connections[i,1]=" "

print <<EOS
#{print_signals}

instanceOf#{componentname} : #{componentname}
port map(
 #{print_connections}
);
EOS

EOF
