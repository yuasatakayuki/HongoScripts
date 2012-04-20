#!/bin/bash

#200904xx Takayuki Yuasa file created
#20090706 Takayuki Yuasa modification for CLI-menu driven structure
#20090713 Takayuki Yuasa band image extraction added
#20100125 Takayuki Yuasa ana/ changed to analysis/

##################################
#VARIABLE DEFINITIONS
##################################
# tag : analysis tag name
# source_regionfile : filename of source region
# bgd_regionfile    : filename of bgd region
# gtifile           : filename of gti

tag=contami1
source_regionfile=contami1.reg
bgd_regionfile=bgd1.reg
tag=cleanedevent
source_regionfile=source_ra_dec_120.reg
bgd_regionfile=bgd1.reg
gtifile=none
extraconditionfile=none


##################################
#CONSTANTS
##################################
true=0
false=254
analysisfolder="analysis"

##################################
#INITIALIZATION
##################################
if [ _$HS_PDF_VIEWER = _ ];
then
	echo "please set PDF Viewer program name as the environmental variable HS_PDF_VIEWER"
	echo " Example : "
	echo "  MacOS X case"
	echo "    export HS_PDF_VIEWER=open"
	echo "  Linux case"
	echo "    export HS_PDF_VIEWER=xpdf"
	exit
fi

if [ _$1 = _ ];
then
	read -p "input analysis folder name > " ip
	if [ _$ip = _ ];
	then
	echo "source folder name empty...exit"
	exit
	fi
else
	ip=$1
fi

if [ _$ip = _ -o -d $ip ];
then
echo "souce folder is found...OK"
else
echo "souce folder is not found...exit"
exit
fi

topdirectory=`pwd`

##################################
##################################
#SUB ROUTINES BEGINS
##################################

##################################
#confirm to proceed
##################################
confirm(){
	read -p "press enter to go back to the menu..."
}

##################################
#dump funtion status
##################################
function_start(){
	cat << EOF

*******************************************************************
Function : $functionname starts
*******************************************************************

EOF
}

function_completed(){
	cat << EOF

*******************************************************************
Function : $functionname completed
*******************************************************************

EOF
}

##################################
#show menu
##################################
show_menu(){
	if [ _${source_regionfile} = _ ];
	then
	 current_source_regionfile="...yet assigned..."
	else
	 current_source_regionfile=${source_regionfile}
	fi
	if [ _${bgd_regionfile} = _ ];
	then
	 current_bgd_regionfile="...yet assigned..."
	else
	 current_bgd_regionfile=${bgd_regionfile}
	fi
	if [ _${gtifile} = _ -o _${gtifile} = "_none" ];
	then
	 current_gtifile="...yet assigned..."
	else
	 current_gtifile=$gtifile
	fi
	if [ _${extraconditionfile} = _ -o _${extraconditionfile} = "_none" ];
	then
	 current_extraconditionfile="...yet assigned..."
	else
	 current_extraconditionfile=$extraconditionfile
	fi
	
	cat << EOF
====================================
   XIS Point Source Analysis MENU
====================================
Target Analysis Folder : ${ip}

 --Before Analysis--
 [100] Link Event Files
 
 --Analysis Configuration--
 [200] Set Analysis Tagname 
      Current Tagname = ${tag}
 [210] Set Source/BGD Region Filename
      Current Source = ${current_source_regionfile}
      Current  BGD   = ${current_bgd_regionfile}
 [211] List Region Files (in regions/)
 [220] Set Good Time Interval File
      Current GTI File = ${current_gtifile}
 [230] Extra Condition File
      Current File = ${current_extraconditionfile}
      (this may contain filtering commands for xselect)
 
 --Image Analysis--
 [300] Extract Raw Images
 [301] Check Raw Images
 [302] Create Raw Image PDF 
 [303] Check Raw Image PDF
 [310] Create Source Region File (auto)
 [311] Create Source Region File (manually)
 [312] Create Source Region File (auto, then quit DS9)
 [320] Create BGD Region File (auto)
 [321] Create BGD Region File (manually)
 [322] Create BGD Region File (auto, then quit DS9)
 [330] Extract Filtered Images
 [331] Check Filtered Images
 [340] Extract Band Images
 [341] List Band Images
 [342] Display Band Images
 
 --Spectral Analysis--
 [400] Extract Source/BGD Spectra
 [410] Create Redistribution Matrices
 [411] List Redistribution Matrices
 [420] Create Ancillary Response Files
 [421] List Ancillary Response Files
 [430] Create Spectra Check Plot
 [431] Check Spectra Check Plot
 
 --Temporal Analysis--
 [500] Extract Source/BGD Lightcurves
 [501] List Lightcurve(.lc) Files
 [502] List Lightcurve Plots
 [503] Display Lightcurve Plot
 [510] Calculate Power Spectrum
 [520] Search Periodicity
 [530] Fold Lightcurve
 
 --Quit--
 [999] Quit
 
EOF
}


