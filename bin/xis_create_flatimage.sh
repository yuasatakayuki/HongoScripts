#!/bin/bash

binning=8

if [ _$2 = _ -o `get_folder_path.sh 2` != "xis/image_analysis" ]; then
cat << EOF 1>&2
`basename $0` (event file) (tag name) (energy lower in keV;optional) (energy upper in keV;optional)

Please run this script in xis/image_analysis/ folder.

This script creates an exposure-, vignetting-, and NXB-corrected
image from an XIS event file. The output is stored as
flattended_images/(tagname)/xisN_vig_exp_corrected.img
in units of count/s/pixel. The NXB is estimated using
xisnxbgen.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
This script takes several hours to complete due to
a large Monte Carlo simulation performed in xissim.
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Please set XIS_CREATE_FLATIMAGE_SH_REUSE_FILES
environmental variable to "yes" to speed up calculation
using existing files. For example,

export XIS_CREATE_FLATIMAGE_SH_REUSE_FILES=yes
export XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES=yes
export XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM=(path to flatimages/)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

EOF
exit -1
fi

#function
function remove_temporary_files() {
for file in $tmp_flat_eventlist $workdir/$nxbimagedir/$nxblogfile $workdir/$nxbimagedir/$tmp_spec $workdir/$nxbimagedir/$regionfile $workdir/$nxbimagedir/$tmp_nxb_binned $workdir/$sourceimagedir/$tmp_source_in_rate $workdir/$tmp_subtracted $workdir/$tmp_trimmed $workdir/$tmp_vig_corrected; do
if [ _$file != _ -a -f $file ]; then
rm -f $file 2> /dev/null
fi
done

}


#set parameters
eventfile=$1
tagname=$2

if [ _$4 = _ ]; then
elow=0.5
ehigh=10
else
elow=$3
ehigh=$4
fi

if [ _$5 = _ ]; then
extraconditionextracondition=$3
else
extracondition=""
fi

workdir=flattened_images/$tagname/

#convert energy to PI
pilow=`xis_energy_to_pi.sh $elow`
pihigh=`xis_energy_to_pi.sh $ehigh`

#check files
echo "Checking input event file..." 1>&2
if [ ! -f $eventfile ]; then
echo "input event file is not found..." 1>&2
remove_temporary_files
exit -1
else
eventfile=`fullpath $1`
fi
n=`xis_get_xis_number.sh $eventfile`

echo "Checking input event file...done" 1>&2
if [ ! -f $extracondition ]; then
echo "extra condition file is not found..." 1>&2
remove_temporary_files
exit -1
fi


#create log file
logfile=logs/$tagname/`basename $0 ".*"`.log
if [ ! -d logs/$tagname ]; then
mkdir logs/$tagname
fi
if [ ! -f $logfile ]; then
echo "Log file '$logfile' is newly created..." 1>&2
touch $logfile
else
echo "Existing log file '$logile' is used..."
fi

cat << EOF 1>&2

To check the execution status of this script,
please see the log file using "tail -f" command.
Example:
tail -f $logfile

EOF


#create folders
flatimagedir=flatimages
nxbimagedir=nxbimages
exposuremapdir=exposuremaps
sourceimagedir=sourceimages
if [ ! -d $workdir ]; then
mkdir -p $workdir
fi

pushd $workdir &> /dev/null
if [ ! -d $flatimagedir ]; then
mkdir $flatimagedir
fi
if [ ! -d $nxbimagedir ]; then
mkdir $nxbimagedir
fi
if [ ! -d $sourceimagedir ]; then
mkdir $sourceimagedir
fi
if [ ! -d $exposuremapdir ]; then
mkdir $exposuremapdir
fi
popd &> /dev/null



########################################
# Flat image
########################################
flatimage=xis${n}_flat.img
flatnormalized=xis${n}_flat_smoothed_normalized.img

