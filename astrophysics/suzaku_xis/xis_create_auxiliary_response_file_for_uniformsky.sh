#!/bin/bash

if [ _$1 = _ ]; then
echo "give xis number (and rmax optional)"
echo "output will be arfs/xisN_uniform_0_20arcmin.arf"
exit -1
fi

n=$1
rmax=20
if [ _$2 != _ ]; then
rmax=$2
fi
num=10000000


arffile=arfs/xis${n}_uniform_0_${rmax}arcmin.arf
evtfile=../data/xis${n}_evt.evt
attfile=`ls ../auxil/ae*.att 2> /dev/null`
rmf=responses/xis${n}.rmf
logfile=logs/xis${n}_uniform_0_${rmax}arcmin.log
obsid=`obs_id.sh $evtfile`

if [ ! -f $evtfile -o ! -f $attfile ]; then
echo "event file or att file is missing..."
exit
fi

#create log file
if [ ! -f $logfile ]; then
 touch $logfile
 if [ ! -f $logfile ]; then
  echo "Creating log file failed..."
  exit
 fi
fi


#extract pi file
tmpdir=`get_hash_random.pl`_xselect
if [ -d $tmpdir -o -f $tmpdir ]; then
tmpdir=`get_hash_random.pl`_xselect
fi
mkdir $tmpdir
tmppi=`get_hash_random.pl`.pi
pushd $tmpdir &> /dev/null
xselect << EOF >> ../$logfile

read e ../$evtfile ./
bin spec
save spec $tmppi
no
exit
no
EOF
popd &> /dev/null
tmppi=$tmpdir/$tmppi

#calculate arf
rm -rf $arffile

ea1=`mean_ea1.sh $evtfile`
ea2=`mean_ea2.sh $evtfile`
ea3=`mean_ea3.sh $evtfile`
regionfile=regions/xis${n}_uniform_0_${rmax}arcmin.reg
aemkreg -xis $ea1 $ea2 $ea3 > $regionfile

#check if area discre is needed for XIS0
if [ $n = 0 ]; then
 yyyy_mm_dd=`date_obs_only_yyyymmdd.sh $evtfile`
 yyyy=`echo "$yyyy_mm_dd" | awk -F"-" '{print $1}'`
 mm=`echo "$yyyy_mm_dd" | awk -F"-" '{print $2}'`
 dd=`echo "$yyyy_mm_dd" | awk -F"-" '{print $3}'`
 yyyymmdd=`calc "$yyyy+$mm/12+$dd/365"`
 yesno=`perl -e "if($yyyymmdd>2009.65){print 'yes';}else{print 'no'}"`
 if [ $yesno = yes ]; then
  echo "Adding Area Discre to region file (creating temporary region file)..."
  tmp_region=`get_hash_random.pl`_region
  cp $regionfile $tmp_region
  tmp_xis_fov=`get_hash_random.pl`_xis_fov
  xis_fov.sh $evtfile > $tmp_xis_fov
  cat $tmp_xis_fov | grep \\-box >> $tmp_region
  regionfile=$tmp_region
  delete_regionfile=yes
  rm -f $tmp_xis_fov
  echo "Adding Area Discre to region file (creating temporary region file)...done"
 fi
fi

echo "Starting xissimarfgen for $obsid"

nice xissimarfgen instrume=XIS${n} pointing=AUTO source_mode=UNIFORM \
  source_rmin=0 source_rmax=$rmax num_region=1 \
  region_mode=SKYREG regfile1=${regionfile} arffile1=${arffile} \
  limit_mode=NUM_PHOTON num_photon=${num} phafile=${tmppi} detmask=none \
  gtifile=${evtfile} \
  attitude=${attfile} \
  rmffile=${rmf} estepfile=medium \
  event_freq=10000000 >> $logfile

rm -rf $tmppi $tmpdir
if [ _$delete_regionfile = _yes ]; then
rm -f $regionfile
fi
