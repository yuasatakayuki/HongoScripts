#!/bin/bash

#20090602 Takayuki Yuasa

if [ _$2 = _ ];
then
echo "usage : pin_fake_cxb_auto.sh (pi file;for response search) (output cxb filename)"
exit
fi

flatresp=`pin_find_flat_responsefile_auto.sh $1`
pin_fake_cxb.sh $flatresp $2
