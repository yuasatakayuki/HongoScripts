require "RubyFits"
include Fits

# Open apec-resulting FITS files
#lineFile=FitsFile.open("apec_line.fits")
#cocoFile=FitsFile.open("apec_coco.fits")

#parametersHDU=lineFile[0]

filename="apec_line.fits"

# Calculation parameters
keywords = { 
	"Continuum calculation" => 
		{ "HIERARCH SBREMS_TYPE" => "Bremss type" },
	"Spectral calculation" =>
		{
			"INUM_E" => "Number of energy bins", 
			"DE_START" => "Lowest energy",
			"DE_END" => "Highest energy",
		},
	"Densities" =>
		{
			"HIERARCH INUM_DENSITIES" => "Number of density grid",
			"HIERARCH DDENSITY_START" => "Log10 (start density)",
			"HIERARCH DDENSITY_STEP" => "Log10 (density step)"
		},
	"Temperatures" =>
		{
			"HIERARCH INUM_TEMP" => "Number of temperatures",
			"HIERARCH DTEMP_START" => "Log10 (start temperature)",
			"HIERARCH DTEMP_STEP" => "Log10 (temperature step)"
		}
	}


# Get and dump header entries
keywords.each(){|category,keyTitleMap|
	puts "## #{category}"
	puts ""
	keyTitleMap.each(){|key,title|
		#key=key.gsub("HIERARCH ","")
		value=`fkeyprint #{filename}+0 "#{key}" 2>/dev/null | grep "=" | grep "#{key.split(" ")[-1]}" | tail -1 | sed -e "s/'//g"`
		if(value!=nil)then
			value=value.split("=")[1]
		end
		if(value!=nil)then
			value=value.split("/")[0]
		end
		if(value!=nil)then
			value.strip!()
		end
		puts "- #{title}: #{value}"
	}
	puts ""
}


# Close files
#lineFile.close()
#cocoFile.close()