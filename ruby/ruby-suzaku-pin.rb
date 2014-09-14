#20100420 Takayuki Yuasa barycentric correction for phase-filtered extraction

class PINAnalysis < HXDAnalysis
	def initialize(_analysisinformation)
		super(_analysisinformation)
	end
	
	def mergeGTIs()
		if(@analysisinformation.phasefilter==false)then
			evtfile=PINFilenames::CleanedEventFile
			nxbfile=PINFilenames::NXBFile
		else
			evtfile=PINFilenames::CleanedEventFileBarycentricCorrected
			nxbfile=PINFilenames::NXBFileBarycentricCorrected
		end
		commands=<<EOS
#merge cleanede event gti and nxb gti
hsPINMergeGTI \\
 "../data/#{evtfile}+2" \\
 "../data/#{nxbfile}+2" \\
 gtis/#{@tagname}/#{PINFilenames::GTIOfCleanedEventMergedWithThatOfNXB}

EOS
		#merge extra gti if specified and exists
		if(@analysisinformation.gtifile!=nil and File.exist?(@analysisinformation.gtifile))then
			commands=commands+<<EOS
#create new GTI by merging cleaned event gti and specified gti
gtifile=gtis/#{@tagname}/#{PINFilenames::MergedGTICreatedFromSpecifiedAndCleanedOnes}
hsPINMergeGTI \\
 gtis/#{@tagname}/#{PINFilenames::GTIOfCleanedEventMergedWithThatOfNXB} \\
 #{@analysisinformation.gtifile} \\
 $gtifile

EOS
 		else
 			commands=commands+"gtifile=gtis/#{@tagname}/#{PINFilenames::GTIOfCleanedEventMergedWithThatOfNXB}\n\n"
 		end
 		
 		return commands
	end
	
  #Spectrum
	def extractSpectrum(eventfile,pseudofile,outputspectrum)
		commands=<<EOS
