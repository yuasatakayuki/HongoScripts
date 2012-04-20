#!/bin/sh 


# reprocess HXD unscreened files
# must be done in event_uf_repro/

pincl=`ls ../event_cl/ae*pinno_cl.evt`
pinfile=`basename $pincl`

rm -f $pinfile
ln -s $pincl .

# create pin gtifile
rm -f pin.gti
mgtime "$pinfile[2],$pinfile[2]" pin.gti AND


ufevt=`ls ae*hxd_0_wel*.evt`
clevt=`basename $ufevt _wel_uf.evt`_gsono_cl.evt

rm -f *.xsl $clevt
 
xselect << EOF  2>&1 | tee HS_extract_cleanGSO_$$.log


read event "$ufevt" ./

filter time file pin.gti
filter column "DET_TYPE=0:0"

show filter

extract event

save event
$clevt


exit


EOF



fparkey fitsfile="${clevt}+0" \
      value="WELL_GSO" keyword="DETNAM" comm="detector name" add=no
fparkey fitsfile="${clevt}+1" \
      value="WELL_GSO" keyword="DETNAM" comm="detector name" add=no


fkeyprint infile= "../event_cl/${clevt}" keynam="TIMEDEL" > fkeytmp$$.log
timedel=( `awk '(/TIMEDEL =/) {print $3}' fkeytmp$$.log` )

fparkey fitsfile="${clevt}+0" \
      value="${timedel[1]}" keyword="TIMEDEL" \
      comm="finest time resolution (time between frames)" add=no

fparkey fitsfile="${clevt}+1" \
      value="${timedel[1]}" keyword="TIMEDEL" \
      comm="finest time resolution (time between frames)" add=no
