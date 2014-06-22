#!/bin/bash

#20090414 Takayuki Yuasa
#20090526 Takayuki Yuasa cpd deleted (xspec no window mode)
#20090825 Takayuki Yuasa added -f option to rm
#20100126 Takayuki Yuasa exit yes was added

if [ _$2 = _ ];
then
echo "usage : pin_fake_cxb.sh (response file;flat rsp) (output pha file)"
echo "output pha file should have '.fake' suffix."
exit
fi

response=$1
outputpha=$2

if [ ! -f $response ];
then
echo "response file not found...exit"
exit
fi

#xspec nowindow mode
export PGPLOT_TYPE=""

mkdir -p `dirname $outputpha`
rm -f $outputpha

xspec << EOF

model pow*highecut
1.29
9.412e-3
1e-4
40.0
fakeit none
$response
none
y

$outputpha
1000000000

exit
yes
EOF
