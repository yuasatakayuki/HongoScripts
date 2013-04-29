#!/usr/bin/env ruby

#20101111 Takayuki Yuasa
#20130429 Takayuki Yuasa added support for parallelized error estimation (e.g. error 1 2 3)

if(ARGV.length<3)then
puts <<EOS
xspec_get_parameter_from_a_logfile.rb (log file) (model component number) (parameter name) (errp/errm/value_errp_errm/value/errP/errM/value_errM_errP;optional) (ruby style format;optional)
EOS
exit
end

logfile=ARGV[0]
if(!File.exist?(logfile))then
$STDERR.puts "File not found..."
exit
end

ncomp=ARGV[1].to_i
pname=ARGV[2]
err="value"
if(ARGV[3]!=nil)then
err=ARGV[3]
end

format="%s"
format_plus="%s"
if(ARGV[4]!=nil)then
format=ARGV[4]
format_plus=format.gsub("%","%+")
format_plus=format_plus.gsub("%++","%+")
end

npara=0
paravalue=0

lines=[]
errorcommands=[]

i=0
open(logfile).each{|line|
 line=line.gsub("#","")
 a=line.split(" ")
 if(a[1]!=nil and a[3]!=nil)then
	 if(npara==0 and a[1].to_i==ncomp and a[3]==pname)then
	  npara=a[0].to_i
	  paravalue=a[-3]
	  #puts "Nparameter=#{npara}"
	 end
 end
 if(line.include?("XSPEC") and line.include?(">") and line.include?("err"))then
  errorcommands.push(i)
 end
 i=i+1
 lines.push(line)
}

if(err=="value")then
puts paravalue
exit
end

blocks={}
for i in 0...errorcommands.length do
 from=errorcommands[i]
 to=from
 if(errorcommands[i+1]!=nil)then
  to=errorcommands[i+1]
 else
  to=lines.length-1
 end
 errcommand=lines[errorcommands[i]]
 a=errcommand.split(" ")
 for p in 1...a.length do
	 nerrpara=a[p].to_i
	 blocks[nerrpara]=lines[from..to]
 end
end

block=blocks[npara]
if(block!=nil)then
block.each{|line|
 line=line.gsub("#"," ")
 line=line.gsub(","," ")
 line=line.gsub(")"," ")
 line=line.gsub("("," ")
 a=line.split(" ")
 #puts line
 if(a[0].to_i==npara)then
  if(err=="errp")then
   puts format % a[-1]
   exit
  elsif(err=="errm")then
   puts format % a[-2]
   exit
  elsif(err=="value_errp_errm")then
   puts "$#{format % paravalue}^{#{format_plus % a[-1]}}_{#{format % a[-2]}}$"
  elsif(err=="errP")then
   if(a[-3]!=nil)then
    puts format % a[-3]
   end
  elsif(err=="errm")then
   if(a[-4]!=nil)then
    puts format % a[-4]
   end
  elsif(err=="value_errM_errP")then
   if(a[-4]!=nil and a[-3]!=nil)then
    puts "#{format % paravalue}(#{(format_plus % a[-4]).gsub("+","")}-#{(format % a[-3]).gsub("+","")})"
   end
  end
 end
}
end
