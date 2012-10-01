#!/bin/bash

#20090507 S. Yamada
#20121001 S. Sakurai

if [ _$1 = _ ];
then
echo "usage : gso_find_nxbfile.sh (GSO fits file;evt or pi) (quick or tuned)"
echo "if there is no nxb file yet, a string 'none' will be returned."
exit
fi

file=$1


#tunedurl=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsonxb/gsonxb_ver2.4/

#echo "--------------------"
#echo $file 
#ls $file 
#echo "--------------------"
obsid=`getheader.sh $file 0 obs_id`
dateobs=`date_obs.sh $file`

year=`ruby -e "print ARGV[0].split('-')[0]" $dateobs`
month=`ruby -e "print ARGV[0].split('-')[1]" $dateobs`
day=`ruby -e "print ARGV[0].split('-')[2]" $dateobs`

if [ ${year} -lt 2011 ]; then
tunedurl=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsonxb/gsonxb_ver2.5/
elif [ ${year} -gt 2011 ]; then
tunedurl=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsonxb/gsonxb_ver2.6/
elif [ ${month} -lt 11 ]; then
#hereafter year==2011
tunedurl=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsonxb/gsonxb_ver2.5/
elif [ ${month} = 11 && ${day} -lt 4 ]; then
tunedurl=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsonxb/gsonxb_ver2.5/
else
tunedurl=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsonxb/gsonxb_ver2.6/
fi

#echo "searching GSO $type NXB for OBSID:$obsid (${year}-${month})"

echo "$tunedurl/${year}_${month}/ae${obsid}_hxd_gsobgd.evt.gz"