function create_flat_image(){

#create flat image
echo "Creating flat image... (this will take time; several hours!)" 1>&2
tmp_flat_eventlist=`get_hash_random.pl`.evt
xis_create_flatimage_eventlist.sh $eventfile $tmp_flat_eventlist
mv $tmp_flat_eventlist $workdir/$flatimagedir/
echo "Creating flat image... done" 1>&2

pushd $workdir/$flatimagedir &> /dev/null

if [ ! -f $tmp_flat_eventlist ]; then
echo "Flat image event file '$tmp_flat_eventlist' is not found..." 1>&2
echo "Flat image creation failed..." 1>&2
remove_temporary_files
exit -1
fi

rm -f $flatimage
xselect << EOF

no
read event $tmp_flat_eventlist ./
set XYBINSIZE $binning
extract image
save image $flatimage
quit
no
EOF

#smooth then normalize the flat image
flatsmoothed=xis${n}_flat_smoothed.img
sigma=`perl -e "print (16/$binning)"`
rm -f $flatsmoothed
ximage << EOF
read/fits $flatimage
smooth/sigma=$sigma
write_image/fits $flatsmoothed
exit
EOF

max=`fits_get_maximum_pixel_value.sh $flatsmoothed`
max=`perl -e "print int($max)"`
if [ _$max = _0 ]; then
echo "Flat image is zero...exit" 1>&2
remove_temporary_files
exit -1
fi
#exposure=`exposure.sh $eventfile`
#scaling=`ruby -e "print $exposure/$max"`
rm -f $flatnormalized
ximage << EOF
read/fits $flatsmoothed
rescale/divide
$max
write_image/fits $flatnormalized
quit
EOF
popd &> /dev/null

}
########################################


########################################
# Exposure map and trim mask
########################################
exposuremap=xis${n}_expmap.img
binnedexposuremap=xis${n}_expmap_binned.img
trimmask=xis${n}_trim.img

function create_exposuremap_and_trimmap() {
echo "Creating exposure map..."
pushd $workdir/$exposuremapdir &> /dev/null

rm -f $exposuremap
attfile=`ls ../../../../auxil/*att | tail -1`
xisexpmapgen $exposuremap $eventfile $attfile  &> /dev/null

rm -f $binnedexposuremap
fimgbin "$exposuremap[1]" $binnedexposuremap $binning
if [ ! -f $binnedexposuremap ]; then
 echo "Error while creating 'binned exposure map'..."
 exit -1
fi

rm -f $trimmask
exposure=`exposure.sh $eventfile`
thresholdlo=`perl -e "print int(0.8*$exposure*$binning*$binning)"`
thresholdup=`perl -e "print int(0.8*$exposure*$binning*$binning+1)"`
echo "thresholdlo=$thresholdlo"
echo "thresholdup=$thresholdup"
cat << EOF
fimgtrim infile="${binnedexposuremap}[1]" threshlo=$thresholdlo threshup=$thresholdup const_lo=0 const_up=1 outfile=$trimmask
EOF
fimgtrim infile="${binnedexposuremap}[1]" threshlo=$thresholdlo threshup=$thresholdup const_lo=0 const_up=1 outfile=$trimmask
if [ ! -f $trimmask ]; then
echo "Error while creating a trim mask..."
exit
fi

#trim exposure map with trim mask
tmp=`get_hash_random.pl`
farith "${binnedexposuremap}[1]" $trimmask $tmp mul
mv $tmp ${binnedexposuremap}

rm -f $tmp
popd &> /dev/null
}
########################################


