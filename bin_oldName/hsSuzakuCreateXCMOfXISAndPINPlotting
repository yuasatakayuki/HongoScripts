#!/bin/bash

#20090316 Takayuki Yuasa
#20090512 Takayuki Yuasa automatic cpd insertion
#20090526 Takayuki Yuasa cpd deleted (xspec no window mode)

if [ _${11} = _ ];
then
cat << EOF
suzaku_create_xcm_simultaneous_xis_pin_plot.sh \\
 (XIS event pi file) \\
 (XIS nxb pi file; or none) \\
 (XIS cxb pi file; or none) \\
 (XIS bgd pi file; or none) \\
 (XIS response file) \\
 (XIS auxiliary response file; or none) \\
 (PIN event pi file) \\
 (PIN nxb pi file; or none) \\
 (PIN 5% of nxb file or none) \\
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
xisnxbfile=$2
xiscxbfile=$3
xisbgdfile=$4
xisrmf=$5
xisarf=$6

pinevtfile=$7
pinnxbfile=$8
pinnxbfivepercent=$9
pinrmf=${10}
pinarf=${11}

outputfile=${12}


#xspec nowindow mode
export PGPLOT_TYPE=""

mkdir -p `dirname $outputfile` &> /dev/null

ruby << EOF > $outputfile
#xis part
xisdatacount=0
filearray=%w($xisevtfile $xisnxbfile $xiscxbfile $xisbgdfile)
dataarray=[]
bgdarray=[]
resparray=[]
arfarray=[]
filearray.each { |file|
 if(file!="none")then
  dataarray+=[file]
  bgdarray+=["none"]
  resparray+=["$xisrmf"]
  arfarray+=["$xisarf"]
  xisdatacount+=1
 end
}
dataarray+=["$xisevtfile"]
bgdarray+=["$xisbgdfile"]
resparray+=["$xisrmf"]
arfarray+=["$xisarf"]
xisdatacount+=1

#pin part
pindatacount=0
filearray=%w($pinevtfile $pinnxbfile $pinnxbfivepercent)
filearray.each { |file|
 if(file!="none")then
  dataarray+=[file]
  bgdarray+=["none"]
  resparray+=["$pinrmf"]
  arfarray+=["none"]
  pindatacount+=1
 end
}
dataarray+=["$pinevtfile"]
bgdarray+=["$pinnxbfile"]
resparray+=["$pinrmf"]
arfarray+=["$pinarf"]
pindatacount+=1

print <<EOS 
data #{dataarray.join(' ')}
response #{resparray.join(' ')}
backgrnd #{bgdarray.join(' ')}
arf #{arfarray.join(' ')}

setplot energy
EOS

#xis rebining/ignorin
for n in 1..xisdatacount do
print <<EOS
ignore #{n}:**-0.5 10.-**
setplot rebin 20,20,#{n}
EOS
end
puts ""

#pin rebining/ignorin
for n in (xisdatacount+1)..(xisdatacount+pindatacount) do
print <<EOS
ignore #{n}:**-10. 50.-**
setplot rebin 5,10,#{n}
EOS
end
puts ""

print <<EOS

plot ldata

EOS

EOF


