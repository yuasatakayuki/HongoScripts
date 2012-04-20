#!/bin/bash

#20090315 Takayuki Yuasa

echo "create Response Matrix File for XIS0-3 and FI/BI using xisrmfgen"

outputdir=responses

pwd=`pwd`
indexof=`indexof.pl "$pwd" "xis/spectral_analysis"`
if [ $indexof == -1 ];
then
echo "run this script at analysis/xis/spectral_analysis/ folder."
exit
fi

if [ ! -d $outputdir ];
then
echo "error: output folder 'responses/' not found"
exit
fi

logfile=$outputdir/xis_create_response_matrix.sh.log

tmp=`get_hash_random.pl`.pha


##################################
#xis0-3 and BI
##################################
for xis in xis0 xis1 xis2 xis3 bi;
do
evtfile=../data/${xis}_evt.evt

if [ -f $evtfile ];
then
xselect << EOF 2>&1 | tee -a $logfile

no
read event $evtfile ./
extract spec
save spec $tmp
no

exit

EOF

xisrmfgen phafile=$tmp outfile=responses/${xis}.rmf clobber=yes
rm -f $tmp

fi
done


##################################
#FI
##################################
cd $outputdir
tmp=`get_hash_random.pl`
ls xis0.rmf xis2.rmf xis3.rmf 1> $tmp 2> /dev/null
num=`file_linenumber.sh $tmp`
#FI file check
if [ _$num = _ ];
then
echo "Error in FI response creation"
exit
fi

#condition
if [ _$num = _3 ];
then
echo "3 FI chips"
weights="0.333,0.333,0.333"
fi

if [ _$num = _2 ];
then
echo "2 FI chips"
weights="0.5,0.5"
fi

if [ _$num = _1 ];
then
echo "1 FI chip"
weights="1.0"
fi

#file list
filelist=""
for file in `ls xis0.rmf xis2.rmf xis3.rmf 2> /dev/null`;
do
filelist=${filelist},$file
done
filelist=`echo $filelist | sed -e "s/^,//g"`

echo "File List = $filelist"

addrmf "$filelist" "$weights" rmffile=fi.rmf clobber=yes 2>&1 | tee -a `basename $logfile`

rm -f $tmp
cd - &> /dev/null


