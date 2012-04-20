#!/usr/bin/env ruby

#20100215 Takayuki Yuasa

if(ARGV.length==0)then
print "usage : regionfile_get_circle_center_ra_dec.rb (region file name) (index of circular region;optional, default=0)\n"
print "This script prints center ra and dec of a circular region which appears i-th in input file. The index i is passed as the second argument, otherwise 1st one will be used.\n"
print "FK5 parameter should be included in the input region file. If not, returned ra and dec will be \"0 0\".\n"
exit
end

filename=ARGV[0]
if(ARGV.length==2)then
 index=ARGV[1].to_i()
else
 index=0
end


if(!File.exist?(filename))then
STDERR.print "input region file '#{filename}' not found...exit\n"
print "0 0"
exit
end


containsFK5=false
array=[]
open(filename).each {|line|
 if(line.include?("FK5") or line.include?("fk5"))then
  containsFK5=true
 end
 if(line.include?("circle") or line.include?("CIRCLE"))then
  array.push(line)
 end
}

if(containsFK5==true)then
 line=array[index]
 parts=line.split("(")
 coordinates=parts[1].split(",")
 ra=coordinates[0]
 dec=coordinates[1]
 print "#{ra} #{dec}\n"
else
 print "0 0\n"
end
