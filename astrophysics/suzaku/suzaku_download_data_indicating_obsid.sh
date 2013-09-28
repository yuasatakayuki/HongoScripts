#!/bin/bash

#20090526 Takayuki Yuasa
#20090528 Takayuki Yuasa version option added

DEFAULT_VERSION=2

if [ _$1 = _ ];
then
echo "usage : suzaku_download_data_indicating_obsid.sh (obsid) (version;optional. default=2)"
exit
fi

if [ _$2 != _ ];
then
version=$2
else
version=$DEFAULT_VERSION
fi

local=./
option="-nv -m --passive-ftp -nH --cut-dirs=3 -P $local"
obsid=$1

wget $option "http://darts.isas.jaxa.jp/pub/suzaku/ver${version}/$obsid/"

