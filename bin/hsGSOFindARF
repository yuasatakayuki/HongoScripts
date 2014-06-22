#!/bin/bash

#20090511 S. Yamada

#This script finds appropriate response
#file for a PIN spectrum from CALDB automatically.

if [ _$1 = _ ];
then
echo "usage : gso_find_arffile_auto.sh (target file; e.g. GSO spectrum file)"
exit
fi

infile=$1

nominal=`getheader.sh $1 0 NOM_PNT`

if [ _$nominal = _'HXD' ];
then
nom=hxnom
else
nom=xinom
fi


response=./arfs/ae_hxd_gso${nom}_crab_20070502.arf

if [ ! -f $response ];
then
echo "No response file was found, start download..."
url=http://www.astro.isas.jaxa.jp/suzaku/analysis/hxd/gsoarf/arf/ae_hxd_gso${nom}_crab_20070502.arf
wget $url
mv ae_hxd_gso${nom}_crab_20070502.arf arfs/
fi

echo $response
