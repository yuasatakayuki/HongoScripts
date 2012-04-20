#!/bin/bash

#20090309 Takayuki Yuasa
#20100310 Takayuki Yuasa

if [ _$1 = _ ];
then
echo "nom_pnt.sh FILE"
exit
fi


getheader.sh $1 0 NOM_PNT