########################################
# NXB image
########################################
nxbfile=xis${n}_nxb.pi
nxbimagefile=xis${n}_nxb.img
nxbbinnedimagefile=xis${n}_nxb_binned.img
nxblogfile=`get_hash_random.pl`_nxbgen_log
function create_nxb_image() {
echo "Creating NXB image..."
pushd $workdir/$nxbimagedir &> /dev/null

#create temporary image
tmp_spec=`get_hash_random.pl`.pi
nxb_tmp_speclog=`get_hash_random.pl`_tmp_nxbspec.log
calmask=`xis_find_calmask.sh $eventfile`
xselect << EOF &> $nxb_tmp_speclog

no
read event $eventfile /
filter column "status=0:65535 131072:196607 262144:327679 393216:458751"
extract spec
save spec $tmp_spec
no
exit
no
EOF

if [ ! -f $tmp_spec ]; then
echo "Spectrum file which is need for NXB creation cannot be created..." 1>&2
echo "See log `fullpath $nxb_tmp_speclog`" 1>&2
remove_temporary_files
exit -1
else
rm -f $nxb_tmp_speclog
fi

#xisnxbgen
regionfile=`get_hash_random.pl`.reg
cat << EOF > $regionfile
global color=green width=1 font="helvetica 10 normal" select=1 highlite=1 dash=0 fixed=0 edit=1 move=1 delete=1 include=1 source=1
image
circle(512,512,2000)
EOF

if [ ! -f $regionfile ]; then
echo "Region file which is need for NXB creation cannot be created..." 1>&2
echo "(filename= `fullpath $regionfile`)" 1>&2
remove_temporary_files
exit -1
fi

orbfile=`ls ../../../../auxil/*orb | tail -1`
attfile=`ls ../../../../auxil/*att | tail -1`
touch $nxblogfile
if [ -f $orbfile -a -f $attfile ]; then
xisnxbgen outfile=$nxbfile phafile=$tmp_spec region_mode=SKYREG regfile=$regionfile orbit=$orbfile attitude=$attfile pi_min=$pilow pi_max=$pihigh &> $nxblogfile
else
echo "orb file or att file not found..." 1>&2
remove_temporary_files
exit -1
fi

if [ ! -f $nxbfile ]; then
echo "NXB creation failed..." 1>&2
echo "See log `fullpath $nxblogfile`..." 1>&2
remove_temporary_files
exit -1
else
echo "NXB creation done"
rm -f $nxblogfile
fi

rm -f $nxbimagefile
fextract ${nxbfile}[3] $nxbimagefile

#rebin the nxb image
tmp_nxb_binned=`get_hash_random.pl`.img
fimgbin "${nxbimagefile}[1]" $tmp_nxb_binned $binning

#rescale (to count rate)
exposure=`exposure.sh $nxbfile`
scale=`perl -e "print $exposure*$binning*$binning"`
rm -f $nxbbinnedimagefile
ximage << EOF &> /dev/null
read/fits $tmp_nxb_binned
rescale/divide
$scale
write_image $nxbbinnedimagefile
exit
EOF

popd &> /dev/null
}
########################################


########################################
# Source image
########################################
sourcecountimagefile=xis${n}_source.img
sourceimagefile=xis${n}_source_in_rate.img

function extract_source_image(){
pushd $workdir/$sourceimagedir &> /dev/null
#extract source image
rm -f $sourcecountimagefile
xselect << EOF &> /dev/null

no
read event $eventfile /
filter column "status=0:65535 131072:196607 262144:327679 393216:458751"
filter pha_cut $pilow $pihigh
set xybinsize $binning
extract image
save image $sourcecountimagefile
exit
no
EOF

#to count rate
rm -f $sourceimagefile
tmp_source_in_rate=`get_hash_random.pl`_source_in_rate.img
farith $sourcecountimagefile[0] ../$exposuremapdir/$binnedexposuremap[0] $tmp_source_in_rate DIV
fimgtrim "$tmp_source_in_rate[0]" threshlo=-100 const_lo=0 threshup=100 const_up=0 outfile=$sourceimagefile
popd &> /dev/null
}
########################################


#files
#source   : $sourceimagedir/$sourceimagefile
#nxb      : $nxbimagedir/$nxbbinnedimagefile
#flat     : $flatimagedir/$flatnormalized
#trimmask : $exposuremapdir/$trimmask


########################################
# Subtract NXB then divide with flat
########################################

