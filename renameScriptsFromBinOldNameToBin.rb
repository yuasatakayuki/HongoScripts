#!/usr/bin/env ruby

# Takayuki Yuasa 20140622

require 'pp'
require 'cgi'

if(ARGV.length<1)then
	puts "Provide input file"
	exit
end

inputFile=ARGV[0]

newNames={}

open("rename_list.text").each(){|line|
	line.strip!()
	array=line.split(" ")
	if(array.size==0)then
	 break
	end
	old=array[0]
	new=""
	if(array[1]!=nil)then
		new=array[1]
	else
		#do not replace
		next
	end

	if(newNames[new]!=nil)then
	 puts "old=#{old} new=#{new} collides with old=#{newNames[new]}"
	else
	 newNames[new]=old
	end

	if(new.include?("?"))then
	 puts "old=#{old} does not have proper new name"
	end
}



oldToNew={}
newNames.each(){|newName,old|
	oldToNew[old]=newName
}

text=File.read(inputFile)
#text=CGI.escapeHTML(text)

oldToNew.each(){|oldName,newName|
	regexp=oldName
	replaceString=newName
	text.gsub!(regexp,replaceString)
}

outputFileName="bin/"+File.basename(inputFile)
outputFile=open(outputFileName,"w")
outputFile.puts text
outputFile.close
File.chmod(0755,outputFileName)