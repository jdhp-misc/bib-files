NAME=bibliography_jeremie_decock

JDHP_ROOT=~/jdhp

# HEVEA doit être mis dans www plutot que dans download pour les stats et le référencement...
JDHP_HEVEA_DIR=${JDHP_ROOT}/www.jdhp.org/hevea
JDHP_PDF_DIR=${JDHP_ROOT}/download.tuxfamily.org/pdf
JDHP_BIB_DIR=${JDHP_ROOT}/download.tuxfamily.org/bib

JDHP_DOWNLOAD_FILES_SCRIPT=${JDHP_ROOT}/download.tuxfamily.org.pull.sh
JDHP_UPLOAD_FILES_SCRIPT=${JDHP_ROOT}/download.tuxfamily.org.push.sh
JDHP_UPLOAD_HEVEA_SCRIPT=${JDHP_ROOT}/www.jdhp.org/push_hevea.sh

#############

all: $(NAME).pdf

.PHONY : all clean init ps html hevea jdhp publish

## ARTICLE ##

SRCARTICLE=$(NAME).tex\
		   bibliography_jeremie_decock.bib

$(NAME).pdf: $(SRCARTICLE)
	pdflatex $(NAME).tex
	bibtex $(NAME)     # this is the name of the .aux file, not the .bib file !
	pdflatex $(NAME).tex
	pdflatex $(NAME).tex

ps: $(NAME).ps

$(NAME).ps: $(SRCARTICLE)
	latex $(NAME).tex
	bibtex $(NAME)     # this is the name of the .aux file, not the .bib file !
	latex $(NAME).tex
	latex $(NAME).tex
	dvips $(NAME).dvi

html: $(NAME).html

hevea: $(NAME).html

$(NAME).html: $(SRCARTICLE)
	hevea -fix $(NAME).tex
	bibhva $(NAME)     # this is the name of the .aux file, not the .bib file !
	hevea -fix $(NAME).tex

publish: jdhp

jdhp:$(NAME).pdf $(NAME).html
	# Download the latest version of published files (it make the assumption
	# that the remote site always contains the latest version of files)
	$(JDHP_DOWNLOAD_FILES_SCRIPT)
	
	# Copy PDF
	cp -v $(NAME).pdf  $(JDHP_PDF_DIR)/
	
	# Copy Bibtex
	cp -v *.bib  $(JDHP_BIB_DIR)/
	
	# Copy HTML
	@rm -rf $(JDHP_HEVEA_DIR)/$(NAME)
	@mkdir $(JDHP_HEVEA_DIR)/$(NAME)
	cp -v $(NAME).html $(JDHP_HEVEA_DIR)/$(NAME)
	
	# Upload files
	$(JDHP_UPLOAD_FILES_SCRIPT)
	$(JDHP_UPLOAD_HEVEA_SCRIPT)

## CLEAN ##

clean:
	@echo "suppression des fichiers de compilation"
	@rm -f *.log *.aux *.dvi *.toc *.lot *.lof *.out *.nav *.snm *.bbl *.blg *.vrb
	@rm -f *.haux *.htoc *.hbbl $(NAME).image.tex

init: clean
	@echo "suppression des fichiers cibles"
	@rm -f $(NAME).pdf
	@rm -f $(NAME).ps
	@rm -f $(NAME).html
