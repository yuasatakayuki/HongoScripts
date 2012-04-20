#!/bin/bash

#20090305 Takayuki Yuasa
#20090512 Takayuki Yuasa automatic cpd insertion
#20090526 Takayuki Yuasa cpd deleted (xspec no window mode)
#20091219 Takayuki Yuasa for spectral fitting

if [ _$6 = _ ];
then
cat << EOF
usage:
pin_create_xcm_for.sh \\
 (spectrum file) \\
 (nxb file) \\
 (response file) \\
 (arf file or 'none') \\
 (cxb file or 'none') \\
 (output xcm filename)
 
If you have an ARF to be loaded, specify the 
name as the 4th argument, if not, none should
be placed. If you have an CXB file to be 
subtracted from the total spectrum, specify 
the name as the 5th argument, if not, none.

example:
pin_create_xcm_for_spectral_fitting.sh \\
 pis/20090304/pin_evt_bin20.pi \\
 pis/20090304/pin_nxb_times10.pi \\
 /net/xdata/astro/caldb/data/suzaku/hxd/cpf//ae_hxd_pinhxnome4_20080129.rsp \\
 none \\
 cxbs/20090304/cxb.fake \\
 xcm/20090304/load_spectra_for_fitting.xcm \\

EOF
exit
fi

#parameter set
evtpi=$1
nxbpi=$2
response=$3
arf=$4
cxbpi=$5
outputxcm=$6

#xspec nowindow mode
export PGPLOT_TYPE=""

#create xcm
cat << EOF > $outputxcm
data 1 $evtpi
response 1 $response
backgrnd 1 $nxbpi
arf 1 $arf
corfile 1 $cxbpi
cornorm 1 1.
EOF

cat << EOF >> $outputxcm
setplot energy
ignore 1-30:**-12. 50.-**
setplot rebin 5,10,3
plot ldata

puts "\\n\\n===================================\\n|  If plot is not shown, type\\n|  > cpd /xw\\n|  in the XSPEC command line.\\n|  Then plot again.\\n|  > plot ldata\\n===================================\\n\\n"
EOF
