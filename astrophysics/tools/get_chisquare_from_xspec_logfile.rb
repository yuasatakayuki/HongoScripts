#!/usr/bin/env ruby

#20090611 Takayuki Yuasa
#20100222 Takayuki Yuasa for xspec12 log

#Usage
#
#arguments
#0 log file
#1 parameter name (one of chisquare, reducedchisquare, ndf, or nhp)
#2 effective digits(optional)

if(ARGV.length<2)then
print "usage : get_parameter_from_xspec_logfile.rb (xspec logfile name) (parameter name [one of chisquare, reducedchisquare, ndf, ndof, or nhp]) (effective digits;optional)\n"
exit
end

chi2array=[]
nhparray=[]
logfile=File::open(ARGV[0]) { |f|
 f.each { |line|
  #delete top # (xspec12)
  if(line.slice(0,1)=="#")then #xspec12 support
  	line=line.slice(1,line.length-1)
  	xspec12mode=true
  end

  if(line.include?("Reduced chi-squared"))then
   if(line.include?("degrees of freedom"))then
    chi2array.push(line)
   end
  end
  if(line.include?("Null hypothesis probability"))then
   nhparray.push(line)
  end
 }
}

#split into components
value=-1
if(ARGV[1].include?("nhp"))then
 if(nhparray.length!=0)then
  line=nhparray[-1]
  nhparray_linearray=line.split(" ")
  nhp=nhparray_linearray[4].to_f()
  value=nhp
 end
else
 if(chi2array.length!=0)then
  line=chi2array[-1]
  chi2array_linearray=line.split(" ")
  reducedchi2=chi2array_linearray[3].to_f()
  ndf=chi2array_linearray[5].to_f()
  if(ARGV[1]=="chisquare")then
   value=reducedchi2*ndf
  end
  
  if(ARGV[1]=="reducedchisquare")then
   value=reducedchi2
  end
  
  if(ARGV[1]=="ndf" or ARGV[1]=="ndof")then
   value=ndf.to_i
  end
 end
end

if(ARGV.length==3)then
 print format("%.#{ARGV[2]}G",value)
else
 print "#{value}"
end
