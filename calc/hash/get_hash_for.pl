#!/usr/bin/env perl

#20090304 Takayuki Yuasa
#20100124 perl path fixed

use Digest::SHA1 qw(sha1_hex);

if(@ARGV!=0){
print sha1_hex($ARGV[0])."\n";
}
