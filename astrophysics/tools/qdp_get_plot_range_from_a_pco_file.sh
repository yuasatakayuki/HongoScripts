#!/usr/bin/env ruby

#20090611 Takayuki Yuasa

if(ARGV.length<3)then
print "usage : qdp_get_plot_range_from_a_pco_file.sh (pco file) (axis;x or y, x1, x2, xN...) (minimum 
or 
maximum)\n"
exit
end

array=[]
axis=ARGV[1].downcase
open(ARGV[0]).each{|line|
	line=line.downcase
	if(line =~ /r *#{axis} /)then
		array.push(line.downcase)
	end
}

if(array.length!=0)then
	linearray=array[-1].split(" ")
	
	limit=ARGV[2].downcase
	if(limit=="minimum")then
	 print linearray[2]
	else
	 if(linearray.length<4)then
	  print "-1"
	 else
	  print linearray[3]
	 end
	end
else
	print "-1"
end