#extract spectra
hsPINExtractSpectrumWithGTI \\
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
			return extractSpectrum("../data/#{PINFilenames::CleanedEventFile}","../data/#{PINFilenames::PseudoEventFile}","pis/#{@tagname}/#{PINFilenames::SpectrumOfCleanedEvents}")
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
if [ ! -f ../data/#{PINFilenames::CleanedEventFileBarycentricCorrected} ];
then
pushd ../ &> /dev/null
hsPINBarycentriCorrectionAuto #{ra} #{dec}
popd &> /dev/null
fi
	
EOS
			return commands+extractSpectrum("../data/#{PINFilenames::CleanedEventFileBarycentricCorrected}","../data/#{PINFilenames::PseudoEventFileBarycentricCorrected}","pis/#{@tagname}/#{PINFilenames::SpectrumOfCleanedEvents}")
		end
	end
	def extractNXBSpectrum()
		if(@analysisinformation.phasefilter==false)then
			return extractSpectrum("../data/#{PINFilenames::NXBFile}","none","nxbs/#{@tagname}/#{PINFilenames::SpectrumOfNXB}")
		else
			return extractSpectrum("../data/#{PINFilenames::NXBFileBarycentricCorrected}","none","nxbs/#{@tagname}/#{PINFilenames::SpectrumOfNXB}")
		end
	end
	def fakeCXBSpectrum()
		commands=<<EOS
#fake cxb spectrum using Boldt 1987
#see http://heasarc.gsfc.nasa.gov/docs/suzaku/analysis/pin_cxb.html
hsPINFakeCXBAuto \\
 ../data/#{PINFilenames::CleanedEventFile} \\
 cxbs/#{@tagname}/#{PINFilenames::SpectrumOfCXB}

EOS
		return commands
	end
	def findAndCopyResponseFile()
		commands=<<EOS
#find appropriate response,
#then copy it to local folder "responses/"
checkifexists=`ls responses/*rsp 2> /dev/null`
if [ _$checkifexists = _ ];
then
#not copied yet
responsefile_fullpath=`hsPINFindResponseFileAuto pis/#{@tagname}/#{PINFilenames::SpectrumOfCleanedEvents}`
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
hsPINCreateARFForPointSource \\
pis/#{@tagname}/#{PINFilenames::SpectrumOfCleanedEvents} \\
`ls ../auxil/ae*.att` \\
@analysisinformation.targetRA \\
@analysisinformation.targetDec \\
arfs/#{@tagname}/

arf=`ls arfs/#{@tagname}/*arf`

EOS
		else
			commands=<<EOS
#no arf is required.
arf=none

EOS
		end
			return commands
	end
	def createSpectraCheckPlot()
		commands=""
		commands=commands+<<EOS
hsPINCreateSpectrumCheckPlot \\
 pis/#{@tagname}/#{PINFilenames::SpectrumOfDeadtimeCorrectedCleanedEvents} \\
 nxbs/#{@tagname}/#{PINFilenames::SpectrumOfRescaledNXB} \\
 nxbs/#{@tagname}/#{PINFilenames::SpectrumOf5PercentOfNXB} \\
 $responsefile \\
 plots/#{@tagname}/#{PINFilenames::CheckPlotOfSpectra}

EOS
		return commands
	end
	def createXCMForSpectralFitting()
		commands=<<EOS
#create an XCM file so that users can start
#spectral fitting soon after the spectral extraction
hsPINCreateXCMForSpectralFitting \\
 pis/#{@tagname}/#{PINFilenames::SpectrumOfDeadtimeCorrectedCleanedEvents} \\
 nxbs/#{@tagname}/#{PINFilenames::SpectrumOfRescaledNXB} \\
 $responsefile \\
 $arf \\
 cxbs/#{@tagname}/#{PINFilenames::SpectrumOfCXB} \\
 xcm/#{@tagname}/#{PINFilenames::XCMLoadFilesForFitting}

EOS
		return commands
	end
	def checkCurrentFolder(current,assumed)
		if(current[-assumed.length-1,assumed.length]!=assumed)then
			raise "run this command in appropriate directory (current=#{current}, assumed=#{assumed})..."
		end
	end
	def createCommandsForExtractSpectra()
		checkCurrentFolder(`pwd`,"analysis/pin/spectral_analysis")
		commands="#!/bin/bash\n"
		commands=commands+setTargetNameIfSet()
		commands=commands+createWorkingFoldersForSpectralExtraction()
		commands=commands+mergeGTIs()
		commands=commands+createExtraFilteringConditionFile()
		commands=commands+extractEventSpectrum()
		commands=commands+extractNXBSpectrum()
		commands=commands+findAndCopyResponseFile()
		commands=commands+createARFIfNeeded()
		commands=commands+fakeCXBSpectrum()
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
hsPINExtractLightcurveWithGTI \\
 ../data/#{PINFilenames::CleanedEventFile} \\
 ../data/#{PINFilenames::NXBFile} \\
 ../data/#{PINFilenames::PseudoEventFile} \\
 $gtifile \\
 lcfiles/#{@tagname}/pin \\
 ${bintime} \\
 extraconditions/#{@tagname}/#{HXDFilenames::ExtraEventFilteringConditionFile}
 
EOS
		return commands
	end
	def correctDeadtimeOfLightcurves()
		commands=<<EOS
#correct dead time
hsPINLightcurveCorrectDeadTimeAndNXB \\
 lcfiles/#{@tagname}/pin_evt_bin${bintime}.lc \\
 lcfiles/#{@tagname}/pin_nxb_bin${bintime}.lc \\
 lcfiles/#{@tagname}/pin_pse_bin${bintime}.lc \\
 lcfiles/#{@tagname}/#{PINFilenames::LightcurvePrefix}${bintime} \\
 ../auxil/ae*.ehk \\
 plots/#{@tagname}/#{PINFilenames::LightcurvePrefix}${bintime}
 
EOS
	end
	def createCommandsForExtractLightcurves()
		if(@analysisinformation.bintime==nil)then
			raise "--bintime option is not specified although lightcurve extraction is executed..."
		end
		checkCurrentFolder(`pwd`,"analysis/pin/lightcurve_analysis")
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
