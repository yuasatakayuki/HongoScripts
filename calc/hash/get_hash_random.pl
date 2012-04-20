#!/usr/bin/env perl

#20090304 Takayuki Yuasa
#20100124 perl path fixed
#20100125 short hash is adopted and the prefix "temporary_" will be provided
#20100809 Takayuki Yuasa longer random part

use Digest::SHA1 qw(sha1_hex);
use Time::HiRes qw(gettimeofday);
CALCHASH:
($sec,$microsec)=gettimeofday();
$hash=sha1_hex($sec.$microsec);
if(-f $hash || -d $hash){
goto CALCHASH;
}
print "temporary_".substr($hash,0,8)."\n";
