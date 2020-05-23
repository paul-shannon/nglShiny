default: roxy install

install:
	R CMD INSTALL .

roxy:
	R -e "devtools::document()"

demo:
	R -f inst/unitTests/minimalDemoApp.R

twoModels:
	R -f inst/unitTests/twoModels.R