##################################
#change analysis tagname
##################################
set_analysis_tagname(){
	cat << EOF
*******************************************************************
                         NOTICE
*******************************************************************
"Analysis Tag" is a name of data set which produced with current
event filtering conditions (like region, GTI, and so on). The tag 
should be simple but self-contained so that you or your colleague 
can know the contents and their filtering conditions easily.
*******************************************************************
EOF
	echo ""
	read -p "input tag name > " tag
}

##################################
#set source/bgd region filenames
##################################
set_regionfilenames(){
	read -p "input source region filename > " source_regionfile
	read -p "then, input background region filename > " bgd_regionfile
	check_regionfile_exsistence
	if [ $? -eq $false ];then
		echo ""
		cat << EOF
*******************************************************************
                         WARNING
*******************************************************************
It seems that region files designated above do not exist yet.
Please create them using 'Create Source Region File' and 
'Create Bgd Region File' commands before starting further analysis.
*******************************************************************
EOF
		echo ""
		confirm
	fi
}

##################################
#list region files
##################################
list_region_files(){
	cd $ip/${analysisfolder}/xis/image_analysis/regions
	regionfiles=`ls -1 *.reg`
	regionfiles_head1=`ls -1 *.reg | head -1`
	cd - &> /dev/null
	if [ _$regionfiles_head1 = _ ];
	then
		echo "there are no region files..."
	else
		echo "image_analysis/regions/ contains..."
		for entry in $regionfiles;
		do
			echo " $entry"
		done
		echo ""
	fi
	confirm
}

##################################
#check if region files exist
##################################
check_regionfile_exsistence(){
	echo "checking region files..."
	if [ _$source_regionfile = _ ];then
		echo " source region file is not set yet..."
		return $false
	fi
	if [ _$bgd_regionfile = _ ];then
		echo " bgd region file is not set yet..."
		return $false
	fi
	
	echo " checking ${ip}/${analysisfolder}/xis/image_analysis/regions/${source_regionfile}..."
	if [ ! -f ${ip}/${analysisfolder}/xis/image_analysis/regions/${source_regionfile} ];then
		echo " file not found..."
		return $false
	else
		echo "  OK"
	fi

	echo " checking ${ip}/${analysisfolder}/xis/image_analysis/regions/${bgd_regionfile}..."
	if [ ! -f ${ip}/${analysisfolder}/xis/image_analysis/regions/${bgd_regionfile} ];then
		echo " file not found..."
		return $false
	else
		echo "  OK"
	fi
	return $true
}

##################################
#set gti filename
##################################
set_gtifilename(){
	read -p "input gti filename > " gtifile
	check_gtifile_exsistence
	if [ $? -eq $false ];then
		echo ""
		cat << EOF
*******************************************************************
                         WARNING
*******************************************************************
It seems that GTI file designated above do not exist yet.
Please check the filepath or create it before proceeding
event processing.
*******************************************************************
EOF
		echo ""
		confirm
	fi
}

