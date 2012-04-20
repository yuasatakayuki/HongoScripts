#!/usr/bin/env ruby

#20100809 Takayuki Yuasa

if(ARGV.length==0)then
print <<EOF
usage : xis_calculate_mosaic_image_size.rb (xis image file1) (xis image file2) ... (xis image fileN)

This script calculates the appropriate mosaic image size for input images.
The output size enclose the whole region covered by the input images.
EOF
exit
end

ramin=360
ramax=0
decmin=90
decmax=-90

ras=[]
decs=[]
files=[]

STDERR.puts "Calculating Size..."

ARGV.each{ |file|

if(FileTest.exist?(file))then
STDERR.puts "Processing #{file}..."
ra=`getheader.sh #{file} 0 ra_nom`.to_f()
dec=`getheader.sh #{file} 0 dec_nom`.to_f()

ras.push(ra)
decs.push(dec)
files.push(file)

if(ra<ramin)then
ramin=ra
end

if(ramax<ra)then
ramax=ra
end

if(dec<decmin)then
decmin=dec
end

if(decmax<dec)then
decmax=dec
end

end
}

#calculate the center
center_ra=(ramax+ramin)/2
center_dec=(decmax+decmin)/2

#find a point which is the nearest to the center
center_i=-1
center_distance=-1
for i in 0...ras.length do
 ra=ras[i]
 dec=decs[i]
 if(center_distance<0)then
  center_distance=(center_ra-ra)**2+(center_dec-dec)**2
  center_i=i
 end
 distance=(center_ra-ra)**2+(center_dec-dec)**2
 if(distance<center_distance)then
  center_distance=distance
  center_i=i
 end
end



#dump for debug
#print "ramax:#{ramax}\n"
#print "ramin:#{ramin}\n"
#print "decmax:#{decmax}\n"
#print "decmin:#{decmin}\n"
#print "center_ra:#{center_ra}\n"
#print "center_dec:#{center_dec}\n"
#print "center_distance:#{center_distance}\n"
#print "center_i:#{center_i}\n"

delta_ra=ramax-ramin
delta_dec=decmax-decmin
delta=0
if(delta_ra<delta_dec)then
delta=delta_dec
else
delta=delta_ra
end

cdelt=`cdelt1.sh #{ARGV[0]}`.to_f()
size=delta/cdelt*1.5
print "#{size.to_i().abs()} #{files[center_i]}\n"
