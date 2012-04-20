#!/bin/bash

#20090316 Takayuki Yuasa
#20090512 Takayuki Yuasa automatic cpd insertion
#20090526 Takayuki Yuasa cpd deleted (xspec no window mode)

if [ _${9} = _ ];
then
cat << EOF
suzaku_create_xcm_simultaneous_xis_pin_plot.sh \\
 (XIS event pi file) \\
 (XIS bgd pi file; or none) \\
 (XIS response file) \\
 (XIS auxiliary response file; or none) \\
 (PIN event pi file) \\
 (PIN nxb pi file; or none) \\
 (PIN response file) \\
 (PIN arf file) \\
 (output xcm filename)
EOF
exit
fi

pwd=`pwd`
if [ `basename $pwd` != simultaneous ];
then
echo "please execute this command inside 'analysis/simultaneous' folder"
exit
fi

#parameter set
xisevtfile=$1
xisbgdfile=$2
xisrmf=$3
xisarf=$4

pinevtfile=$5
pinnxbfile=$6
pinrmf=${7}
pinarf=${8}

outputfile=${9}

#xspec nowindow mode
export PGPLOT_TYPE=""


mkdir -p `dirname $outputfile` &> /dev/null

ruby << EOF > $outputfile
#xis part
dataarray=["$xisevtfile"]
bgdarray=["$xisbgdfile"]
resparray=["$xisrmf"]
arfarray=["$xisarf"]

#pin part
dataarray+=["$pinevtfile"]
bgdarray+=["$pinnxbfile"]
resparray+=["$pinrmf"]
arfarray+=["$pinarf"]

datanumber=1
dataarray.each { |line|
 print "data #{datanumber}:#{datanumber} #{line}\n"
 datanumber=datanumber+1
}

print <<EOS 
response #{resparray.join(' ')}
backgrnd #{bgdarray.join(' ')}
arf #{arfarray.join(' ')}

setplot energy
EOS

print <<EOS
ignore 1:**-0.5 9.-**
setplot rebin 10,10,1

ignore 2:**-12. 50.-**
setplot rebin 5,10,2

plot ldata

EOS

EOF


