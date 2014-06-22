#!/bin/bash

#20090316 Takayuki Yuasa
#20090526 Takayuki Yuasa cpd deleted (xspec no window mode)

if [ _$7 = _ ];
then
cat << EOF
xis_create_xcm_for.sh \\
 (event pi file) \\
 (nxb pi file; or none) \\
 (cxb pi file; or none) \\
 (bgd pi file; or none) \\
 (response file) \\
 (auxiliary response file; or none) \\
 (output xcm filename)
EOF
exit
fi


#parameter set
evtfile=$1
nxbfile=$2
cxbfile=$3
bgdfile=$4
rmf=$5
arf=$6
outputfile=$7

#xspec nowindow mode
export PGPLOT_TYPE=""

mkdir -p `dirname $outputfile`

ruby << EOF > $outputfile
filearray=%w($evtfile $nxbfile $cxbfile $bgdfile)
dataarray=[]
bgdarray=[]
resparray=[]
arfarray=[]
filearray.each { |file|
 if(file!="none")then
  dataarray+=[file]
  bgdarray+=["none"]
  resparray+=["$rmf"]
  arfarray+=["$arf"]
 end
}
dataarray+=["$evtfile"]
bgdarray+=["$bgdfile"]
resparray+=["$rmf"]
arfarray+=["$arf"]

print <<EOS 
data #{dataarray.join(' ')}
response #{resparray.join(' ')}
backgrnd #{bgdarray.join(' ')}
arf #{arfarray.join(' ')}

setplot energy
ignore 1-30:**-0.5 10.-**
setplot rebin 10,10

plot ldata

EOS

EOF


