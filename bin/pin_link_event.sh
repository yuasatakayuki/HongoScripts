#!/bin/bash

#20090304 Takayuki Yuasa
#20100730 Takayuki Yuasa creating uff0 is skipped (not necessary any more)

if [ _$1 = _ ];
then
echo "pin_link_event.sh PATH_TO_DATA"
echo "e.g. pin_link_event.sh ../../data/403023010"
exit
fi

currentdir=`pwd`

mkdir data &> /dev/null

event_cl=$1/hxd/event_cl
event_uf=$1/hxd/event_uf
hxdhk=$1/hxd/hk
auxil=$1/auxil

ln -sf $event_cl
ln -sf $event_uf
ln -sf $hxdhk hxdhk
ln -sf $auxil

for dir in event_cl hxdhk auxil;
do

cd $dir
for file in `ls *gz 2> /dev/null`;
do
echo "unzipping : $file"
gzip -fd $file
done
cd - &> /dev/null

done

#link event files
echo "creating links to the event files..."
cd data/
rm -f pin_evt.evt pseudo.evt uff.evt
ln -sf ../event_cl/*pinno*evt pin_evt.evt
ln -sf ../event_cl/*pse*evt pseudo.evt
# ln -sf ../event_uf/*hxd_0_wel_uf*evt uff.evt
cd - &> /dev/null

#searching nxb file
rm -f data/pin_nxb.evt
rm -f bgd
bgd=../../data/bgd
ln -sf $bgd
nxbfile=`ls $bgd/*pinnxb* 2> /dev/null | tail -1`
if [ _$nxbfile = _ ]; then
echo "NXB file not found..."
echo "Automatic download will start..."
pushd $bgd &> /dev/null
nxbdownloadlog=pin_download_nxbs.log
pin_download_nxbs.sh &> $nxbdownloadlog
popd $> /dev/null
nxbfile=`ls $bgd/*pinnxb* 2> /dev/null | tail -1`
 if [ _$nxbfile = _ ]; then
  echo "NXB download failed..."
  echo "check log file '$nxbdownloadlog'..."
  exit
 else
  echo "NXB download done"
 fi
fi

pushd data &> /dev/null
echo "creating link to the nxb file..."
ln -sf ../bgd/`basename $nxbfile` pin_nxb.evt
popd &> /dev/null

echo "pin_link_event.sh done"
