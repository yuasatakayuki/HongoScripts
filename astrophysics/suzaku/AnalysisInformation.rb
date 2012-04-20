class AnalysisInformation
	ValueNotDefined=nil
	FileNotDefined=nil
	StringNotDefined=nil
	
	@targetname=StringNotDefined
	@detector=StringNotDefined
	@command=StringNotDefined
	@tagname=StringNotDefined
	@gtifile=FileNotDefined
	@regionfile=FileNotDefined
	@bintime=ValueNotDefined
	@pharange_lowerlimit=ValueNotDefined
	@pharange_upperlimit=ValueNotDefined
	@energyrange_lowerlimit=ValueNotDefined
	@energyrange_upperlimit=ValueNotDefined
	@phasefilter=false
	@phasefilter_epoch=ValueNotDefined
	@phasefilter_period=ValueNotDefined
	@phasefilter_phase=StringNotDefined
	@targetRA=ValueNotDefined
	@targetDec=ValueNotDefined
	@filteringcommandfile=StringNotDefined
	@dryrun=StringNotDefined

	attr_accessor :targetname
	attr_accessor :detector
	attr_accessor :command
	attr_accessor :tagname
	attr_accessor :gtifile
	attr_accessor :regionfile
	attr_accessor :bintime
	attr_accessor :pharange_lowerlimit
	attr_accessor :pharange_upperlimit
	attr_accessor :energyrange_lowerlimit
	attr_accessor :energyrange_upperlimit
	attr_accessor :phasefilter
	attr_accessor :phasefilter_epoch
	attr_accessor :phasefilter_period
	attr_accessor :phasefilter_phase
	attr_accessor :targetRA
	attr_accessor :targetDec
	attr_accessor :filteringcommandfile
	attr_accessor :dryrun
	
	def getAsHash()
		return {
					"targetname" => @targetname,
					"detector" => @detector,
					"command" => @command,
					"tagname" => @tagname,
					"gtifile" => @gtifile,
					"regionfile" => @regionfile,
					"bintime" => @bintime,
					"pharange_lowerlimit" => @pharange_lowerlimit,
					"pharange_upperlimit" => @pharange_upperlimit,
					"energyrange_lowerlimit" => @energyrange_lowerlimit,
					"energyrange_upperlimit" => @energyrange_upperlimit,
					"phasefilter_epoch" => @phasefilter_epoch,
					"phasefilter_period" => @phasefilter_period,
					"phasefilter_phase" => @phasefilter_phase,
					"targetRA" => @targetRA,
					"targetDec" => @targetDec,
					"filteringcommandfile" => @filteringcommandfile,
					"dryrun" => @dryrun
				}
	end
	
	def areAllMustOptionsSpecified()
		if(
			@detector==nil or @detector=="" or
			@command==nil or @command=="" or
			@tagname==nil or @tagname==""
		)then
			return false
		end
		return true
	end
	def saveTo(filename)
		document=REXML::Document.new()
		document.add(REXML::XMLDecl.new(version="1.0", encoding="UTF-8"))
		root_element = REXML::Element.new("suzaku_on_rails")
		document.add_element(root_element)
		root_element.add_text("sample7: サンプルデータです。")
		File.open(out_file_name,"w") do |outfile|
		    document.write(filename, 0)
		end
	end
end
