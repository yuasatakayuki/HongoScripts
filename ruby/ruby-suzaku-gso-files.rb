class GSOFilenames < HXDFilenames
	#Event Files
	CleanedEventFile="gso_evt.evt"
	CleanedEventFileBarycentricCorrected="gso_evt_barycentric_correction.evt"
	NXBFile="gso_nxb.evt"
	NXBFileBarycentricCorrected="gso_nxb_barycentric_correction.evt"
	PseudoEventFile="pseudo.evt"
	PseudoEventFileBarycentricCorrected="pseudo_barycentric_correction.evt"
	UnfilteredFile="uff_repro.evt"
	
	#GTIs
	GTIOfCleanedEventMergedWithThatOfNXB="cleaned_evt_nxb_merged.gti"
	MergedGTICreatedFromSpecifiedAndCleanedOnes="cleaned_and_specified_merged.gti"
	
	#Output Spectra
	SpectrumOfCleanedEvents="gso_evt.pi"
	SpectrumOfNXB="gso_nxb.pi"
	SpectrumOfCXB="cxb.fake"
	SpectrumOfDeadtimeCorrectedCleanedEvents="gso_evt_dtcor_binGSO.pi"
	SpectrumOfDeadtimeCorrectedNXB="gso_nxb_dtcor.pi"
	SpectrumOf1PercentOfNXB="gso_nxb_times100.pi"
	
	#Output Lightcurves
	LightcurvePrefix="gso_lightcurves_bin"
	
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
