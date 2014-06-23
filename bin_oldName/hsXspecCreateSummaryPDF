#!/bin/bash

#20090612 Takayuki Yuasa modified from the previous PS implementation to use PDF

if [ _$2 = _ ];
then
 echo "usage : xspec_create_summary.sh (spectral ps file) (xspec log file)"
 exit
fi

ps=$1
log=$2
dir=`dirname $ps`
outpdf=$dir/`basename $ps .ps`_summary.pdf
tmpps=`get_hash_random.pl`.ps
tmppdf=`get_hash_random.pl`.pdf
specpdf=`get_hash_random.pl`.pdf
tmpallpdf=`get_hash_random.pl`.pdf

a2ps.pl $2 > $tmpps
ps2pdf $ps $specpdf
ps2pdf $tmpps $tmppdf
pdftk $specpdf $tmppdf cat output $tmpallpdf
pdfnup --nup 1x2 $tmpallpdf --no-landscape --outfile $outpdf

rm $tmpps $tmppdf $specpdf $tmpallpdf

