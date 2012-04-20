#!/bin/bash

#20090309 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "ra_obj.sh FILE"
exit
fi


getheader.sh $1 0 RA_OBJ
