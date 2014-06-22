#20100217 Takayuki Yuasa dead-time correction added
#20100420 Takayuki Yuasa barycentric correction for phase-filtered extraction

class GSOAnalysis < HXDAnalysis
	def initialize(_analysisinformation)
		super(_analysisinformation)
	end
	
	def mergeGTIs()
		if(@analysisinformation.phasefilter==false)then
			evtfile=GSOFilenames::CleanedEventFile
			nxbfile=GSOFilenames::NXBFile
		else
			evtfile=GSOFilenames::CleanedEventFileBarycentricCorrected
			nxbfile=GSOFilenames::NXBFileBarycentricCorrected
		end
		commands=<<EOS
#merge cleanede event gti and nxb gti
pin_merge_gtis.sh \\
 "../data/#{evtfile}+2" \\
 "../data/#{nxbfile}+2" \\
 gtis/#{@tagname}/#{GSOFilenames::GTIOfCleanedEventMergedWithThatOfNXB}

EOS
		#merge extra gti if specified and exists
		if(@analysisinformation.gtifile!=nil and File.exist?(@analysisinformation.gtifile))then
			commands=commands+<<EOS
#create new GTI by merging cleaned event gti and specified gti
gtifile=gtis/#{@tagname}/#{GSOFilenames::MergedGTICreatedFromSpecifiedAndCleanedOnes}
pin_merge_gtis.sh \\
 gtis/#{@tagname}/#{GSOFilenames::GTIOfCleanedEventMergedWithThatOfNXB} \\
 #{@analysisinformation.gtifile} \\
 $gtifile

EOS
 		else
 			commands=commands+"gtifile=gtis/#{@tagname}/#{GSOFilenames::GTIOfCleanedEventMergedWithThatOfNXB}\n\n"
 		end
 		
 		return commands
	end
	
  #Spectrum
	def extractSpectrum(eventfile,pseudofile,outputspectrum)
		commands=<<EOS
#extract spectra
gso_extract_spectrum_with_gti.sh \\
 #{eventfile} \\
 #{pseudofile} \\
 $gtifile \\
 #{outputspectrum} \\
 extraconditions/#{@tagname}/#{HXDFilenames::ExtraEventFilteringConditionFile}
 
EOS
		return commands
	end
	def extractEventSpectrum()
		if(@analysisinformation.phasefilter==false)then
			return extractSpectrum("../data/#{GSOFilenames::CleanedEventFile}","../data/#{GSOFilenames::PseudoEventFile}","pis/#{@tagname}/#{GSOFilenames::SpectrumOfCleanedEvents}")
		else
			if(@analysisinformation.targetRA!=nil and @analysisinformation.targetDec!=nil)then
			 ra=@analysisinformation.targetRA
			 dec=@@analysisinformation.targetDec
			else
				ra=""
				dec=""
			end
			commands=<<EOS
