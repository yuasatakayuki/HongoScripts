#!/usr/bin/env ruby

# Takayuki Yuasa 20140622

list=[]
open("rename_list.text").each(){|line|
	array=line.strip.split(" ")
	oldName=array[0]
	newName=""
	if(array[1]!=nil)then
		newName=array[1]
		list << [oldName,newName]	
	end
}

list.sort!(){|a,b|
	b[0].length <=> a[0].length
}

list.each(){|e|
 puts "#{e[0]} #{e[1]}"
}
