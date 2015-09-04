
$debugXspecModule=false

module Xspec

module LogModules
# Represents a signle model component in a composite model.
class ModelComponentFitResult
  attr_accessor :modelComponentNumber, :modelName, :values
  
  def initialize
    @modelComponentNumber=0
    @modelName=""
    @values={} # map parameterName => [parameterNumber, value]
  end

  def to_s
    str=[]
    str << " Component #{@modelComponentNumber}: #{modelName}"
    @values.each(){|parameterName, array|
      str << "  #{array[0]} #{parameterName} = #{array[1]}"
    }
    return str.join("\n")
  end

  # Returns the best-fit value for _parameterName_.
  def getBestFitValue(parameterName)
    return @values[parameterName][1]
  end

  # Returns the parameter index for _parameterName_.
  def getParameterNumber(parameterName)
    return @values[parameterName][0]
  end

  # Sets error for the specified parameter.
  def setParameterError(parameterName,positiveError,negativeError)
    if(@values[parameterName].length<4)then
      @values[parameterName] << positiveError
      @values[parameterName] << negativeError
    else
      @values[parameterName][2]=positiveError
      @values[parameterName][3]=negativeError
    end
  end

  # Returns [positiveError, negativeError].
  def getParameterError(parameterName) 
    # if(@values[parameterName][2]==nil or @values[parameterName][3]==nil)then
    #   STDERR.puts "Warning: Component #{modelComponentNumber} #{modelName} #{parameterName} does not have error assigned"
    #   exit -1
    # end
    if(@values[parameterName][2]==nil or @values[parameterName][3]==nil)then
      return [nil, nil]
    end
    return [@values[parameterName][2],@values[parameterName][3]]
  end

  # Returns [parameterMin, parameterMax]
  def getParameterRange(parameterName)
    # if(@values[parameterName][2]==nil or @values[parameterName][3]==nil)then
    #   STDERR.puts "Error: Component #{modelComponentNumber} #{modelName} #{parameterName} does not have error assigned"
    #   exit -1
    # end
    if(@values[parameterName][2]==nil or @values[parameterName][3]==nil)then
      return [nil, nil]
    end
    return [@values[parameterName][1]+@values[parameterName][3],@values[parameterName][1]+@values[parameterName][2]]
  end
end

# Represents a fit result for a single data group.
# Contains multiple ModelComponentFitResult instances.
class DataGroupFitResult
  attr_accessor :modelComponents

  def initialize()
    @modelComponents={} # map modelComponentNumber => ModelComponentFitResult
  end

  # Add an parameter entry.
  def addParameterResult(parameterNumber, modelComponentNumber, modelName, parameterName, bestFitValue)
    if(@modelComponents[modelComponentNumber]==nil)then
      #STDERR.puts "Debug: modelComponentNumber = #{modelComponentNumber}, modelName = #{modelName} instantiated."
      modelComponent=ModelComponentFitResult.new
      @modelComponents[modelComponentNumber]=modelComponent
    end
    @modelComponents[modelComponentNumber].modelName=modelName
    @modelComponents[modelComponentNumber].modelComponentNumber=modelComponentNumber
    @modelComponents[modelComponentNumber].values[parameterName]=[parameterNumber, bestFitValue]
  end

  def to_s
    str=[]
    @modelComponents.each(){|modelComponentNumber, modelCompoenntFitResult|
      str << modelCompoenntFitResult.to_s
    }
    return str.join("\n")
  end

  # Returns the best-fit value for the specified model parameter.
  def getBestFitValue(modelComponentNumber, parameterName)
    return @modelComponents[modelComponentNumber].getBestFitValue(parameterName)
  end

  # Sets parameter error.
  def setParameterError(modelComponentNumber,paramterName,positiveError,negativeError)
    @modelComponents[modelComponentNumber].setParameterError(paramterName,positiveError,negativeError)
  end

  # Returns [positiveError, negativeError].
  def getParameterError(modelComponentNumber,paramterName) 
    return @modelComponents[modelComponentNumber].getParameterError(paramterName) 
  end

  # Returns [parameterMin, parameterMax]
  def getParameterRange(modelComponentNumber,paramterName)
    return @modelComponents[modelComponentNumber].getParameterRange(paramterName)
  end
