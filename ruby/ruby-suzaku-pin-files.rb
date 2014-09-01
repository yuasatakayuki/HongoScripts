class PINFilenames < HXDFilenames
	#Event Files
	CleanedEventFile="pin_evt.evt"
	CleanedEventFileBarycentricCorrected="pin_evt_barycentric_correction.evt"
	NXBFile="pin_nxb.evt"
	NXBFileBarycentricCorrected="pin_nxb_barycentric_correction.evt"
	PseudoEventFile="pseudo.evt"
	PseudoEventFileBarycentricCorrected="pseudo_barycentric_correction.evt"
	UnfilteredFile="uff.evt"
	
	#GTIs
	GTIOfCleanedEventMergedWithThatOfNXB="cleaned_evt_nxb_merged.gti"
	MergedGTICreatedFromSpecifiedAndCleanedOnes="cleaned_and_specified_merged.gti"
	
	#Output Spectra
	SpectrumOfCleanedEvents="pin_evt.pi"
	SpectrumOfNXB="pin_nxb.pi"
	SpectrumOfCXB="cxb.fake"
	SpectrumOfDeadtimeCorrectedCleanedEvents="pin_evt_dtcor_bin20.pi"
	SpectrumOfRescaledNXB="pin_nxb_times10.pi"
	SpectrumOf5PercentOfNXB="pin_nxb_times200.pi"
	
	#Output Lightcurves
	LightcurvePrefix="pin_lightcurves_bin"
	
	#Output XCMs
	XCMLoadFilesForFitting="load_files.xcm"
	
	#Check Plots
	ExtraQDPCommandFileForCheckPlot="extraqdpcommands.pco"
	CheckPlotOfSpectra="checkplot_spectra.pdf"
	CheckPlotOfGTI="checkplot_gti.pdf"
	CheckPlotOfLightcurves="checkplot_gti.pdf"
	
	#Summary of each Process
	SummaryOfExtractSpectra="summary_extract_spectra.pdf"
	SummaryOfExtractLightcurves="summary_extract_lightcurves.pdf"
	
end
