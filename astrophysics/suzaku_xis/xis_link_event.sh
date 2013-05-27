#!/bin/bash

#20090312 Takayuki Yuasa
#20090608 Takayuki Yuasa show progress
#20100708 Takayuki Yuasa merge 2x2 as well

if [ _$1 = _ ];
then
echo "xis_link_event.sh PATH_TO_DATA"
echo "e.g. xis_link_event.sh ../../data/403023010"
exit
fi

mkdir data &> /dev/null

event_cl=$1/xis/event_cl
event_uf=$1/xis/event_uf
xishk=$1/xis/hk
auxil=$1/auxil

logfile=data/xis_link_event.sh.log

ln -sf $event_cl
ln -sf $event_uf
ln -sf $xishk xishk
ln -sf $auxil auxil

for dir in event_cl event_uf xishk auxil;
do

cd $dir
for file in `ls *gz 2> /dev/null`;
do
echo "unzipping : $file"
gzip -d $file
done
cd - &> /dev/null

done

#merge 3x3 and 5x5
for n in 0 1 2 3;
do
rm -f event_cl/ae*xi${n}*_converted_to_3x3.evt
evt5x5=`ls event_cl/ae*xi${n}*5x5*_cl.evt 2> /dev/null | tail -1`
evt3x3=`ls event_cl/ae?????????xi${n}_?_3x3?????_cl.evt 2> /dev/null | tail -1`
evt2x2=`ls event_cl/ae*xi${n}*2x2*_cl.evt 2> /dev/null | tail -1`

#a temp file containing a list of event files (3x3 and 5x5)
tmp=`get_hash_random.pl`

#5x5 mode
if [ _$evt5x5 != _ ];
then
echo "XIS $n 5x5 event was found...convert to 3x3 event file"
evt5x5_to_3x3=event_cl/`basename $evt5x5 .evt`_converted_to_3x3.evt
hkfile=xishk/ae*xi${n}_0.hk
xis5x5to3x3 << EOF 2>&1 | tee -a $logfile
$evt5x5
$evt5x5_to_3x3
`ls $hkfile`
EOF
echo `basename $evt5x5_to_3x3` >> $tmp
fi

#3x3 mode
if [ _$evt3x3 != _ ];
then
#has 3x3, then merge 3x3 and 5x5_converted_to_3x3
echo "XIS $n 3x3 event was found"
echo `basename $evt3x3` >> $tmp
fi

#2x2 mode
if [ _$evt2x2 != _ ];
then
#has 2x2, then merge this as well
echo "XIS $n 2x2 event was found"
echo `basename $evt2x2` >> $tmp
fi

#merge 2x2, 3x3 and 5x5 if needed
#if it is not needed (i.e. only 3x3 or onlu 5x5),
#a symbolic link will be created.
rm -f xis${n}_evt.evt

if [ _$evt5x5 != _ -a _$evt3x3 != _ ];
then
echo "merging 2x2, 3x3 and 5x5 into xis${n}_evt.evt"
cp -f $tmp event_cl/$tmp
cd event_cl

tmp2=`get_hash_random.pl`
xselect << EOF 2>&1 | tee -a $tmp2

no
read event @$tmp ./
extract event
save event xis${n}_evt.evt

exit

EOF
rm -r $tmp
cd - &> /dev/null
cat event_cl/$tmp2 >> $logfile
cd data
ln -sf ../event_cl/xis${n}_evt.evt xis${n}_evt.evt
cd - &> /dev/null

#only 5x5 data, then link
elif [ _$evt5x5 != _ ];then
echo "only 5x5 event file...link it as xis${n}_evt.evt"
cd data
ln -sf ../event_cl/`basename $evt5x5_to_3x3` xis${n}_evt.evt
cd - &> /dev/null

#only 3x3 data, then link
elif [ _$evt3x3 != _ ];then
echo "only 3x3 event file...link it as xis${n}_evt.evt"
cd data
ln -sf ../event_cl/`basename $evt3x3` xis${n}_evt.evt
cd - &> /dev/null

#only 2x2 data, then link
elif [ _$evt2x2 != _ ];then
echo "only 2x2 event file...link it as xis${n}_evt.evt"
cd data
ln -sf ../event_cl/`basename $evt2x2` xis${n}_evt.evt
cd - &> /dev/null

fi

rm -f $tmp event_cl/$tmp2

done

#create fi and bi
cd data
tmp=`get_hash_random.pl`
ls xis0_evt.evt xis2_evt.evt xis3_evt.evt > $tmp 2> /dev/null
xselect << EOF

no
read event @$tmp ./
extract event
save event fi_evt.evt
y
exit


EOF
ln -sf xis1_evt.evt bi_evt.evt
rm -f $tmp
cd - &> /dev/null
