NAME=bibliography_jeremie_decock

###############################################################################

all: $(NAME).pdf

.PHONY : all clean init ps html pdf jdhp publish

SRCARTICLE=$(NAME).tex\
		   bibliography_jeremie_decock.bib

## ARTICLE ####################################################################

# PDF #############

pdf: $(NAME).pdf

$(NAME).pdf: $(SRCARTICLE)
	pdflatex $(NAME).tex
	bibtex $(NAME)     # this is the name of the .aux file, not the .bib file !
	pdflatex $(NAME).tex
	pdflatex $(NAME).tex

# PS ##############

ps: $(NAME).ps

$(NAME).ps: $(SRCARTICLE)
	latex $(NAME).tex
	bibtex $(NAME)     # this is the name of the .aux file, not the .bib file !
	latex $(NAME).tex
	latex $(NAME).tex
	dvips $(NAME).dvi

# HTML ############

html: $(NAME).html

$(NAME).html: $(SRCARTICLE)
	hevea -fix $(NAME).tex
	bibhva $(NAME)     # this is the name of the .aux file, not the .bib file !
	hevea -fix $(NAME).tex

## JDHP #######################################################################

publish: jdhp

jdhp:$(NAME).pdf $(NAME).html
	# JDHP_DOCS_URI is a shell environment variable that contains the
	# destination URI of the HTML files.
	@if test -z $$JDHP_DOCS_URI ; then exit 1 ; fi
	
	# JDHP_DL_URI is a shell environment variable that contains the destination
	# URI of the PDF files.
	@if test -z $$JDHP_DL_URI ; then exit 1 ; fi

	# Copy the HTML file
	@rm -rf $(NAME)/
	@mkdir $(NAME)/
	cp -v $(NAME).html $(NAME)/

	# Upload the HTML file
	rsync -r -v -e ssh $(NAME)/ ${JDHP_DOCS_URI}/$(NAME)/
	
	# Upload the PDF file
	rsync -v -e ssh $(NAME).pdf ${JDHP_DL_URI}/pdf/

	# Upload Bibtex files
	rsync -v -e ssh *.bib ${JDHP_DL_URI}/bib/

## CLEAN ######################################################################

clean:
	@echo "suppression des fichiers de compilation"
	@rm -f *.log *.aux *.dvi *.toc *.lot *.lof *.out *.nav *.snm *.bbl *.blg *.vrb
	@rm -f *.haux *.htoc *.hbbl $(NAME).image.tex
	@rm -rf $(NAME)/

init: clean
	@echo "suppression des fichiers cibles"
	@rm -f $(NAME).pdf
	@rm -f $(NAME).ps
	@rm -f $(NAME).html
