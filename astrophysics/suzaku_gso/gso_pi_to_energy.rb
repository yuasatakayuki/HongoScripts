#!/usr/bin/env ruby

#20090527 Takayuki Yuasa

if(ARGV.size()==0)then
print "usage : gso_pi_to_energy.rb (PI)\n"
print "returns corresponding bin-center energy\n"
exit
end
print 2*(ARGV[0].to_i()+1)-1
