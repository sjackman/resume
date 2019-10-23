all: ShaunJackman.pdf publications.html

install-deps:
	tlmgr install titlesec

clean:
	rm -f ShaunJackman.pdf publications.html

.DELETE_ON_ERROR:
.SECONDARY:
.PHONY: all clean

# Format the resume for print.
ShaunJackman.md: README.md
	sed -E 's/^([^#].*)/> &/' $< >$@

# Render the resume in PDF format.
ShaunJackman.pdf: frontmatter.md ShaunJackman.md
	pandoc -o $@ $^

# Download the citation style language (CSL).
publications.csl:
	curl -o $@ https://www.zotero.org/styles/genome-research

# Download the publications from NCBI PubMed.
# Warning: returns an incomplete list. Use the web interface:
# https://www.ncbi.nlm.nih.gov/pubmed/?term=Jackman%20SD%5BAuthor%5D&cauthor=true&cauthor_uid=26645680
#publications.csv:
#	esearch -db pubmed -query "Jackman SD[Author]" | sed 's/<Count>25/<Count>99/' | efetch -format csv | sed 's/,$$//' >$@

# Convert PubMed CSV to a list of DOI.
%.doi: %.csv
	sed -nE 's/.*doi: ([^ "]*)\..*/\1/p' $< | sort -u >$@

# Convert a list of DOI to Bibtex entries.
%.bib.orig: %.doi
	while read i; do echo $$i >&2; curl -sLH "Accept: text/bibliography; style=bibtex" "https://doi.org/$$i"; done <$< | sed 's/^ *//' >$@

# Rename duplicate entries and remove incorrect ones.
%.bib: %.bib.orig
	grep -v 'Jackman, Sarah D' $< \
	| sed -E \
		-e 's/Jackman_2015, title={Organellar/Jackman_2015_Organellar, title={Organellar/' \
		-e 's/Jackman_2015, title={UniqTag/Jackman_2015_UniqTag, title={UniqTag/' \
		-e 's/title={([^}]*)},/title={{\1}},/' \
		-e 's~http://dx.doi.org~https://doi.org~' \
	| sort -t_ -k2,2nr -k1,1 >$@

# Convert Bibtext to Markdown.
%.md: %.bib
	sed -E 's/^@article\{([^,]*),.*/@\1/' $< | awk '{print NR ". " $$0}' >$@

# Convert Markdown to HTML.
publications.html: %.html: %.md publications.bib publications.csl
	pandoc -s --metadata=title=Publications --bibliography=publications.bib --csl=publications.csl $< \
	| sed -E 's/Jackman SD?/<strong>&<\/strong>/' > $@
