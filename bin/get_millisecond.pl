use Time::HiRes qw(gettimeofday);
($sec,$microsec)=gettimeofday();
print $sec.$microsec;
