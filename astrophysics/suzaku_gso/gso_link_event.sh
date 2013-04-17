#!/bin/bash


#20090304 Shin'ya Yamada
#20090511 Takayuki Yuasa unzipping before reprocess
#20100121 Takayuki Yuasa link to cleaned event fixed according to Shinya Yamada's comment
#20120928 Soki Sakurai modified arguments to aepipeline

if [ _$1 = _ ];
then
echo "gso_link_event.sh PATH_TO_DATA"
echo "e.g. gso_link_event.sh ../../data/403023010"
exit
fi

obsid=`basename $1`

echo gso_link_event_newhdpi.sh : obsid = $obsid

#check CALDB environment variables
#suzaku_check_caldb_variables.sh
#if [ $? != 0 ];
#then
#echo "exit..."
#exit
#fi

mkdir data &> /dev/null

event_cl=$1/hxd/event_cl
event_uf=$1/hxd/event_uf

hxdhk=$1/hxd/hk
auxil=$1/auxil

event_uf_repro=$1/hxd/event_uf_repro

mkdir -p ${event_uf_repro}

ln -sf $event_cl
ln -sf $event_uf
ln -sf $hxdhk hxdhk
ln -sf $auxil
ln -sf ${event_uf_repro}

for dir in event_cl event_uf hxdhk auxil;
do

cd $dir
for file in `ls *gz 2> /dev/null`;
do
echo "unzipping : $file"
gzip -d $file
done
cd - &> /dev/null

done
# reprocess


## link hxdhk files (uf tel. and gti )
cd event_uf
ln -fs ../hk/*.hk .
ln -fs ../hk/*.gti .
ls 
cd ..

#aepipeline indir=event_uf outdir=event_uf_repro steminputs=ae${obsid} entry_stage=1 exit_stage=2 instrument=GSO chatter=3 clobber=yes hxdpi_old=no attitude=./auxil/ae${obsid}.att housekeeping=./auxil/ae${obsid}.hk extended_housekeeping=./auxil/ae${obsid}.ehk makefilter=./auxil/ae${obsid}.mkf orbit=./auxil/ae${obsid}.orb timfile=./auxil/ae${obsid}.tim
currentdir=`pwd`
cd $1/../
aepipeline indir=$obsid outdir=event_uf_repro steminputs=ae${obsid} entry_stage=1 exit_stage=2 instrument=GSO clobber=yes
cd $currentdir

##check if uff_0 exists
#uff_0=`ls event_uf_repro/ae*hxd_0_wel_uf*`
#if [ _${uff_0} = _ ];
#then
#hxd_merge_uff.sh ae*hxd_?_wel_uf*
#fi
#
#HS_extract_cleanGSO.sh
#
#cd - &> /dev/null
#

#link event files
cd data/
rm -f gso_evt.evt pseudo.evt uff.evt

#miss! NG
#ln -sf ../event_cl/*gsono*evt gso_evt.evt

#Good
ln -sf ../event_uf_repro/ae*hxd_0_gsono_cl.evt gso_evt.evt

ln -sf ../event_cl/*pse*evt pseudo.evt
# ln -sf ../event_uf_repro/*hxd_0_wel_uf*evt uff_repro.evt
cd - &> /dev/null

bgd=../../data/bgd
ln -sf $bgd
cd data

rm -f gso_nxb.evt
ln -sf `ls ../bgd/*gsobgd* | tail -1 2> /dev/null` gso_nxb.evt
if [ -f gso_nxb.evt ];
then
echo ""
else
echo "Error : NXB file not found"
fi
cd - &> /dev/null


pushd spectral_analysis &> /dev/null
gso_download_arf.rb
popd &> /dev/null
