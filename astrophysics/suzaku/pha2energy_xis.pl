#!/usr/bin/env perl

#20070501 Takayuki Yuasa
#20100124 perl path fixed

if(@ARGV==0){
 print "usage : pin_pi2energy.pl PHA";
 #exit;
}

$pi=$ARGV[0];

if($pi<0 or $pi>255){
 print "0\n";
}else{
 $ene=(3.65*$pi/1000);
 print $ene."\n";
}
