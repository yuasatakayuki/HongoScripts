#!/bin/bash

#20090403 Takayuki Yuasa

if [ _$2 = _ ];
then
echo "usage : pin_find_nxbfile.sh (PIN fits file;evt or pi) (quick or tuned)"
echo "if there is no nxb file yet, a string 'none' will be returned."
exit
fi

file=$1
type=$2

quickurl=http://www.astro.isas.ac.jp/suzaku/analysis/hxd/pinnxb/pinnxb_ver2.0/
tunedurl=http://www.astro.isas.ac.jp/suzaku/analysis/hxd/pinnxb/pinnxb_ver2.0_tuned/

obsid=`getheader.sh $file 0 obs_id`
dateobs=`date_obs.sh $file`

year=`ruby -e "print ARGV[0].split('-')[0]" $dateobs`
month=`ruby -e "print ARGV[0].split('-')[1]" $dateobs`

#echo "searching PIN $type NXB for OBSID:$obsid (${year}-${month})"

if [ $type = quick ];
then
echo "$quickurl/${year}_${month}/ae${obsid}hxd_pinnxb_cl.evt.gz"
exit
fi

if [ $type = tuned ];
then
echo "$tunedurl/${year}_${month}/ae${obsid}_hxd_pinbgd.evt.gz"
exit
fi

echo "none"
