# Makefile for Matlab Compiler

FNAME = metacentrum_task

MATLAB_COMPILER = mcc
MC_FLAGS= -R -singleCompThread -R -nodisplay
MC_INCLUDE= -a src/ 
OUT = $(FNAME)
SRC = exp/$(FNAME).m

$(OUT):	
	$(MATLAB_COMPILER) -m $(MC_FLAGS) $(MC_INCLUDE) -o $@ $(SRC)
	mv $(OUT) exp/$(OUT)

all:	$(OUT)

clean:
	rm mccExcludedFiles.log readme.txt requiredMCRProducts.txt run_$(FNAME).sh
