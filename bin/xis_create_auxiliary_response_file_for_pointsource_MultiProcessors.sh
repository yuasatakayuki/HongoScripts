#!/bin/bash

#20091214 Takayuki Yuasa


if [ _$2 = _ ];
then
cat << EOF
xis_create_auxiliary_response_file_for_pointsource_MultiProcessors.sh (region file) (CPU core number) (source RA;optional) (source DEC;optional)
 This script increases the speed of ARF calculation by executing
 xissimarfgen and related commands simultaneously distributing
 processes over multi processors.
 The maximum number of parallelized calculation can be set via
 (CPU core number) argument. 
 We expect nearly linear increase of calculation speed since
 xissimarfgen does much computations with only little disk I/O.
 
 e.g. If you are using 4-core CPU, specify 4 as (CPU core number).
      In this case, 4 threads will be running simultaneously.
      
 note : output arf file name is something link arfs/xisN_(region filename).arf
EOF
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
nofcores=$2

#if ra,dec are given
#if not, null will be passed to xis_create_auxiliary_response_file_for_pointsource.sh
#so that parameters stored in the FITS header will be used.
if [ _$4 != _ ];
then
ra_obj=$3
dec_obj=$4
else
ra_obj=""
dec_obj=""
fi


####################
#functions definition
####################
function showPleaseWaitMessage(){
  echo ""
  echo "waiting $nthreads to be completed..."
  echo " this will take tens of minuites to a few hours depending"
  echo " on the available computation power. please be patient,"
  echo " or you can check how these processes are going,"
  echo " by reviewing realtime execution log by :"
  echo " \"tail -f arfs/xis${n}_`basename $regionfile .reg`.arf.log\""
  echo " in other terminal window."
  echo ""
}
function executeSingleARFCalculation(){
 echo "calculating Auxiliary Response File of XIS$n..."
 xis_create_auxiliary_response_file_for_pointsource.sh $regionfile $n $ra_obj $dec_obj &> /dev/null &
  #dump will not be displayed, but an execution log is automatically
  #saved by xis_create_auxiliary_response_file_for_pointsource.
 nthreads=`expr $nthreads + 1`
 if [ $nthreads = $nofcores -o $n = 3 ];
 then
  showPleaseWaitMessage
  wait
  nthreads=0
 fi 
 echo ""
 n=`expr $n + 1`
}

####################
#execute
####################
#Although XIS2 is not operational in some observations,
#we try to execute xis_create_auxiliary_response_file_for_pointsource.sh
#anyway (if not existing, it will stop automatically).

n=0
nthreads=0

executeSingleARFCalculation
executeSingleARFCalculation
executeSingleARFCalculation
executeSingleARFCalculation

####################
#finalize
####################
cat << EOF
It seems the ARF calculation is done. You will find
resulting ARFs are saved in the arfs/ directory.

It is strongly recommended to check the correctness
of the created ARFs. The simplest way is to display
the raw observed images and the calculated ARF images
using e.g. DS9. 

Check List : 
 (i) Do the centers of point sources (observed and
     simulated ones) coincide?
(ii) Is the simulated point source placed at the
     correct coordinate?
(iii)Does the input coordinate of the point source
     match with ones found at published catalogs?
     (visit SIMBAD http://simbad.u-strasbg.fr/Simbad
      or NED http://nedwww.ipac.caltech.edu/ for e.g.)
EOF
