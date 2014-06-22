#!/bin/bash

#20090403 Takayuki Yuasa

pwd=`pwd`
dir=`basename $pwd`
if [ $dir != bgd ];
then
echo "please run this script in bgd folder."
exit
fi

mkdir quick tuned 2> /dev/null

pinevtfile=`ls ../?????????/hxd/event_cl/ae*hxd_?_pinno_cl.evt ../?????????/hxd/event_cl/ae*hxd_?_pinno_cl.evt.gz 2> /dev/null | tail -1 `

if [ _$pinevtfile = _ ];
then
echo "PIN cleaned event file was not found!, exiting..."
exit
else
echo "found $pinevtfile"
fi


cd quick
wget -nv `pin_find_nxbfile.sh ../$pinevtfile quick`
gzip -d -f *.gz
cd -

cd tuned
wget -nv `pin_find_nxbfile.sh ../$pinevtfile tuned`
gzip -d -f *.gz
cd -


quicknxbpath=`ls quick/* | head -1`

if [ _`ls tuned/* 2> /dev/null | tail -1` != _ ];
then
#has tuned
ln -sf `ls tuned/*` `basename $quicknxbpath`
else
ln -sf `ls quick/* | head -1`
fi
