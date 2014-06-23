#!/bin/bash

#20090315 Takayuki Yuasa
#20090608 Takayuki Yuasa
#20090710 Takayuki Yuasa for more informative log
#20100213 Takayuki Yuasa pixel quality selection is added (pixq_max)
#20100215 Takayuki Yuasa temporary folder name changed
#20100721 Takayuki Yuasa pixel quality selection changed (0:1023 => 0:524287)

if [ _$2 = _ ];
then
echo "xis_create_auxiliary_response_file_for_pointsource.sh (region file) (xis number;0-3) (source RA;optional) (source DEC;optional)"
echo " note : output arf file name is something link arfs/xisN_(region filename).arf"
exit
fi

pwd=`pwd`
indexof=`indexof.pl "$pwd" "xis/spectral_analysis"`
if [ $indexof == -1 ];
then
echo "run this script at analysis/xis/spectral_analysis/ folder."
exit
fi

####################
#parameter set
####################
regionfile=$1
n=$2

evtfile=../data/xis${n}_evt.evt

mkdir -p arfs/ &> /dev/null
arffile=arfs/xis${n}_`basename $regionfile .reg`.arf
rm -f $arffile


attfile=`ls ../auxil/ae*.att 2> /dev/null`
rmf=responses/xis${n}.rmf

#if ra,dec are given
#if not, RA_OBJ,DEC_OBJ in header will be used
if [ _$4 != _ ];
then
ra_obj=$3
dec_obj=$4
else
if [ -f $evtfile ];
then
ra_obj=`ra_obj.sh $evtfile`
dec_obj=`dec_obj.sh $evtfile`
fi
fi

####################
#log start
####################
logfile=${arffile}.log
cat << EOF 2>&1 | tee -a $logfile
######################################
######### new run of arfgen###########
Starts from `dateyymmdd_hhmm`
PWD = `pwd`
XISn = $n
Source Ra,Dec=(${ra_obj},${dec_obj})
######################################
EOF


####################
#check
####################
if [ ! -f $regionfile ];
then
echo "region file ($regionfile) was not found" 2>&1 | tee -a $logfile
exit
fi

if [ ! -f $evtfile ];
then
echo "event file ($evtfile) was not found" 2>&1 | tee -a $logfile
exit
fi

if [ ! -d ../auxil ];
then
echo "../auxil was not found" 2>&1 | tee -a $logfile
exit
fi

if [ _$attfile = _ ];
then
echo "att file was not found" 2>&1 | tee -a $logfile
exit
fi

if [ ! -f $rmf ];
then
echo "rmf ($rmf) was not found" 2>&1 | tee -a $logfile
exit
fi

####################
#execute
####################
#create pha
#execute xselect to avoid possible collision
#in multi core cpu environment.
tmp=`get_hash_random.pl`.pha
tmpdir=tmp/`get_hash_random.pl`
echo "temporary directory is ${tmpdir}"
mkdir -p $tmpdir
pushd $tmpdir
xselect << EOF 2>&1 | tee -a ../../$logfile

no
read event ../../$evtfile ./
extract spec
save spec ../../$tmp
no

exit

EOF
popd
rm -rf $tmpdir


#xis sim arf gen
nice xissimarfgen instrume=XIS${n} pointing=AUTO source_mode=J2000 \
  source_ra=${ra_obj} source_dec=${dec_obj} num_region=1 \
  region_mode=SKYREG regfile1=${regionfile} arffile1=${arffile} \
  limit_mode=MIXED num_photon=500000 phafile=${tmp} detmask=none \
  accuracy=0.005 \
  gtifile=${evtfile} \
  attitude=${attfile} \
  rmffile=${rmf} estepfile=medium \
  event_freq=1000000 \
  enable_pixq=yes pixq_max=524287 2>&1 | tee -a $logfile

rm -f $tmp

dateyymmdd_hhmm 2>&1 | tee -a $logfile
echo "######### end run ###########" 2>&1 | tee -a $logfile
