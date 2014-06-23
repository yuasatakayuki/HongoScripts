#!/usr/bin/env perl

#MCA to DAT formatter
#2006-05-08 Takayuki Yuasa
#2007-09-01 Takayuki Yuasa bug fix
#20100124 perl path fixed

foreach $filename (@ARGV){
	if(-f $filename and substr($filename,-4,4) eq ".mca"){
		open(FILE,$filename);
		@list=<FILE>;
		close FILE;
		$filename=~s/.mca/.dat/g;
		open(FILE,">".$filename);
		$data_flag=0;
		$channel_number=0;

		foreach $line (@list){
			if(index($line,"<<END>>")==0){
				$data_flag=0;
		    }
			if($data_flag==1 and $line ne "<<END>>\n"){
				print FILE $channel_number." ".$line;
				$channel_number++;
			}
			if(index($line,"<<DATA>>")==0){
				$data_flag=1;
		    }
	
		}
		close FILE;
		print $filename." was created!\n";
	}else{
		if(-f $filename){}else{print "warning:$filename doesnot exist...\n";}
		if(index($filename,"mca")=>0){}else{print "warning:$filename isnot a mca file...\n";}
	}
}
