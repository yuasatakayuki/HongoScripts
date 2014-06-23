open("rename_list.text").each(){|line|
	array=line.split(" ")
	oldName=array[0]
	newName=array[1]
	puts "alias #{oldName}=#{newName}"
}
