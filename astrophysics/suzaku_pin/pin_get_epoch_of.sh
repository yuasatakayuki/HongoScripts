#!/bin/bash

#20090305 Takayuki Yuasa
#20100125 Takayuki Yuasa expr substr abandoned
#20100511 Takayuki Yuasa move to ruby

#This script finds appropriate epoch number of the input PIN related file using TSTART value in the first extension header.

if [ _$1 = _ ];
then
echo "usage : pin_find_responsefile_auto.sh (target file; e.g. PIN spectrum file)"
exit
fi

infile=$1

if [ _$CALDB = _ -o ! -d $CALDB ];
then
echo "please set CALDB environmental variable"
echo "also, please check if CALDB is truely located there"
echo "e.g. export CALDB=/net/suzaku/process/caldb/2008-10-20"
exit
fi


#infile no TSTART wo get
tstart=`getheader.sh $infile 0 TSTART`
tstart=`calc $tstart`

#response no CVSD/CVST wo get shite, list wo sakusei
hxdcpf=${CALDB}/data/suzaku/hxd/cpf/
tmpfile=`get_hash_random.pl`
touch $tmpfile

#echo "TSTART $tstart"

for file in `ls $hxdcpf/ae_hxd_pinhxnome*rsp`;
do

D=`getheader.sh $file 1 CVSD0001`
T=`getheader.sh $file 1 CVST0001`
#20100125 modified
#UTC="`expr substr ${D} 1 10`T`expr substr ${T} 1 8`"
UTC="${D:0:10}T${T:0:8}"

missiontime=`suzaku_utc_to_missiontime.sh $UTC`
echo "$file $missiontime" >> $tmpfile

done


ruby << EOF
t=0
finish=false
epoch=1
open("$tmpfile").each {|line|
 a=line.split(" ")
 f=a[0]
 if(f!=nil)then
  e=f.split("_")[-2].split("e")[-1]
  t=a[1].to_f()
  if(t>$tstart and finish==false)then
   epoch=e.to_i()-1
   finish=true
  end
 end
  if(finish==false)then
   epoch=e.to_i()
  end
}

print epoch

EOF


rm -f $tmpfile
rm -f $tmpfile2
