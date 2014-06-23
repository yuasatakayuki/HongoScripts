#!/usr/bin/env ruby

# Takayuki Yuasa 20140622

for file in `ls bin/hs*`; do
	echo "Processing $file"
	outputFile=`basename $file`.html
	ruby renameScriptsPreviewAsHTML.rb $file > html/$outputFile
done
