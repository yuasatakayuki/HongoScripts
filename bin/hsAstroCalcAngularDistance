#!/usr/bin/env perl

#20080828 Takayuki Yuasa
#20100124 perl path fixed

use Math::Trig;

if(@ARGV!=2){
 print "usage angulardistance.pl (kpc) (arcmin)\n";
 print "return : projected distance in a unit of kpc\n";
 exit;
}

$r=$ARGV[0];
$arcmin=$ARGV[1];

$degree=$arcmin/60;
$radian=$degree/360*2*pi;

$distance=$r*$radian;
print $distance."\n";

