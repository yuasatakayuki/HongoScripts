#!/bin/bash

#20090318 Takayuki Yuasa
#20090608 Takayuki Yuasa suppress message when deleting old arf

if [ _$1 = _ ];
then

echo "xis_merge_arfs_fibi.sh (region file)"
echo "note:(region file) should be a region filename which was used to create ARFs to be merged."
echo "FI ARF are created merging exisisting FI ARFs. XIS1 ARF is linked as BI ARF."
echo "output file is fi_(basename 'region file' .reg).arf"
exit
fi

regionfile=$1
regionname=`basename $regionfile .reg`

files=`ls arfs/xis0_${regionname}.arf arfs/xis2_${regionname}.arf arfs/xis3_${regionname}.arf 2> /dev/null`
filelist=`ruby -e "print ARGV.join(',')" $files`
ratio=`ruby -e "a=[];ARGV.each { a+=[1]; }; print a.join(',');" $files`
outputfile=arfs/fi_${regionname}.arf
logfile=${outputfile}.log

#FI
echo "filelist:$filelist" 2>&1 | tee -a $logfile
echo "ratio:$ratio" 2>&1 | tee -a $logfile
echo "outputfile:$outputfile" 2>&1 | tee -a $logfile
rm -r $outputfile &> /dev/null
addarf $filelist $ratio $outputfile 2>&1 | tee -a $logfile

#BI
cd arfs/
ln -sf xis1_${regionname}.arf bi_${regionname}.arf
cd - &> /dev/null