#barycentric correction if needed
if [ ! -f ../data/#{GSOFilenames::CleanedEventFileBarycentricCorrected} ];
then
pushd ../ &> /dev/null
gso_barycentric_correction_auto.sh #{ra} #{dec}
popd &> /dev/null
fi
	
EOS
			return commands+extractSpectrum("../data/#{GSOFilenames::CleanedEventFileBarycentricCorrected}","../data/#{GSOFilenames::PseudoEventFileBarycentricCorrected}","pis/#{@tagname}/#{GSOFilenames::SpectrumOfCleanedEvents}")
		end
	end
	def extractNXBSpectrum()
		if(@analysisinformation.phasefilter==false)then
			return extractSpectrum("../data/#{GSOFilenames::NXBFile}","../data/#{GSOFilenames::PseudoEventFile}","nxbs/#{@tagname}/#{GSOFilenames::SpectrumOfNXB}")
		else
			return extractSpectrum("../data/#{GSOFilenames::NXBFileBarycentricCorrected}","../data/#{GSOFilenames::PseudoEventFileBarycentricCorrected}","nxbs/#{@tagname}/#{GSOFilenames::SpectrumOfNXB}")
		end
	end
	def findAndCopyResponseFile()
		commands=<<EOS
#find appropriate response,
#then copy it to local folder "responses/"
checkifexists=`ls responses/*rsp 2> /dev/null`
if [ _$checkifexists = _ ];
then
#not copied yet
responsefile_fullpath=`gso_find_responsefile_auto.sh pis/#{@tagname}/#{GSOFilenames::SpectrumOfCleanedEvents}`
responsefile=responses/`basename $responsefile_fullpath`
cp $responsefile_fullpath $responsefile
else
responsefile=`ls responses/*rsp`
fi

EOS
	end
	def createARFIfNeeded()
		commands=""
		if(@analysisinformation.targetRA!=nil and @analysisinformation.targetDec!=nil)then
			commands=<<EOS
#create point source arf
gso_create_auxiliary_response_file_for_pointsource.sh \\
pis/#{@tagname}/#{GSOFilenames::SpectrumOfCleanedEvents} \\
`ls ../auxil/ae*.att` \\
@analysisinformation.targetRA \\
@analysisinformation.targetDec \\
arfs/#{@tagname}/

arf=`ls arfs/#{@tagname}/*arf`

EOS
		else
			commands=<<EOS
#use default arf when no additional arf is specified.
arf=arfs/`gso_get_latest_arf.sh pis/#{@tagname}/#{GSOFilenames::SpectrumOfDeadtimeCorrectedCleanedEvents}`

EOS
		end
			return commands
	end
	def createSpectraCheckPlot()
		commands=""
		commands=commands+<<EOS
gso_create_spectra_check_plot.sh \\
 pis/#{@tagname}/#{GSOFilenames::SpectrumOfDeadtimeCorrectedCleanedEvents} \\
 nxbs/#{@tagname}/#{GSOFilenames::SpectrumOfDeadtimeCorrectedNXB} \\
 nxbs/#{@tagname}/#{GSOFilenames::SpectrumOf1PercentOfNXB} \\
 $responsefile \\
 plots/#{@tagname}/#{GSOFilenames::CheckPlotOfSpectra} \\
 $arf

EOS
		return commands
	end
	def createXCMForSpectralFitting()
		commands=<<EOS
#create an XCM file so that users can start
#spectral fitting soon after the spectral extraction
gso_create_xcm_for_spectral_fitting.sh \\
 pis/#{@tagname}/#{GSOFilenames::SpectrumOfDeadtimeCorrectedCleanedEvents} \\
 nxbs/#{@tagname}/#{GSOFilenames::SpectrumOfDeadtimeCorrectedNXB} \\
 $responsefile \\
 $arf \\
 none \\
 xcm/#{@tagname}/#{GSOFilenames::XCMLoadFilesForFitting}

EOS
		return commands
	end
	def checkCurrentFolder(current,assumed)
		if(current[-assumed.length-1,assumed.length]!=assumed)then
			raise "run this command in appropriate directory (current=#{current}, assumed=#{assumed})..."
		end
	end
	def createCommandsForExtractSpectra()
		checkCurrentFolder(`pwd`,"analysis/gso/spectral_analysis")
		commands="#!/bin/bash\n"
		commands=commands+setTargetNameIfSet()
		commands=commands+createWorkingFoldersForSpectralExtraction()
		commands=commands+mergeGTIs()
		commands=commands+createExtraFilteringConditionFile()
		commands=commands+extractEventSpectrum()
		commands=commands+extractNXBSpectrum()
		commands=commands+findAndCopyResponseFile()
		commands=commands+createARFIfNeeded()
		commands=commands+createSpectraCheckPlot()
		commands=commands+createXCMForSpectralFitting()
		return commands
	end
	def executeExtractSpectra()
		commands=createCommandsForExtractSpectra()
		scriptfile="scripts/#{@tagname}/extract_spectra.sh"
		saveCommandsToFile(scriptfile,commands)
		executeScriptFile(scriptfile)
	end

	#Lightcurve
	def createWorkingFoldersForLightcurveExtraction()
		commands=<<EOS
#create analysis folders
mkdir -p \\
lcfiles/#{@tagname} \\
gtis/#{@tagname} \\
extraconditions/#{@tagname} \\
dumps/#{@tagname} \\
plots/#{@tagname} \\
logs/#{@tagname} \\
scripts/#{@tagname} \\
tmp/#{@tagname}  \\
powerspectra/#{@tagname}  \\
folded_lcfiles/#{@tagname}  \\
&> /dev/null

EOS
		return commands
	end

	def extractLightcurves()
		commands=<<EOS
#extract lightcurve files
bintime=#{@analysisinformation.bintime}
gso_extract_lightcurve_with_gti.sh \\
 ../data/#{GSOFilenames::CleanedEventFile} \\
 ../data/#{GSOFilenames::NXBFile} \\
 ../data/#{GSOFilenames::PseudoEventFile} \\
 $gtifile \\
 lcfiles/#{@tagname}/gso \\
 ${bintime} \\
 extraconditions/#{@tagname}/#{HXDFilenames::ExtraEventFilteringConditionFile}
 
EOS
		return commands
	end
	def correctDeadtimeOfLightcurves()
		commands=<<EOS
#correct dead time
gso_lightcurve_correct_deadtime_and_nxb.sh \\
 lcfiles/#{@tagname}/gso_evt_bin${bintime}.lc \\
 lcfiles/#{@tagname}/gso_nxb_bin${bintime}.lc \\
 lcfiles/#{@tagname}/gso_pse_bin${bintime}.lc \\
 lcfiles/#{@tagname}/#{GSOFilenames::LightcurvePrefix}${bintime} \\
 ../auxil/ae*.ehk \\
 plots/#{@tagname}/#{GSOFilenames::LightcurvePrefix}${bintime}
 
EOS
	end
	def createCommandsForExtractLightcurves()
		if(@analysisinformation.bintime==nil)then
			raise "--bintime option is not specified although lightcurve extraction is executed..."
		end
		checkCurrentFolder(`pwd`,"analysis/gso/lightcurve_analysis")
		commands="#!/bin/bash\n"
		commands=commands+setTargetNameIfSet()
		commands=commands+createWorkingFoldersForLightcurveExtraction()
		commands=commands+mergeGTIs()
		commands=commands+createExtraFilteringConditionFile()
		commands=commands+extractLightcurves()
		commands=commands+correctDeadtimeOfLightcurves()
		return commands
	end
	def executeExtractLightcurves()
		commands=createCommandsForExtractLightcurves()
		scriptfile="scripts/#{@tagname}/extract_lightcurves.sh"
		saveCommandsToFile(scriptfile,commands)
		executeScriptFile(scriptfile)
	end
end
