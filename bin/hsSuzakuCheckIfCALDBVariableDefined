#!/bin/bash

#20100125 Takayuki Yuasa

#check CALDB environment variable
if [ _$CALDB = _ -o ! -d $CALDB ];
then
echo "please set CALDB environmental variable"
echo "also, please check if CALDB is truely located there"
echo "e.g. export CALDB=/net/suzaku/process/caldb/2008-10-20"
echo ""
echo "See How to Install a Calibration Database offered by NASA/GSFC for detail"
echo "at http://heasarc.gsfc.nasa.gov/docs/heasarc/caldb/caldb_install.html"
exit -1
fi

#check CALDBCONFIG environment variable
if [ _$CALDBCONFIG = _ -o ! -f $CALDBCONFIG ];
then
echo "please set CALDBCONFIG environment variable"
echo "also, please check if CALDBCONFIG file is truely loated there"
echo "e.g. export CALDBCONFIG=$CALDB/software/tools/caldb.config"
echo ""
echo "See How to Install a Calibration Database offered by NASA/GSFC for detail"
echo "at http://heasarc.gsfc.nasa.gov/docs/heasarc/caldb/caldb_install.html"
exit -1
fi

#check CALDBALIAS environment variable
if [ _$CALDALIAS = _ -o ! -f $CALDBALIAS ];
then
echo "please set CALDBALIAS environment variable"
echo "also, please check if CALDBCONFIG file is truely loated there"
echo "e.g. export CALDBALIAS=$CALDB/software/tools/alias_config.fits"
echo ""
echo "See How to Install a Calibration Database offered by NASA/GSFC for detail"
echo "at http://heasarc.gsfc.nasa.gov/docs/heasarc/caldb/caldb_install.html"
exit -1
fi