end
end # end of module Log

#
#
#
# Manipulates fit log containing results of "show all", "error", and "flux" commands.
#
#
#
class Log
  def initialize
    @dataGroups=[]
    @parameterNumberMap={} #parameterNumber => {dataGroupIndex, modelComponentNumber, parameterName}
    @eqwEntries={}
    @redChi2=0
    @dof=0
    @nhp=0
  end

  # Constructs an instance from the provided log content.
  # _str_ can be a file name or string of log.
  def initialize(str)
    @dataGroups=[]
    @parameterNumberMap={} #parameterNumber => {dataGroupIndex, modelComponentNumber, parameterName}
    @eqwEntries={}
    @redChi2=0
    @dof=0
    @nhp=0

    load(str)
  end

  # Entry method for parsing a fit log string.
  def load(logString)
    if(File.exist?(logString))then
      loadFile(logString)
      return
    end
    logArray=logString.split("\n")
    if(logArray.count("#========================================================================")==0 or logArray.count("#________________________________________________________________________")==0)then
      STDERR.puts "Error: log file does not contain a result of 'show all'"
      exit -1
    end
    if(logArray.count("#========================================================================")!=1 or logArray.count("#________________________________________________________________________")!=1)then
      STDERR.puts "Error: the log file seems to contain multiple 'show all' restuls or fit resutl has been updated in error estimation."
      exit -1
    end
    
    fitResultString=logString.split("#========================================================================")[-1].split("#________________________________________________________________________")[0]
    parseFitResult(fitResultString)
    parseErrorEstimationPart(logString)
    parseEquivalentWidth(logString)
    parseFitStatistics(logString)
  end

  # Entry method for parsing a fit log.
  def loadFile(logFile)
    load(File.read(logFile))
  end
  alias parseLogFile loadFile

  private
  def parseFitResult(fitResultString)
    fitResultLines=fitResultString.split("\n")
    currentDataGroup=1
    currentDataGroupResult=LogModules::DataGroupFitResult.new
    fitResultLines.each_with_index(){|line,i|
      if(line.include?("Data group:"))then
        currentDataGroup=line.strip.split(":")[-1].strip.to_i
        if(currentDataGroupResult!=nil and currentDataGroupResult.modelComponents.length!=0)then
          if($debugXspecModule)then
            puts "Debug parameterNumber(): adding currentDataGroupResult to @dataGroups"
          end
          @dataGroups << currentDataGroupResult
          if($debugXspecModule)then
            puts "Debug parameterNumber(): @dataGroups=#{@dataGroups}"
          end
        end
        currentDataGroupResult = LogModules::DataGroupFitResult.new
        next
      end
      #process the best-fit values for a single data group
      for separator in ["+/-","frozen"] do
        if(currentDataGroup!=0 and line.include?(separator))then
          array=line.gsub(/^#/,"").gsub(/\s\s/," ").split(" ")
          parameterNumber=array[0].to_i
          modelComponentNumber=array[1].to_i
          modelName=array[2]
          parameterName=array[3]
          bestFitValue=line.split(separator)[0].split(" ")[-1].to_f
          if($debugXspecModule)then
            puts "Debug parseFitResult(): parameterName=#{parameterName} bestFitValue=#{bestFitValue} "
          end
          currentDataGroupResult.addParameterResult(parameterNumber, modelComponentNumber, modelName, parameterName, bestFitValue)
          if($debugXspecModule)then
            puts "Debug parseFitResult(): @parameterNumberMap[#{parameterNumber}]=#{{dataGroupIndex:currentDataGroup, modelComponentNumber:modelComponentNumber, parameterName:parameterName}}"
          end
          @parameterNumberMap[parameterNumber]={dataGroupIndex:currentDataGroup, modelComponentNumber:modelComponentNumber, parameterName:parameterName}
        end
      end
      #if this is the last line
      if(i==fitResultLines.length-1)then
        @dataGroups << currentDataGroupResult
      end
    }
  end

  private
  def parseErrorEstimationPart(logString)
    logString.each_line(){|line|
      if(line.match(/\(([\-\.0-9]+),([\-\.0-9]+)\)/))then
        negativeError=Regexp.last_match[1].to_f
        positiveError=Regexp.last_match[2].to_f
        array=line.strip.gsub(/^#/,"").gsub(/\s\s/," ").split(" ")
        parameterNumber=array[0].to_i
        parameterMin=array[1].to_f
        parameterMax=array[2].to_f
        if(parameterMin==0)then negativeError=0 end
        if(parameterMax==0)then postiveError=0 end
        # STDERR.puts "Debug: parameterNumber = #{parameterNumber}  error = (#{negativeError},#{positiveError})"
        setParameterError(parameterNumber,positiveError,negativeError)
      end
    }
  end

  private
  def setParameterError(parameterNumber,positiveError,negativeError)
    #puts "setParameterError(parameterNumber,positiveError,negativeError) = #{parameterNumber},#{positiveError},#{negativeError}"
    if($debugXspecModule)then
      puts "Debug setParameterError(): parameterNumber=#{parameterNumber} errp=#{positiveError} errm=#{negativeError}"
    end
    dataGroupIndex=@parameterNumberMap[parameterNumber][:dataGroupIndex]
    modelComponentNumber=@parameterNumberMap[parameterNumber][:modelComponentNumber]
    parameterName=@parameterNumberMap[parameterNumber][:parameterName]
    if($debugXspecModule)then
      puts "Debug setParameterError(): dataGroupIndex=#{dataGroupIndex} modelComponentNumber=#{modelComponentNumber} parameterName=#{parameterName}"
    end
    @dataGroups[dataGroupIndex-1].setParameterError(modelComponentNumber,parameterName,positiveError,negativeError)
  end

  private
  def parseEquivalentWidth(logString)
    insideEqwEntry=false
    nComponent=0
    logString.each_line(){|line|
      if(insideEqwEntry and line.include?("XSPEC") and line.include?("> "))then
        insideEqwEntry=false
      end

      if(!insideEqwEntry)then
        if(line.include?("XSPEC") and line.include?("> ") and line.include?("eqw"))then
          insideEqwEntry=true
          nComponent=line.split(" ")[2].to_i
          @eqwEntries[nComponent]={}
          next
        end
      end

      if(insideEqwEntry)then
        if(line.include?("Additive group equiv width"))then
          @eqwEntries[nComponent][:eqw]=line.split(" ")[-2].to_f*1000
        end

        if(line.include?("Equiv width error range"))then
          @eqwEntries[nComponent][:eqwMin]=line.split(" ")[-4].to_f*1000
          @eqwEntries[nComponent][:eqwMax]=line.split(" ")[-2].to_f*1000
        end
      end
    }
  end

  private
  def parseFitStatistics(logString)
    redChi2Lines=[]
    nhpLines=[]
    logString.each_line(){|line|
      # redChi2 lines
      if(line.include?("Reduced chi-squared = ") and line.include?(" degrees of freedom "))then
        redChi2Lines << line
      end
      #nhp lines
      if(line.include?("Null hypothesis probability ="))then
        nhpLines << line
      end
    }
    if(redChi2Lines[-1]!=nil)then
      @redChi2=redChi2Lines[-1].split("=")[1].split("for")[0].to_f
      @dof=redChi2Lines[-1].split("for")[1].split("degrees")[0].to_f
    end
    if(nhpLines[-1]!=nil)then
      @nhp=nhpLines[-1].split(" ")[-1].to_f
    end
  end

  private
  # Returns the best-fit value of the specified parameter.
  def getParameterFor(dataGroupIndex, modelComponentNumber, parameterName)
    return @dataGroups[dataGroupIndex-1].getBestFitValue(modelComponentNumber, parameterName)
  end

  public
  # Returns the best-fit value for the specified parameter number.
  # The hash should contain { parameter: parameter_number }.
  def getParameter(hash)
    parameterNumber=getParameterNumberFromHash(hash)
    dataGroupIndex=@parameterNumberMap[parameterNumber][:dataGroupIndex]
    modelComponentNumber=@parameterNumberMap[parameterNumber][:modelComponentNumber]
    parameterName=@parameterNumberMap[parameterNumber][:parameterName]
    return getParameterFor(dataGroupIndex, modelComponentNumber, parameterName)
  end

  alias getBestFitValue getParameter 

  private
  # Returns [positiveError, negativeError].
  def getParameterErrorFor(dataGroupIndex,modelComponentNumber,paramterName) 
    return @dataGroups[dataGroupIndex-1].getParameterError(modelComponentNumber,paramterName) 
  end

  public
  # Returns [positiveError, negativeError].
  # The hash should contain { parameter: parameter_number }.
  def getParameterError(hash)
    parameterNumber=getParameterNumberFromHash(hash)
    dataGroupIndex=@parameterNumberMap[parameterNumber][:dataGroupIndex]
    modelComponentNumber=@parameterNumberMap[parameterNumber][:modelComponentNumber]
    parameterName=@parameterNumberMap[parameterNumber][:parameterName]
    return getParameterErrorFor(dataGroupIndex, modelComponentNumber, parameterName)
  end

  private
  # Returns [parameterMin, parameterMax]
  def getParameterRangeFor(dataGroupIndex,modelComponentNumber,paramterName)
    return @dataGroups[dataGroupIndex-1].getParameterRange(modelComponentNumber,paramterName)
  end

  public
  # Returns [parameterMin, parameterMax]
  # The hash should contain { parameter: parameter_number }.
  def getParameterRange(hash)
    parameterNumber=getParameterNumberFromHash(hash)
    dataGroupIndex=@parameterNumberMap[parameterNumber][:dataGroupIndex]
    modelComponentNumber=@parameterNumberMap[parameterNumber][:modelComponentNumber]
    parameterName=@parameterNumberMap[parameterNumber][:parameterName]
    return getParameterRangeFor(dataGroupIndex, modelComponentNumber, parameterName)
  end

  # Returns fit value and errors in TeX style.
  def getParameterTeX(hash)
    parameterNumber=getParameterNumberFromHash(hash)
    precision=(hash[:precision])? hash[:precision]:3
    dataGroupIndex=@parameterNumberMap[parameterNumber][:dataGroupIndex]
    modelComponentNumber=@parameterNumberMap[parameterNumber][:modelComponentNumber]
    parameterName=@parameterNumberMap[parameterNumber][:parameterName]
    value=getParameter(hash)
    errors=getParameterErrorFor(dataGroupIndex, modelComponentNumber, parameterName)
    errp=errors[0]
    errm=errors[1]
    if(errp==0 || errp==value)then
      return ">%.#{precision}f" % [value+errm]
    elsif(errm==0 || errm==value)then
      return "<%.#{precision}f" % [value+errp]
    elsif(errp==nil and errm==nil)then
      return "%.#{precision}f" % [value]
    else
      return "%.#{precision}f^{+%.#{precision}f}_{%.#{precision}f}" % [value, errp, errm]
    end
  end    

  # Returns fit value and errors in TeX style.
  def getParameterGnuplot(hash)
    parameterNumber=getParameterNumberFromHash(hash)
    precision=(hash[:precision])? hash[:precision]:3
    dataGroupIndex=@parameterNumberMap[parameterNumber][:dataGroupIndex]
    modelComponentNumber=@parameterNumberMap[parameterNumber][:modelComponentNumber]
    parameterName=@parameterNumberMap[parameterNumber][:parameterName]
    value=getParameter(hash)
    min,max=getParameterRangeFor(dataGroupIndex, modelComponentNumber, parameterName)
    if(min==nil and max==nil)then
      return "%.#{precision}f %.#{precision}f %.#{precision}f" % [value, 0, 0]
    else
      return "%.#{precision}f %.#{precision}f %.#{precision}f" % [value, min, max]
    end
  end    

  private
  def getParameterNumberFromHash(hash)
    if(hash[:parameter]!=nil)then
      parameterNumber=hash[:parameter]
    elsif(hash[:param]!=nil)then
      parameterNumber=hash[:param]
    else
      STDERR.puts "Error: parameter number was not provided. e.g. getParameterTeX(parameter: 6, precision: 3)"
      exit -1
    end
    return parameterNumber
  end

  def getModelComponentNumberFromHash(hash)
    if(hash[:model]!=nil)then
      return hash[:model]
    elsif(hash[:comp]!=nil)then
      return hash[:comp]
    else
      STDERR.puts "Error: please provide model component number (e.g. getEWTeX(model: 3) or getEWTeX(comp: 3) "
    end
  end

  public
  # Returns equivalent width.
  def getEW(modelComponentNumber)
    return @eqwEntries[modelComponentNumber][:eqw]
  end

  # Returns equivalent width [positiveError, negativeError].
  def getEWError(modelComponentNumber)
    ew=@eqwEntries[modelComponentNumber][:eqw]
    min=@eqwEntries[modelComponentNumber][:eqwMin]
    max=@eqwEntries[modelComponentNumber][:eqwMax]
    if(min==nil and max==nil)then
      return [0,0]
    else
      return [max-ew, min-ew]
    end
  end

  # Returns equivalent width range [eqwMin, eqwMax]
  def getEWRange(modelComponentNumber)
    min=@eqwEntries[modelComponentNumber][:eqwMin]
    max=@eqwEntries[modelComponentNumber][:eqwMax]
    return [min, max]
  end

  # Returns equivalent width and errors in TeX style.
  def getEWTeX(hash)
    modelComponentNumber=getModelComponentNumberFromHash(hash)
    value=getEW(modelComponentNumber)
    precision=(hash[:precision])? hash[:precision]:3
    errp,errm=getEWError(modelComponentNumber)
    return "%.#{precision}f^{+%.#{precision}f}_{%.#{precision}f}" % [value, errp, errm]
  end    

  # Returns equivalent width and errors in TeX style.
  def getEWGnuplot(hash)
    modelComponentNumber=getModelComponentNumberFromHash(hash)
    value=getEW(modelComponentNumber)
    precision=(hash[:precision])? hash[:precision]:3
    min,max=getEWRange(modelComponentNumber)
    if(min==nil and max==nil)then
      return "%.#{precision}f %.#{precision}f %.#{precision}f" % [value, 0, 0]
    else
      return "%.#{precision}f %.#{precision}f %.#{precision}f" % [value, min, max]
    end
  end

  public
  def getReducedChi2()
    return @redChi2
  end

  def getChi2()
    return @redChi2*@dof
  end

  def getDOF()
    return @dof
  end

  def getNHP()
    return @nhp
  end

  def getProb()
    return @nhp
  end

  def to_s
    str=[]
    #fit parameters
    @dataGroups.each_with_index(){|dataGroup,i|
      str << "============================================"
      str << "Data group #{i+1}"
      str << "============================================"
      str << dataGroup
    }
    str << ""
    #fit statistics
    str << "============================================"
    str << "Fit statistics"
    str << "============================================"
    str << "  Reduced chi-square = #{@redChi2}"
    str << "N. degree of freedom = #{@dof}"
    str << "              N.H.P. = #{@nhp}"
    str << ""
    #fluxes
    str << "============================================"
    str << "Flux"
    str << "============================================"
    @eqwEntries.each(){|k,v|
      str << "#{k} => #{v}"
    }
    return str.join("\n")
  end
end

end