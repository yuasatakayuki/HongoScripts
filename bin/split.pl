#!/usr/bin/env perl

#20060715 perlのsplit関数を簡単にbashなどから利用するためのスクリプト
#20100124 perl path fixed

#split.pl delimitter text index_of_output
#index_of_outputで指定した位置の要素が出力される
#textの行末の改行はchompで切り落とされる

$scriptname="split.pl";
$usage="usage $scriptname delimitter text index_of_output\n";

if(@ARGV == 3){}else{die "split.pl : ERROR lack of arguments...\n;$usage";}

chomp($ARGV[1]);

@array=split($ARGV[0],$ARGV[1]);
print $array[$ARGV[2]];
