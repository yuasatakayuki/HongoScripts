#!/bin/bash

#20090311 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "usage : hxd_merge_uff.sh (uff file1) (uff file2) ..."
echo "output would be ae?????????_hxd_0_wel_uf.evt"
exit
fi

log=hxd_merge_uff.sh.log
tmp=`get_hash_random.pl`
touch $tmp
for file in $@;
do
echo "$file" >> $tmp
done

echo "########`dateyymmdd_hhmm`#########" >> $log

outfilename=`echo "$1" | sed -e "s/hxd_.*.evt//g"`hxd_0_wel_uf.evt

xselect << EOF 2>&1 | tee -a $log

no
read event @$tmp ./

extract event
save event $outfilename

exit

EOF

rm $tmp