##################################
#check if gti file exist
##################################
check_gtifile_exsistence(){
	echo "checking GTI file..."
	if [ _$gtifile = _ ];then
		echo " GTI file is not set yet..."
		return $false
	fi
	if [ _$gtifile = "_none" ];then
		echo " GTI file is not set yet..."
		return $false
	fi
	
	echo " checking ${gtifile}..."
	if [ ! -f ${gtifile} ];then
		echo " file not found...NG"
		return $false
	else
		echo " GTI file found...OK"
	fi

	return $true
}

##################################
#set extra condition filename
##################################
set_extraconditionfilename(){
	read -p "input extra condition filename > " extraconditionfile
	check_extraconditionfile_exsistence
	if [ $? -eq $false ];then
		echo ""
		cat << EOF
*******************************************************************
                         WARNING
*******************************************************************
It seems that Extra Condition file designated above do not exist yet.
Please check the filepath or create it before proceeding
event processing.
*******************************************************************
EOF
		echo ""
		confirm
	fi
}

##################################
#check if extra command file exist
##################################
check_extraconditionfile_exsistence(){
	echo "checking Extra Command file..."
	if [ _$extraconditionfile = _ ];then
		echo " Extra Command file is not set yet..."
		return $false
	fi
	if [ _$extraconditionfile = "_non" ];then
		echo " Extra Command file is not set yet..."
		return $false
	fi
	
	echo " checking ${extracommandfile}..."
	if [ ! -f ${extracommandfile} ];then
		echo " file not found...NG"
		return $false
	else
		echo " Extra Command file found...OK"
	fi

	return $true
}



