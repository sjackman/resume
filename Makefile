GROFF=groff -M. -mresume -rS12

all: README.html ShaunJackman.html ShaunJackman.pdf

clean:
	rm -f ShaunJackman.html ShaunJackman.pdf ShaunJackman.ps

.DELETE_ON_ERROR:
.SECONDARY:
.PHONY: all clean

# Download the citation style language (CSL).
publications.csl:
	curl -o $@ https://www.zotero.org/styles/genome-research

# Convert Markdown to HTML.
%.html: %.md publications.bib publications.csl
	pandoc -s -o $@ $<

# Convert TROFF to HTML.
%.html: %.tr
	$(GROFF) -Thtml $< >$@

# Convert TROFF to Postscript.
%.ps: %.tr
	$(GROFF) -Tps $< >$@

# Convert Postscript to PDF.
%.pdf: %.ps
	pstopdf $< $@

# Download the publications from NCBI PubMed.
# Warning: returns an incomplete list. Use the web interface:
# https://www.ncbi.nlm.nih.gov/pubmed/?term=Jackman%20SD%5BAuthor%5D&cauthor=true&cauthor_uid=26645680
#publications.csv:
#	esearch -db pubmed -query "Jackman SD[Author]" | sed 's/<Count>25/<Count>99/' | efetch -format csv | sed 's/,$$//' >$@

# Convert PubMed CSV to a list of DOI.
%.doi: %.csv
	gsed -nr 's/.*doi: ([^ "]*)\..*/\1/p' $< | sort -u >$@

# Convert a list of DOI to Bibtex entries.
%.bib.orig: %.doi
	while read i; do echo $$i >&2; curl -sLH "Accept: text/bibliography; style=bibtex" "https://dx.doi.org/$$i"; done <$< | sed 's/^ *//' >$@

# Rename duplicate entries and remove incorrect ones.
%.bib: %.bib.orig
	sed 's/Jackman_2015, title={Organellar/Jackman_2015_Organellar, title={Organellar/' $< \
	| sed 's/Jackman_2015, title={UniqTag/Jackman_2015_UniqTag, title={UniqTag/' \
	| sed 's/title={/title={{/;s/}/}}/' \
	| grep -v 'Jackman, Sarah D' >$@

# Convert Bibtext to Markdown.
%.md: %.bib
	gsed -r 's/^@article\{([^,]*),.*/@\1/' $< | awk '{print NR ". " $$0}' >$@

# Convert Markdown to HTML.
publications.html: %.html: %.md publications.bib publications.csl
	pandoc -s --bibliography=publications.bib --csl=publications.csl $< \
	| gsed -r 's/Jackman SD?/<strong>&<\/strong>/' > $@
