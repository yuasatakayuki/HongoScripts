#!/bin/bash

function dumpMessage() {
cat << EOF 1>&2

Note:
Run this script in xis/image_analysis/ folder so that
the program can find needed files automatically (e.g. att file).

EOF
}

#check arguments
if [ _$2 = _ ]; then
name=`basename $0`
cat << EOF 1>&2
usage : $name (xis PI fits file) (output event list fits file name)
EOF
dumpMessage
exit -1
fi

#check folder path
path=`get_folder_path.sh 2`
if [ _$path != _ -a $path = "xis/image_analysis" ]; then
echo ""
else
dumpMessage
exit -1
fi

#set parameters
eventfile=$1
outputfile=$2

xisn=`instrume.sh $eventfile`
ra=`getheader.sh $eventfile 0 RA_NOM`
dec=`getheader.sh $eventfile 0 DEC_NOM`
exposure=10000
ea1=`getheader.sh $eventfile 0 MEAN_EA1`
ea2=`getheader.sh $eventfile 0 MEAN_EA2`
ea3=`getheader.sh $eventfile 0 MEAN_EA3`

#check RMF existence
n=`xis_get_xis_number.sh $eventfile`
rmffile=../spectral_analysis/responses/xis${n}.rmf
if [ ! -f $rmffile ]; then
pushd ../spectral_analysis &> /dev/null
echo "preparing RMF file..." 1>&2
xis_create_response_matrix.sh &> ../spectral_analysis/logs/xis_create_response_matrix.log
popd &> /dev/null
#check RMF again
if [ ! -f $rmffile ]; then
echo "RMF generation failed..." 1>&2
exit -1
else
echo "RMF generation done..."
fi
fi


#check ATT file
attfile=`ls ../auxil/ae*.att 2> /dev/null | tail -1`
if [ _$attfile = _ ]; then
echo "att file is not found" 1>&2
exit -1
fi

#execute
rm -f $outputfile
xissim instrume=$xisn enable_photongen=yes photon_flux=10 flux_emin=1.0 \
flux_emax=10.0 spec_mode=1 image_mode=2 time_mode=0 limit_mode=1 energy=2.45 \
ra=$ra dec=$dec sky_r_min=0 sky_r_max=20 exposure=$exposure \
pointing=AUTO gtifile="${eventfile}[2]" attitude=$attfile \
ea1=$ea1 ea2=$ea2 ea3=$ea3 \
xis_rmffile=$rmffile \
event_freq=10000000 \
outfile=$outputfile phafile=$eventfile

if [ _$outputfile != _ -a -f $outputfile ]; then
echo "Event list '$outputfile' is successfully created." 1>&2
else
echo "Execution failed..." 1>&2
exit -1
fi
