#!/bin/bash

#20100714 Takayuki Yuasa

if [ _$1 = _ ]; then
cat << EOF
usage : `basename $0` (gnuplot command file with ".gp" suffix) ("color" or "grayscale";default "color") (font size;optional, default=18)
This script creates a pdf file from a gnuplot's command file.
The command file must have .gp suffix. The saved pdf has the
same file prefix as the command file.
For example, if "kT_vs_Z.gp" is provided, the plot is saved 
as "kT_vs_Z.pdf".

The set terminal option can be passed  
EOF
exit
fi

if [ ! -f $1 ]; then
echo "file not found...exit"
exit
fi

if [ _$2 != _ ]; then
 if [ $2 = "color" ]; then
  color="col"
 elif [ $2 = "grayscale" ]; then
  color=""
 else
  color="col"
 fi
else
color="col"
fi

if [ _$3 = _ ]; then
fontsize=18
else
fontsize=$3
fi

outputpsfile=`get_hash_random.pl`.ps

gnuplot << EOF
load "$1"
set terminal post $color "Times" $fontsize
set out "$outputpsfile"
replot
exit
EOF

ps2pdf $outputpsfile
rm $outputpsfile
mv `basename $outputpsfile .ps`.pdf `dirname $1`/`basename $1 .gp`.pdf
