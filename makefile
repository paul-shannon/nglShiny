default: roxy install

install:
	R CMD INSTALL .

roxy:
	R -e "devtools::document()"
