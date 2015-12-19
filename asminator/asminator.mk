##
## Auto Generated makefile by CodeLite IDE
## any manual changes will be erased      
##
## Release
ProjectName            :=asminator
ConfigurationName      :=Release
WorkspacePath          := "/home/mgohde/codeliteworkspace"
ProjectPath            := "/home/mgohde/codeliteworkspace/asminator"
IntermediateDirectory  :=./Release
OutDir                 := $(IntermediateDirectory)
CurrentFileName        :=
CurrentFilePath        :=
CurrentFileFullPath    :=
User                   :=mgohde
Date                   :=27/11/15
CodeLitePath           :="/home/mgohde/.codelite"
LinkerName             :=/usr/bin/clang++
SharedObjectLinkerName :=/usr/bin/clang++ -shared -fPIC
ObjectSuffix           :=.o
DependSuffix           :=.o.d
PreprocessSuffix       :=.i
DebugSwitch            :=-g 
IncludeSwitch          :=-I
LibrarySwitch          :=-l
OutputSwitch           :=-o 
LibraryPathSwitch      :=-L
PreprocessorSwitch     :=-D
SourceSwitch           :=-c 
OutputFile             :=$(IntermediateDirectory)/$(ProjectName)
Preprocessors          :=$(PreprocessorSwitch)NDEBUG 
ObjectSwitch           :=-o 
ArchiveOutputSwitch    := 
PreprocessOnlySwitch   :=-E
ObjectsFileList        :="asminator.txt"
PCHCompileFlags        :=
MakeDirCommand         :=mkdir -p
LinkOptions            :=  
IncludePath            :=  $(IncludeSwitch). $(IncludeSwitch). 
IncludePCH             := 
RcIncludePath          := 
Libs                   := 
ArLibs                 :=  
LibPath                := $(LibraryPathSwitch). 

##
## Common variables
## AR, CXX, CC, AS, CXXFLAGS and CFLAGS can be overriden using an environment variables
##
AR       := /usr/bin/ar rcu
CXX      := /usr/bin/clang++
CC       := /usr/bin/clang
CXXFLAGS :=  -O2 -Wall $(Preprocessors)
CFLAGS   :=  -O2 -Wall $(Preprocessors)
ASFLAGS  := 
AS       := /usr/bin/as


##
## User defined environment variables
##
CodeLiteDir:=/usr/share/codelite
Objects0=$(IntermediateDirectory)/main.cpp$(ObjectSuffix) $(IntermediateDirectory)/opdefs.cpp$(ObjectSuffix) $(IntermediateDirectory)/assembler.cpp$(ObjectSuffix) $(IntermediateDirectory)/parser.cpp$(ObjectSuffix) $(IntermediateDirectory)/token.cpp$(ObjectSuffix) 



Objects=$(Objects0) 

##
## Main Build Targets 
##
.PHONY: all clean PreBuild PrePreBuild PostBuild MakeIntermediateDirs
all: $(OutputFile)

$(OutputFile): $(IntermediateDirectory)/.d $(Objects) 
	@$(MakeDirCommand) $(@D)
	@echo "" > $(IntermediateDirectory)/.d
	@echo $(Objects0)  > $(ObjectsFileList)
	$(LinkerName) $(OutputSwitch)$(OutputFile) @$(ObjectsFileList) $(LibPath) $(Libs) $(LinkOptions)

MakeIntermediateDirs:
	@test -d ./Release || $(MakeDirCommand) ./Release


$(IntermediateDirectory)/.d:
	@test -d ./Release || $(MakeDirCommand) ./Release

PreBuild:


##
## Objects
##
$(IntermediateDirectory)/main.cpp$(ObjectSuffix): main.cpp $(IntermediateDirectory)/main.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "/home/mgohde/codeliteworkspace/asminator/main.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/main.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/main.cpp$(DependSuffix): main.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/main.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/main.cpp$(DependSuffix) -MM "main.cpp"

$(IntermediateDirectory)/main.cpp$(PreprocessSuffix): main.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/main.cpp$(PreprocessSuffix) "main.cpp"

$(IntermediateDirectory)/opdefs.cpp$(ObjectSuffix): opdefs.cpp $(IntermediateDirectory)/opdefs.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "/home/mgohde/codeliteworkspace/asminator/opdefs.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/opdefs.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/opdefs.cpp$(DependSuffix): opdefs.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/opdefs.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/opdefs.cpp$(DependSuffix) -MM "opdefs.cpp"

$(IntermediateDirectory)/opdefs.cpp$(PreprocessSuffix): opdefs.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/opdefs.cpp$(PreprocessSuffix) "opdefs.cpp"

$(IntermediateDirectory)/assembler.cpp$(ObjectSuffix): assembler.cpp $(IntermediateDirectory)/assembler.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "/home/mgohde/codeliteworkspace/asminator/assembler.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/assembler.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/assembler.cpp$(DependSuffix): assembler.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/assembler.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/assembler.cpp$(DependSuffix) -MM "assembler.cpp"

$(IntermediateDirectory)/assembler.cpp$(PreprocessSuffix): assembler.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/assembler.cpp$(PreprocessSuffix) "assembler.cpp"

$(IntermediateDirectory)/parser.cpp$(ObjectSuffix): parser.cpp $(IntermediateDirectory)/parser.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "/home/mgohde/codeliteworkspace/asminator/parser.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/parser.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/parser.cpp$(DependSuffix): parser.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/parser.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/parser.cpp$(DependSuffix) -MM "parser.cpp"

$(IntermediateDirectory)/parser.cpp$(PreprocessSuffix): parser.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/parser.cpp$(PreprocessSuffix) "parser.cpp"

$(IntermediateDirectory)/token.cpp$(ObjectSuffix): token.cpp $(IntermediateDirectory)/token.cpp$(DependSuffix)
	$(CXX) $(IncludePCH) $(SourceSwitch) "/home/mgohde/codeliteworkspace/asminator/token.cpp" $(CXXFLAGS) $(ObjectSwitch)$(IntermediateDirectory)/token.cpp$(ObjectSuffix) $(IncludePath)
$(IntermediateDirectory)/token.cpp$(DependSuffix): token.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) -MG -MP -MT$(IntermediateDirectory)/token.cpp$(ObjectSuffix) -MF$(IntermediateDirectory)/token.cpp$(DependSuffix) -MM "token.cpp"

$(IntermediateDirectory)/token.cpp$(PreprocessSuffix): token.cpp
	@$(CXX) $(CXXFLAGS) $(IncludePCH) $(IncludePath) $(PreprocessOnlySwitch) $(OutputSwitch) $(IntermediateDirectory)/token.cpp$(PreprocessSuffix) "token.cpp"


-include $(IntermediateDirectory)/*$(DependSuffix)
##
## Clean
##
clean:
	$(RM) -r ./Release/


