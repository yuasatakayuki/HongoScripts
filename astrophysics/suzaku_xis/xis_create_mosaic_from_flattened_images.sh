#!/bin/bash

#20100803 Takayuki Yuasa

if [ _$1 = _ ]; then
cat << EOF 1>&2
usage : `basename $0` (output folder name) (analysis folder1) (tag of flattened image1) ... (analysis folderN) (tag of flattened imageN)
 output folder name : the folder where output should be saved
 analysis folder? : folder name of the analysis folder containing flattened images
 tag of flattened image? : tag of the flattened image

example : `basename $0` mosaic 502002010 cleanedevent 502003010 cleanedevent

This script creates a mosaic image of the XIS data of
multiple observations. Each image should be created
using xis_create_flatimage.sh in HongoScript style
analysis folders (e.g. target/analysis/xis/image_analysis/flattened_images/).

EOF
exit -1
fi

#temporary file
tmp_folderlist=`get_hash_random.pl`

#construct script
ruby << EOF
require "fileutils"
line="$@"
array=line.split(" ")
if((array.length-1)%2!=0)then
exit -1
end

outputfolder=array[0]

if(!FileTest.exist?(outputfolder))then
print "Output folder was newly created...\n"
FileUtils.mkdir(outputfolder)
end

i=1
file=File.open("$tmp_folderlist","w")

while i<array.length do
name=array[i]
tag=array[i+1]
i=i+2

file.puts "#{name}/analysis/xis/image_analysis/flattened_images/#{tag}/\n"

end

file.close
EOF


#function
function deleteTemporaryFilesThenExit() {
for file in $tmp_folderlist $tmp_sources $tmp_nxbs $tmp_flats $tmp_expmaps $tmp_trims $tmp0 $tmp1 $tmp2 $tmp3 $tmp4 $tmp5 $tmp6 $tmp_sources_count $mosaiclist; do
if [ -f $file ]; then
rm -f $file
fi
if [ -f ${file}_mosaic_command ]; then
rm -f ${file}_mosaic_command
fi
done
echo "Exitting..."
exit -1
}

#check output script
if [ ! -f $tmp_folderlist ]; then
echo "Argument number error..." 1>&2
echo "Please see help invoking `basename $0` with no argument." 1>&2
deleteTemporaryFilesThenExit
fi

outputfolder=$1

#search files
echo "Searching files to be used to create a mosaic image..."
tmp_sources=`get_hash_random.pl`_sources
tmp_nxbs=`get_hash_random.pl`_nxbs
tmp_flats=`get_hash_random.pl`_flats
tmp_expmaps=`get_hash_random.pl`_expmaps
tmp_trims=`get_hash_random.pl`_trims
touch $tmp_sources $tmp_nxbs $tmp_flats $tmp_expmaps $tmp_trims
for path in `cat $tmp_folderlist`; do
ls $path/xis?_flattened.img 2> /dev/null >> $tmp_sources
ls $path/nxbimages/xis?_nxb_binned.img 2> /dev/null >> $tmp_nxbs
ls $path/flatimages/xis?_flat_smoothed_normalized.img 2> /dev/null >> $tmp_flats
ls $path/exposuremaps/xis?_expmap_binned.img 2> /dev/null >> $tmp_expmaps
ls $path/exposuremaps/xis?_trim.img 2> /dev/null >> $tmp_trims
done

echo "Validating files..."
for file in $tmp_sources $tmp_nxbs $tmp_expmaps $tmp_trims;do
if [ `file_linenumber.sh $file` = 0 ]; then
if [ $file = $tmp_sources ]; then
echo "Source file is missing..."
fi
if [ $file = $tmp_nxbs ]; then
echo "NXB file is missing..."
fi
if [ $file = $tmp_expmap ]; then
echo "Exposure map file is missing..."
fi
if [ $file = $tmp_trims ]; then
echo "Trimming mask file is missing..."
fi
deleteTemporaryFilesThenExit
fi
done


#calculate mosaic size
echo "Automatically calculating the mosaic size..."
sourcelist=`cat $tmp_sources`
mosaicsizeandcenter=`xis_calculate_mosaic_image_size.rb $sourcelist`
mosaicsize=`echo "$mosaicsizeandcenter" | awk '{print \$1}'`
mosaiccenter=`echo "$mosaicsizeandcenter" | awk '{print \$2}'`
echo "Mosaic size is $mosaicsize"
echo "Mosaic center is $mosaiccenter"

#list of mosaic images
mosaiclist=`get_hash_random.pl`_mosaiclist
touch $mosaiclist

#create folder
relatedfilefolder=$outputfolder/realted
if [ ! -d $relatedfilefolder ]; then
mkdir -p $relatedfilefolder
fi

#create source mosaics (in counts/binned pixel)
tmp_sources_count=`get_hash_random.pl`_sources_count
touch $tmp_sources_count
i=0
centerimage=""
for file in `cat $tmp_sources`;do
echo "File:$file"
exposure=`exposure.sh $file`
echo "Exposure:$exposure"
naxis1=`getheader.sh $file 0 naxis1`
echo "NAXIS1=$naxis1"
binning=`calc "1536/$naxis1"`
echo "Binning:$binning"
scaling=`perl -e "print $exposure*$binning*$binning"`
echo "Scaling:$scaling"
tmp=`get_hash_random.pl`.img
echo "Processing $file"
i=`calc $i+1`
ximage << EOF &> /dev/null &
read/fits $file
rescale/multiply
$scaling
save_image
write_image/fits $relatedfilefolder/$tmp
exit
EOF
if [ $mosaiccenter = $file ]; then
 centerimage=$relatedfilefolder/$tmp