##################################
#link event
##################################
link_event(){
	functionname="link event"
	function_start
	cd $ip/${analysisfolder}/xis/
	xis_link_event.sh `ls -d ../../data/?????????`
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#extract raw images
##################################
extract_raw_images(){
	functionname="extract raw image"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/
	xis_extract_raw_images.sh
	cd - &> /dev/null
	function_completed
	confirm
}

check_raw_images(){
	functionname="check raw images"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/
	if [ -f raw_images/fi_bin2.img -a -f raw_images/bi_bin2.img ];
	then
		ds9 raw_images/fi_bin2.img raw_images/bi_bin2.img -zoom to fit -frame 1 -zoom to fit 
	else
		echo " raw images are not found"
		echo " use this command after extracting raw images"
	fi
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#create regions
##################################
create_source_region_auto(){
	functionname="create source region (auto)"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/
	if [ ! -f raw_images/fi_bin1.img ];
	then
		echo " needed image file 'raw_images/fi_bin1.img' was not found..."
		echo " please execute this command after executing 'Extract Raw Images'"
		return
	fi
	read -p "input source region filename to be created > " source_regionfile
	xis_create_region_file_for.sh raw_images/fi_bin1.img regions/${source_regionfile}
	ds9 raw_images/fi_bin1.img -region regions/${source_regionfile} -zoom to fit
	cd - &> /dev/null
	function_completed
	confirm
}

create_source_region_auto_then_quit(){
	functionname="create source region (auto)"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/
	if [ ! -f raw_images/fi_bin1.img ];
	then
		echo " needed image file 'raw_images/fi_bin1.img' was not found..."
		echo " please execute this command after executing 'Extract Raw Images'"
		return
	fi
	read -p "input source region filename to be created > " source_regionfile
	xis_create_region_file_for.sh raw_images/fi_bin1.img regions/${source_regionfile}
	ds9 raw_images/fi_bin1.img -region regions/${source_regionfile} -zoom to fit -quit
	cd - &> /dev/null
	function_completed
	confirm
}



create_bgd_region_auto(){
	functionname="create source region (auto)"
	function_start
	echo "create bgd region (auto)"
	cd $ip/${analysisfolder}/xis/image_analysis/
	if [ ! -f raw_images/fi_bin1.img ];
	then
		echo " needed image file 'raw_images/fi_bin1.img' was not found..."
		echo " please execute this command after executing 'Extract Raw Images'"
		return
	fi
	read -p "input bgd region filename to be created > " bgd_regionfile
	yesno=`yesno.sh "use default radius (inner=180\", outer=270\") [yes/no] > "`
	if [ $yesno = "yes" ];
	then
		inner=""
		outer=""
	else
		read -p "input inner radius in arcsec > " inner
		read -p "input outer radius in arcsec > " outer
	fi
	xis_create_bgd_region_file_for.sh raw_images/fi_bin1.img regions/${bgd_regionfile} $inner $outer
	ds9 raw_images/fi_bin1.img -region regions/${bgd_regionfile} -zoom to fit
	cd - &> /dev/null
	function_completed
	confirm
}

create_bgd_region_auto_then_quit(){
	functionname="create source region (auto)"
	function_start
	echo "create bgd region (auto)"
	cd $ip/${analysisfolder}/xis/image_analysis/
	if [ ! -f raw_images/fi_bin1.img ];
	then
		echo " needed image file 'raw_images/fi_bin1.img' was not found..."
		echo " please execute this command after executing 'Extract Raw Images'"
		return
	fi
	read -p "input bgd region filename to be created > " bgd_regionfile
	yesno=`yesno.sh "use default radius (inner=180\", outer=270\") [yes/no] > "`
	if [ $yesno = "yes" ];
	then
		inner=""
		outer=""
	else
		read -p "input inner radius in arcsec > " inner
		read -p "input outer radius in arcsec > " outer
	fi
	xis_create_bgd_region_file_for.sh raw_images/fi_bin1.img regions/${bgd_regionfile} $inner $outer
	ds9 raw_images/fi_bin1.img -region regions/${bgd_regionfile} -zoom to fit -quit
	cd - &> /dev/null
	function_completed
	confirm
}


##################################
#extract filtered images
##################################
extract_filtered_images(){
	functionname="extract filtered images"
	function_start
	#check region file existence
	check_regionfile_exsistence
	if [ $? = false ];
	then
		return
	fi
	#if region files are OK, then
	cd $ip/${analysisfolder}/xis/image_analysis/
	for file in xis0_evt.evt xis1_evt.evt xis2_evt.evt xis3_evt.evt fi_evt.evt bi_evt.evt;
	do
		eventfile=../data/$file
		if [ -f $eventfile ];then
			outputimage_source=filtered_images/$tag/`basename $file .evt`_`basename ${source_regionfile} .reg`.img
			outputimage_bgd=filtered_images/$tag/`basename $file .evt`_`basename ${bgd_regionfile} .reg`.img
			xis_extract_filtered_images.sh $eventfile $outputimage_source regions/${source_regionfile} ${extraconditionfile}
			xis_extract_filtered_images.sh $eventfile $outputimage_bgd regions/${bgd_regionfile} ${extraconditionfile}
		fi
	done
	cd - &> /dev/null
	function_completed
	confirm
}

check_filtered_images(){
	functionname="check filtered images"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/
	if [ -f filtered_images/${tag}/fi_evt_`basename ${source_regionfile} .reg`.img -a -f filtered_images/${tag}/fi_evt_`basename ${bgd_regionfile} .reg`.img ];
	then
		ds9 filtered_images/${tag}/fi_evt_`basename ${source_regionfile} .reg`.img -region regions/${source_regionfile} -zoom to fit filtered_images/${tag}/fi_evt_`basename ${bgd_regionfile} .reg`.img -region regions/${bgd_regionfile} -zoom to fit -frame 1 -zoom to fit
	else
		echo " filtered images are not found"
		echo " use this command after extracting filtered images"
	fi
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#create energy-band-divided img
##################################
extract_band_images(){
	functionname="extract_band_images"
	function_start
	pushd $ip/${analysisfolder}/xis/image_analysis/ &> /dev/null
	echo "Please input Energy Bnad to be used for band images..." 
	read -p "  Red image lower limit (keV) > " red_lower_e
	read -p "  Red image upper limit (keV) > " red_upper_e
	read -p "Green image lower limit (keV) > " green_lower_e
	read -p "Green image upper limit (keV) > " green_upper_e
	read -p " Blue image lower limit (keV) > " blue_lower_e
	read -p " Blue image upper limit (keV) > " blue_upper_e
	
	for eventfile in ../data/fi_evt.evt ../data/bi_evt.evt;
	do
		if [ -f $eventfile ];
		then
			xis_extract_band_image.sh $eventfile band_images/${tag}/`basename $eventfile .evt` $red_lower_e $red_upper_e $green_lower_e $green_upper_e $blue_lower_e $blue_upper_e ${extraconditionfile}
		fi
	done
	popd &> /dev/null
	function_completed
	confirm
}

list_band_images(){
	pushd $ip/${analysisfolder}/xis/image_analysis/band_images
	if [ -d ${tag} ];
	then
		pushd ${tag} &> /dev/null &> /dev/null
		echo "image_analysis/band_images/$tag contains..."
		images=`ls -1 *.img 2> /dev/null`
		for entry in $images
		do
			echo " $entry"
		done
		echo ""
                                                                                                        
		popd &> /dev/null
	else
		echo "there is no band image..."
	fi
	popd &> /dev/null
	confirm
}

display_band_images(){
	functionname="check filtered images"
	function_start
	if [ -d $ip/${analysisfolder}/xis/image_analysis/band_images/${tag} ];
	then
		pushd $ip/${analysisfolder}/xis/image_analysis/band_images/$tag &> /dev/null
		echo "image_analysis/band_images/$tag contains..."
		images=`ls -1 *.img 2> /dev/null`
		images_head1=`ls -1 *.img 2> /dev/null | head -1`
		if [ _${images_head1} = _ ];
		then
			echo "there is no band image..."
			echo "Please execute this command after executing 'extract_band_images' command"
		else
			for entry in $images
			do
				echo " $entry"
			done
			echo ""
			read -p "Please input file name of Red-band image   > " red_band_image
			read -p "Please input file name of Green-band image > " green_band_image
			read -p "Please input file name of Blue-band image  > " blue_band_image
			if [ -f $red_band_image -a -f $green_band_image -a -f $blue_band_image ];
			then
				echo ""
				echo "ds9 will run. Please close the DS9 window if you finish your operation."
				ds9 -rgb -red $red_band_image -green $green_band_image -blue $blue_band_image
			fi
			popd &> /dev/null
		fi
	else
		echo "there is no band image..."
		echo "Please execute this command after executing 'extract_band_images' command"
	fi
	function_completed
	confirm
}

##################################
#create img pdf
##################################
create_img_pdf(){
	functionname="create img pdf"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/raw_images/
	fits_image_to_pdf.sh fi_bin2.img fi_bin2.pdf
	cd - &> /dev/null
	function_completed
	confirm
}

check_img_pdf(){
	functionname="check raw img pdf"
	function_start
	cd $ip/${analysisfolder}/xis/image_analysis/raw_images/
	`$HS_PDF_VIEWER fi_bin2.pdf`
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#extract source/bgd spectra
##################################
extract_spectra(){
	functionname="extract source/bgd spectra"
	function_start
	#check region file existence
	check_regionfile_exsistence
	if [ $? = false ];
	then
		return
	fi
	#if region files are OK, then
	cd $ip/${analysisfolder}/xis/spectral_analysis/
	for xis in xis0 xis1 xis2 xis3 fi bi;
	do
		if [ -f ../data/${xis}_evt.evt ];
		then
			xis_extract_filtered_spectrum.sh ../data/${xis}_evt.evt pis/$tag/${xis}_`basename ${source_regionfile} .reg`.pi ../image_analysis/regions/${source_regionfile} ${extraconditionfile}
			xis_extract_filtered_spectrum.sh ../data/${xis}_evt.evt bgds/$tag/${xis}_`basename ${bgd_regionfile} .reg`.pi ../image_analysis/regions/${bgd_regionfile} ${extraconditionfile}
		fi
	done
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#create rmf
##################################
create_rmf(){
	functionname="create rmf"
	function_start
	cd $ip/${analysisfolder}/xis/spectral_analysis/
	xis_create_response_matrix.sh
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#list response
##################################
list_responses(){
	cd $ip/${analysisfolder}/xis/spectral_analysis/responses/
	responses=`ls -1 *.rmf 2> /dev/null`
	responses_head1=`ls -1 *.rmf 2> /dev/null | head -1`
	cd - &> /dev/null
	if [ _$responses_head1 = _ ];
	then
		echo "there are no response file..."
	else
		echo "spectral_analysis/responses/ contains..."
		for entry in $responses;
		do
			echo " $entry"
		done
		echo ""
	fi
	confirm
}


##################################
#create arf
##################################
create_arf(){
	functionname="create arf"
	function_start
	#check region file existence
	check_regionfile_exsistence
	if [ $? = false ];
	then
		return
	fi
	#if region files are OK, then
	cd $ip/${analysisfolder}/xis/spectral_analysis/
	for n in 0 1 2 3;
	do
		if [ -f ../data/xis${n}_evt.evt ];
		then
			xis_create_auxiliary_response_file_for_pointsource.sh ../image_analysis/regions/${source_regionfile} $n
		fi
	done
	xis_merge_arfs_fibi.sh ../image_analysis/regions/${source_regionfile}
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#list arfs
##################################
list_arfs(){
	cd $ip/${analysisfolder}/xis/spectral_analysis/arfs/
	arfs=`ls -1 *.arf`
	arfs_head1=`ls -1 *.arf | head -1`
	cd - &> /dev/null
	if [ _$arfs_head1 = _ ];
	then
		echo "there are no arf..."
	else
		echo "spectral_analysis/arfs/ contains..."
		for entry in $arfs;
		do
			echo " $entry"
		done
		echo ""
	fi
	confirm
}

##################################
#create spectra check plots
##################################
create_spectra_check_plot(){
	functionname="create spectra check plot"
	function_start
	cd $ip/${analysisfolder}/xis/spectral_analysis/
	evtpi=pis/${tag}/fi_`basename ${source_regionfile} .reg`_bin20.pi
	if [ ! -f $evtpi ];
	then
		echo "PI file is not found..."
		cd - &> /dev/null
		return
	fi
	bgdpi=bgds/${tag}/fi_`basename ${bgd_regionfile} .reg`.pi
	if [ ! -f $bgdpi ];
	then
		echo "BGD PI file is not found..."
		cd - &> /dev/null
		return
	fi
	rmf=responses/fi.rmf
	if [ ! -f $rmf ];
	then
		echo "response file is not found..."
		cd - &> /dev/null
		return
	fi
	arf=arfs/fi_`basename ${source_regionfile} .reg`.arf
	if [ ! -f $arf ];
	then
		echo "arf is not found..."
		cd - &> /dev/null
		return
	fi
	xis_create_spectra_check_plot.sh $evtpi none none $bgdpi $rmf $arf plots/$tag/fi_`basename ${source_regionfile} .reg`_bin20.pdf "`targetname.sh $evtpi` / Regions ${source_regionfile} & ${bgd_regionfile}"
	cd - &> /dev/null
	function_completed
	confirm

}

check_spectra_check_plot(){
	functionname="check spectra check plot"
	function_start
	check_regionfile_exsistence
	if [ $? -eq $false ];
	then
		echo "please execute this command after preoaration of region files"
		confirm
		cd - &> /dev/null
		return
	fi
	cd $ip/${analysisfolder}/xis/spectral_analysis/
	pdffile=plots/$tag/fi_`basename ${source_regionfile} .reg`_bin20.pdf
	if [ -f $pdffile ];
	then
		echo "opening $ip/${analysisfolder}/xis/spectral_analysis/$pdffile"
		`$HS_PDF_VIEWER $pdffile`
	else
		echo " file not found...execute this command after completing 'Create Spectra Check Plot'"
		confirm
		cd - &> /dev/null
		return
	fi
	cd - &> /dev/null
	function_completed
	confirm
}

##################################
#extract lightcurves
##################################
extract_lightcurves(){
	functionname="extract lightcurves"
	function_start
	#check region file existence
	check_regionfile_exsistence
	if [ $? = false ];
	then
		return
	fi
	
	echo ""
	echo "Input Bin Size and Energy Band to be used in lightcurve extraction"
	echo "Note: Bin Size is normally a multiple of 8 sec since the XIS's frame"
	echo "      exposure is 8sec in normal mode."
	echo ""
	read -p " Bin Size (sec)    > " binsize
	read -p " Lower Limit (keV) > " lower_e
	read -p " Upper Limit (keV) > " upper_e
	band="band`echo $lower_e | sed -e 's/\.//g'`_`echo $upper_e | sed -e 's/\.//g'`keV"
	lower_pi=`xis_energy_to_pi.sh $lower_e`
	upper_pi=`xis_energy_to_pi.sh $upper_e`
	
	echo ""
	echo "Select Lightcurve Plot Appearance"
	yesno=`yesno.sh " Source ALL Lightcurve (yes/no) > "`
	if [ $yesno = yes ];
	then
		show_sourcelc=true
	else
		show_sourcelc=false
	fi
	yesno=`yesno.sh " Background Lightcurve (yes/no) > "`
	if [ $yesno = yes ];
	then
		show_bgdlc=true
	else
		show_bgdlc=false
	fi
	yesno=`yesno.sh " Source-BGD Lightcurve (yes/no) > "`
	if [ $yesno = yes ];
	then
		show_sourcesubbgd=true
	else
		show_sourcesubbgd=false
	fi
	
	#if region files are OK, then
	pushd $ip/${analysisfolder}/xis/lightcurve_analysis/ &> /dev/null
	for file in fi_evt.evt bi_evt.evt;
	do
		eventfile=../data/$file
		if [ -f $eventfile ];then
			#create extracondition
			extraconditionfile=extraconditions/$tag/pha_cut.filter
			mkdir -p `dirname $extraconditionfile` &> /dev/null
			echo "filter pha_cut $lower_pi $upper_pi" > $extraconditionfile
			#extract lightcurve
			outputprefix_source=lcfiles/$tag/`basename $eventfile .evt`_`basename $source_regionfile .reg`_$band
			xis_extract_lightcurve_with_gti.sh $eventfile ../image_analysis/regions/$source_regionfile $gtifile $outputprefix_source $binsize $extraconditionfile
			outputprefix_bgd=lcfiles/$tag/`basename $eventfile .evt`_`basename $bgd_regionfile .reg`_$band
			xis_extract_lightcurve_with_gti.sh $eventfile ../image_analysis/regions/$bgd_regionfile $gtifile $outputprefix_bgd $binsize $extraconditionfile
			#plot
			sourcelc=${outputprefix_source}_bin${binsize}.lc
			bgdlc=${outputprefix_bgd}_bin${binsize}.lc
			outputprefix=plots/$tag/`basename $eventfile .evt`_`basename $source_regionfile .reg`_subtract_`basename $bgd_regionfile .reg`_bin_${binsize}_$band
			xis_plot_lightcurves.sh $sourcelc $bgdlc $outputprefix $show_sourcelc $show_bgdlc $show_sourcesubbgd
		fi
	done
	popd &> /dev/null
	function_completed
	confirm
}

##################################
#list lightcurves
##################################
list_lightcurve_files(){
	if [ ! -d $ip/${analysisfolder}/xis/lightcurve_analysis/lcfiles/${tag} ];
	then
		echo "there are no lightcurve (.lc) file..."
		confirm
		return
	fi
	pushd $ip/${analysisfolder}/xis/lightcurve_analysis/lcfiles/$tag/ &> /dev/null
	files=`ls -1 *.lc 2> /dev/null`
	files_head1=`ls -1 *.lc 2> /dev/null | head -1`
	popd &> /dev/null
	if [ _$files_head1 = _ ];
	then
		echo "there are no lightcurve (.lc) file..."
	else
		echo "lightcurve_analysis/lcfiles/$tag/ contains..."
		for entry in $files;
		do
			echo " $entry"
		done
		echo ""
	fi
	confirm
}

list_lightcurve_plots(){
	if [ ! -d $ip/${analysisfolder}/xis/lightcurve_analysis/plots/${tag} ];
	then
		echo "there are no lightcurve plot file..."
		confirm
		return
	fi
	cd $ip/${analysisfolder}/xis/lightcurve_analysis/plots/$tag/
	files=`ls -1 *.pdf 2> /dev/null`
	files_head1=`ls -1 *.pdf 2> /dev/null | head -1`
	cd - &> /dev/null
	if [ _$files_head1 = _ ];
	then
		echo "there are no lightcurve plot file..."
	else
		echo "lightcurve_analysis/plots/$tag/ contains..."
		for entry in $files;
		do
			echo " $entry"
		done
		echo ""
	fi
	confirm
}

##################################
#display lightcurve plot
##################################
display_lightcurve_plot(){
	functionname="display lightcurve plot"
	function_start
	if [ -d $ip/${analysisfolder}/xis/lightcurve_analysis/plots/${tag} ];
	then
		pushd $ip/${analysisfolder}/xis/lightcurve_analysis/plots/${tag} &> /dev/null
		echo "lightcurve_analysis/lcfiles/${tag} contains..."
		files=`ls -1 *.pdf 2> /dev/null`
		files_head1=`ls -1 *.pdf 2> /dev/null | head -1`
		if [ _${files_head1} = _ ];
		then
			echo "there is no lightcurve plot file..."
			echo "Please execute this command after executing 'Extract Source/BGD Lightcurves' command"
		else
			for entry in $files
			do
				echo " $entry"
			done
			echo ""
			read -p "Please select a filename to be displayed > " filename
			if [ -f $filename ];
			then
				echo ""
				echo "PDF viewer will run. Please close the viewer window if you finish your operation."
				$HS_PDF_VIEWER $filename
			else
				echo "file '$filename' not found..."
			fi
			popd &> /dev/null
		fi
	else
		echo "there is no lightcurve plot..."
		echo "Please execute this command after executing 'Extract Source/BGD Lightcurves' command"
	fi
	function_completed
	confirm
}

##################################
#END OF SUB ROUTINES SECTION
##################################
##################################


##################################
##################################
#MAIN LOOP
##################################
command=000
while [ ! $command = 999 ];
do
	show_menu
	read -p "select command number > " command
	echo ""
	if [ _$command = _ ];
	then
		command=000
	fi
	case $command in
		100) link_event ;;
		200) set_analysis_tagname ;;
		210) set_regionfilenames ;;
		211) list_region_files ;;
		220) set_gtifilename;;
		230) set_extraconditionfilename;;
		300) extract_raw_images ;;
		301) check_raw_images ;;
		302) create_img_pdf ;;
		303) check_img_pdf ;;
		310) create_source_region_auto ;;
		311)  ;;
		312) create_source_region_auto_then_quit ;;
		320) create_bgd_region_auto ;;
		321)  ;;
		322) create_bgd_region_auto_then_quit ;;
		330) extract_filtered_images ;;
		331) check_filtered_images ;;
		340) extract_band_images ;;
		341) list_band_images ;;
		342) display_band_images ;;
		400) extract_spectra ;;
		410) create_rmf ;;
		411) list_responses ;;
		420) create_arf ;;
		421) list_arfs ;;
		430) create_spectra_check_plot ;;
		431) check_spectra_check_plot ;;
		500) extract_lightcurves ;;
		501) list_lightcurve_files ;;
		502) list_lightcurve_plots ;;
		503) display_lightcurve_plot ;;
		510) calculate_powerspectrum ;;
		520) search_periodicity ;;
		530) fold_lightcurve ;;
		999) exit ;;
		default) ;;
	esac
	
	echo ""

done
##################################
#END OF MAIN LOOP
##################################
##################################