function flatten_image() {
pushd $workdir &> /dev/null
cat << EOF 1>&2
Flattening the image...
EOF

#check files
cat << EOF 1>&2
Checking needed files...
Source              : $sourceimagedir/$sourceimagefile (in counts/s/binned pixel)
NXB                 : $nxbimagedir/$nxbbinnedimagefile (in counts/s/binned pixel)
Flat and Exposure   : $flatimagedir/$flatnormalized (flat image normalized at the maximum=1)
TrimMask            : $exposuremapdir/$trimmask (contains 0 or 1 for masking) 

EOF

if [ -f $sourceimagedir/$sourceimagefile -a -f $nxbimagedir/$nxbbinnedimagefile -a -f $flatimagedir/$flatnormalized -a -f $exposuremapdir/$trimmask ]; then
echo "All needed files exist..."
else
echo "Needed file is missing..." 1>&2
remove_temporary_files
exit -1
fi

#subtract
tmp_subtracted=`get_hash_random.pl`_sub.img
tmp_vig_corrected=`get_hash_random.pl`_vig_corrected.img
output=xis${n}_flattened.img
rm -f $output
echo "Subtracting NXB..." 1>&2
farith $sourceimagedir/$sourceimagefile[0] $nxbimagedir/$nxbbinnedimagefile[0] $tmp_subtracted SUB
echo "Correcting vignetting..." 1>&2
farith $tmp_subtracted[0] $flatimagedir/$flatnormalized[0] $tmp_vig_corrected DIV
echo "Applying trim mask..." 1>&2
tmp_trimmed=`get_hash_random.pl`_trimmed.img
farith $exposuremapdir/$trimmask[0] $tmp_vig_corrected[0] $tmp_trimmed MUL
fimgtrim "$tmp_trimmed[0]" threshlo=-100 const_lo=0 threshup=100 const_up=0 outfile=$output
output_fullpath=`fullpath $output`
echo "Flattened image was saved as $output_fullpath ..." 1>&2
popd &> /dev/null
}
########################################


########################################
# Main part
########################################

cat << EOF
======================================================
`basename $0` : creates flattened XIS image
======================================================
EOF

#check reuse flag
if [ _$XIS_CREATE_FLATIMAGE_SH_REUSE_FILES != _ ]; then
echo "XIS_CREATE_FLATIMAGE_SH_REUSE_FILES is set."
echo "Existing files are reused..."
fi

if [ _$XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM != _ ]; then
 echo "XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM is set..."
 echo "Checking if flat image is available..."
 if [ -f $XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM/$flatnormalized ]; then
 echo "Checking if flat image is available...found"
  echo "Skipping to create flat image..."
  fullpath=`fullpath $XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM/$flatnormalized`
  flatimagedir=`dirname $fullpath`
 else
  echo "Error flat image is not found in $XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM/ although XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES_FROM is set...exit"
  exit -1
 fi
else
 if [ ! -f $workdir/$flatimagedir/$flatnormalized ]; then
  create_flat_image
 else
  if [ _$XIS_CREATE_FLATIMAGE_SH_REUSE_FLAT_FILES != _ -o _$XIS_CREATE_FLATIMAGE_SH_REUSE_FILES != _ ]; then
   echo "Skipping to create flat image..."
  else
   create_flat_image
  fi
 fi
fi


if [ -f $workdir/$exposuremapdir/$trimmask -a _$XIS_CREATE_FLATIMAGE_SH_REUSE_FILES != _ ]; then
echo "Skipping to create exposure map and trim map..."
else
create_exposuremap_and_trimmap
fi

if [ -f $workdir/$nxbimagedir/$nxbbinnedimagefile -a _$XIS_CREATE_FLATIMAGE_SH_REUSE_FILES != _ ]; then
echo "Skipping to create NXB image..."
else
create_nxb_image
fi


if [ -f $workdir/$sourceimagedir/$sourceimagefile -a _$XIS_CREATE_FLATIMAGE_SH_REUSE_FILES != _ ]; then
echo "Skipping to create source image..."
else
extract_source_image
fi

#final process
flatten_image

#delete temporary files
remove_temporary_files

#message
echo "`basename $0` completed." 1>&2
echo "" 1>&2
