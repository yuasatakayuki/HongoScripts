#!/usr/bin/env perl

#20090305 Takayuki Yuasa
#20100124 perl path fixed

#returns the index where the second argument appears inside the first argument

if(@ARGV!=2){
 print "usage : indexof.pl str1 str2\n";
 exit;
}

print index($ARGV[0],$ARGV[1]);  
