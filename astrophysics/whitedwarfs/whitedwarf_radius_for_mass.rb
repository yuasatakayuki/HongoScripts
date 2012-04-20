#!/usr/bin/env ruby

#20100715 Takayuki Yuasa

if(ARGV.length==0)then
print "usage whitedwarf_radius_for_mass.rb (white dwarf mass in units of Msun) (output unit {cm m km Rsun Rearth};optional, default=cm)\n"
exit -1
end

unit="cm"

if(ARGV.length==2)then
unit=ARGV[1]
end

mwd=ARGV[0].to_f()
if(1.44<=mwd or mwd<=0)then
print "0\n"
exit -1
end

rwd=7.8e8*Math.sqrt((1.44/mwd)**(2.0/3.0)-(mwd/1.44)**(2.0/3.0)) #cm
rwd_out=rwd
if(unit=="cm")then
 rwd_out=rwd
elsif(unit=="m")then
 rwd_out=rwd/100
elsif(unit=="km")then
 rwd_out=rwd/100000
elsif(unit=="Rsun")then
 rwd_out=rwd/100000/(1392000)
elsif(unit=="Rearth")then
 rwd_out=rwd/100000/6356
else
 rwd_out=0
end

print "#{rwd_out}\n"

