#!/usr/bin/env ruby

#20090304 Takayuki Yuasa
#20100124 perl path fixed
#20100125 short hash is adopted and the prefix "temporary_" will be provided
#20100809 Takayuki Yuasa longer random part
#20120828 Takayuki Yuasa changed to use ruby

require 'digest/sha2'


ctime=Time.now
str="#{ctime.day}#{ctime.month}#{ctime.usec}#{ctime.sec}"
hash=Digest::SHA256.hexdigest(str)[0..5]
print "temporary_#{hash}\n"
