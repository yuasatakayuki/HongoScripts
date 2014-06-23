#!/usr/bin/env ruby

# Takayuki Yuasa 20140622

for file in `cat filesToBeCopied.text`; do
	echo "Copying $file"
	cp bin_oldName/$file bin/
done

for file in `cat filesToBeProcesses.text`; do
	echo "Processing $file"
	ruby renameScriptsFromBinOldNameToBin.rb bin_oldName/$file
done