else
 echo $relatedfilefolder/$tmp >> $tmp_sources_count
fi
if [ $i = 2 ]; then
wait
i=0
fi
done

wait

#find center expmap and trim mask
mosaiccenter_fullpath=`fullpath $mosaiccenter`
mosaiccenter_dirname=`dirname $mosaiccenter_fullpath`
expmapcenter=`ls $mosaiccenter_dirname/exposuremaps/xis?_expmap_binned.img 2> /dev/null | tail -1`
if [ _$expmapcenter = _ ]; then
echo "Exposure map file for the center image is missing..." 1>&2
deleteTemporaryFilesThenExit
else
expmapcenter=`fullpath $expmapcenter`
fi
tmp=`get_hash_random.pl`
echo $expmapcenter > $tmp
for file in `cat $tmp_expmaps`; do
if [ `fullpath $file` != $expmapcenter ]; then
echo $file >> $tmp
fi
done
mv $tmp $tmp_expmaps

trimcenter=`ls $mosaiccenter_dirname/exposuremaps/xis?_trim.img 2> /dev/null | tail -1`
if [ _$trimcenter = _ ]; then
echo "Trim mask file for the center image is missing..." 1>&2
deleteTemporaryFilesThenExit
else
trimcenter=`fullpath $trimcenter`
fi
tmp=`get_hash_random.pl`
echo $trimcenter > $tmp
for file in `cat $tmp_trims`; do
if [ `fullpath $file` != $trimcenter ]; then
echo $file >> $tmp
fi
done
mv $tmp $tmp_trims


#create source mosaic
commandfile=${tmp_sources_count}_mosaic_command
mosaic=${tmp_sources_count}_mosaic.img
ximage_create_commands_for_mosaic.sh $mosaicsize $centerimage `cat $tmp_sources_count` | sed -e "s/^disp//g" > $commandfile
cat << EOF >> $commandfile
write_image/fits $mosaic
exit
EOF
echo "Creating a mosaic of source images..."
ximage < $commandfile &> /dev/null &
echo "$mosaic" >> $mosaiclist


#create exposure map mosaic
for file in $tmp_expmaps $tmp_trims; do
 commandfile=${file}_mosaic_command
 mosaic=${file}_mosaic.img
 ximage_create_commands_for_mosaic.sh $mosaicsize `cat $file` | sed -e "s/^disp//g" > $commandfile
# if [ _`echo "$file" | grep expmap` != _ ]; then
#  tmp=`get_hash_random.pl`
#  sed -e 's/.img$/.img\+1/g' $commandfile > $tmp
#  mv $tmp $commandfile
# fi
 cat << EOF >> $commandfile
write_image/fits $mosaic
exit
EOF
 echo "Creating a mosaic of `echo $file | awk -F_ '{print \$3}'`..."
 ximage < $commandfile &> /dev/null &
 echo "$mosaic" >> $mosaiclist
done

wait

#delete temporary files
for file in `cat $tmp_sources_count`; do
rm -f $file
done


#check outputs
for file in `cat $mosaiclist`; do
if [ ! -f $file ]; then
echo "Creating individual mosaics failed..." 1>&2
echo "($file was not found...)" 1>&2
deleteTemporaryFilesThenExit
fi
done
echo "Creating individual mosaics done..."


#move files into output
for type in sources expmaps trims; do
tmpfile=`grep $type $mosaiclist | tail -1`
if [ ! -f $tmpfile ]; then
echo "Creating a mosaic failed..." 1>&2
deleteTemporaryFilesThenExit
fi
mv $tmpfile $relatedfilefolder/${type}.img
done


#correct exposure
pushd $relatedfilefolder &> /dev/null
tmp0=`get_hash_random.pl`_tmp0
tmp1=`get_hash_random.pl`_tmp1
tmp2=`get_hash_random.pl`_tmp2
tmp3=`get_hash_random.pl`_tmp3
tmp4=`get_hash_random.pl`_tmp4
tmp5=`get_hash_random.pl`_tmp5
tmp6=`get_hash_random.pl`_tmp6
echo "Correcting exposure..."
farith sources.img[0] expmaps.img[0] $tmp0 DIV
fimgtrim "$tmp0" threshlo=-100 const_lo=0 threshup=100 const_up=0 outfile=$tmp1 > /dev/null
echo "Trimming the sharp edges..."
fimgtrim "trims.img[0]" threshlo=0 const_lo=0 threshup=1 const_up=1 outfile=$tmp2 > /dev/null
farith $tmp1[0] $tmp2 $tmp3 MUL
mv $tmp2 trims.img
fimgtrim "$tmp3[0]" threshlo=-100 const_lo=0 threshup=100 const_up=0 outfile=$tmp4 > /dev/null
if [ ! -f $tmp4 ]; then
echo "Constructing a mosaic failed..." 1>&2
deleteTemporaryFilesThenExit
else
echo "Completed!"
fi
mv $tmp4 ../mosaic.img 
rm -f $tmp1 $tmp2 $tmp3 $tmp4 $tmp5
popd &> /dev/null

#delete temporary file
deleteTemporaryFilesThenExit
