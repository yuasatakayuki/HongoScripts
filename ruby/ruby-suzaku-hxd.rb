# 2010...  created first vertion.        Yuasa 
# 2010/6.7 included GSO energy to pi     S. Yamada
class HXDAnalysis
	@analysisinformation
	@tagname
	def initialize(_analysisinformation)
		@analysisinformation=_analysisinformation
		@tagname=@analysisinformation.tagname
	end
	def createWorkingFoldersForSpectralExtraction()
		commands=<<EOS
#create analysis folders
mkdir -p \\
arfs/#{@tagname} \\
gtis/#{@tagname} \\
pis/#{@tagname} \\
plots/#{@tagname} \\
extraconditions/#{@tagname} \\
cxbs/#{@tagname} \\
xcm/#{@tagname} \\
logs/#{@tagname} \\
scripts/#{@tagname} \\
tmp/#{@tagname}  \\
&> /dev/null

EOS
		return commands
	end
	def setTargetNameIfSet()
		commands=""
		if(@analysisinformation.targetname!=nil)then
			commands=<<EOS
#set target name shown in plots
export HS_Target_Name_Long="#{@analysisinformation.targetname}"

EOS
		else
			commands
		end
		return commands
	end
	def createExtraFilteringConditionFile()
		#filtering commands applied in XSELCT
		filteringcommands=""
		
		#energy selection for PIN
		if(
			@analysisinformation.energyrange_upperlimit!=nil and
			@analysisinformation.energyrange_lowerlimit!=nil and 
                        @analysisinformation.detector=="pin"
		)then
			pha_upperlimit=`pin_energy_to_pi.sh #{@analysisinformation.energyrange_upperlimit}`.to_i()
			pha_lowerlimit=`pin_energy_to_pi.sh #{@analysisinformation.energyrange_lowerlimit}`.to_i()
			filteringcommands=filteringcommands+"filter pha_cut #{pha_lowerlimit} #{pha_upperlimit}\n"
		end


		#energy selection for GSO
		if(
			@analysisinformation.energyrange_upperlimit!=nil and
			@analysisinformation.energyrange_lowerlimit!=nil and 
                        @analysisinformation.detector=="gso"
		)then
			pha_upperlimit=`gso_energy_to_pi.sh #{@analysisinformation.energyrange_upperlimit}`.to_i()
			pha_lowerlimit=`gso_energy_to_pi.sh #{@analysisinformation.energyrange_lowerlimit}`.to_i()
			filteringcommands=filteringcommands+"filter pha_cut #{pha_lowerlimit} #{pha_upperlimit}\n"
		end


		
		#pha selection
		if(
			@analysisinformation.pharange_lowerlimit!=nil and
			@analysisinformation.pharange_upperlimit!=nil
		)then
			pha_upperlimit=@analysisinformation.pharange_upperlimit
			pha_lowerlimit=@analysisinformation.pharange_lowerlimit
			filteringcommands=filteringcommands+"filter pha_cut #{pha_lowerlimit} #{pha_upperlimit}\n"
		end
		
		#phase filtering
		if(
			@analysisinformation.phasefilter_epoch!=nil and
			@analysisinformation.phasefilter_period!=nil and
			@analysisinformation.phasefilter_phase!=nil
		)then
			epoch=@analysisinformation.phasefilter_epoch
			period=@analysisinformation.phasefilter_period
			phase=@analysisinformation.phasefilter_phase
			filteringcommands=filteringcommands+"filter phase #{epoch} #{period} #{phase}\n"
		end
		
		#return
		if(filteringcommands!="")then
			commands=<<EOS
#create extra filtering condition file
extraconditionfile=extraconditions/#{@tagname}/#{HXDFilenames::ExtraEventFilteringConditionFile}
cat << EOF > $extraconditionfile
#{filteringcommands}

EOF

EOS
			return commands
		else
			return ""
		end
	end
	#Common
	def saveCommandsToFile(filename,commands)
		begin
			checkAndCreateFolder(filename)
			file=File.open(filename,'w')
			file.puts commands
			file.close()
		rescue
			print "cannot create script file #{filename}...\n"
		end
	end
	def checkAndCreateFolder(filename)
		if(!File.directory?(File.dirname(filename)))then
			path=File.dirname(filename)
			FileUtils.mkdir_p(path)
		end
	end
	def executeScriptFile(scriptfile)
		if(@analysisinformation.dryrun!="true")then
			basename=File.basename(scriptfile,".*")
			logfile="logs/#{@tagname}/#{basename}.log"
			checkAndCreateFolder(logfile)
			if(!File.exist?(logfile))then
				print "log file #{@logfile} is newly created...\n"
				`touch #{logfile}`
			end
			STDOUT.print "executing, wait for while"
			STDOUT.flush()
			showProgress=true
			progressThread=Thread.new do
				while(showProgress)do
					sleep 1
					STDOUT.print "."
					STDOUT.flush()
				end
			end
			system("bash #{scriptfile} >> #{logfile} 2>> #{logfile}")
			showProgress=false
			progressThread.join()
			STDOUT.print "completed\n"
			STDOUT.flush()
		else
			print "The command #{@analysisinformation.command} is not really executed because of --dryrun true option. \n"
			print "You might see resulting scripts inside scripts/#{@tagname} folder.\n"
		end
	end
	def executeCommand()
		if(@analysisinformation.command=="extract_spectra")then
			begin
				executeExtractSpectra()
			rescue => exception
				print "Exception!\n"
				print "#{exception}\n"
				showAppropriateDirectoryThenExit()
			end
		elsif(@analysisinformation.command=="extract_lightcurves")then
			begin
				executeExtractLightcurves()
			rescue => exception
				print "Exception!\n"
				print "#{exception}\n"
				showAppropriateDirectoryThenExit()
			end
		else
			raise "command '#{@analysisinformation.command}' is not implemented..."
		end
	end
end
