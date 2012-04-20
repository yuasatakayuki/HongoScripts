#!/usr/bin/env perl

#20100124 perl path fixed

if(@ARGV==0){
 print "give archive file name\n";
}

foreach $file (@ARGV){
 @a=split(".","$file");
 $suffix=$a[-1];
 switch($suffix){
  case "zip" {
   
}
