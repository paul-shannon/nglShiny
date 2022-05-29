default:
	@echo targets: basic [roxy install] demo

basic: roxy install

install:
	R CMD INSTALL .

roxy:
	R -e "devtools::document()"

demo:
	R -f inst/unitTests/minimalDemoApp.R

twoModels:
	R -f inst/unitTests/twoModels.R

twoModelsConditionalDisplay:
	R -f inst/unitTests/twoModelsConditionalDisplay.R


rstudio:
	open -a Rstudio  inst/unitTests/minimalDemoApp.R

