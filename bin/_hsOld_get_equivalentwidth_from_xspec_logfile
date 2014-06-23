#!/usr/bin/env ruby

#20090928 Takayuki Yuasa
#20090929 Takayuki Yuasa bug fix
#20091224 Takayuki Yuasa
#20100222 Takayuki Yuasa for xspec12 log
#20101109 Takayuki Yuasa for error estimation

#Usage
#
#arguments
#0 log file
#1 energy range (enclosed with double quotations;e.g. "12 40" for flux 12-40 keV)
#2 effective digits(optional)

if(ARGV.length<2)then
print "usage : get_equivalentwidth_from_xspec_logfile.rb (xspec logfile name) (model component number) (errp or errm; optional)\n"
exit
end

modelnumber=ARGV[1]

err=""
if(ARGV[2]!=nil)then
err=ARGV[2]
end

ew=0.0
flag_ew_dumped=false
logfile=File::open(ARGV[0]) { |f|
 f.each { |line|
  #delete top # (xspec12)
  if(line.slice(0,1)=="#")then #xspec12 support
  	line=line.slice(1,line.length-1)
  	xspec12mode=true
  end
  if(line.include?("Additive group equiv width for model #{modelnumber}") or line.include?("Additive group equiv width for Component #{modelnumber}"))then
   array=line.split(" ")
   if(array[-1]=="eV")then
    ew=array[-2].to_f
   else
    ew=array[-2].to_f()*1000
   end
   if(err=="")then
    puts ew
    exit
   end
   flag_ew_dumped=true
  end
  if(flag_ew_dumped==true and err!="" and line.include?("Equiv width error range:"))then
   factor=1
   if(line.include?("keV"))then
   factor=1000
   end
  	if(err=="errp")then
    print line.split(" ")[-2].to_f*factor-ew
  	elsif(err=="errm")then
    print line.split(" ")[-4].to_f*factor-ew
  	else
  	 exit
  	end
  end
 }
}
