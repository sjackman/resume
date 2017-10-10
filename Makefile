GROFF=groff -M. -mresume -rS12

all: README.html ShaunJackman.html ShaunJackman.pdf

clean:
	rm -f ShaunJackman.html ShaunJackman.pdf ShaunJackman.ps

.PHONY: all clean

%.html: %.md
	pandoc -s -o $@ $<

%.html: %.tr
	$(GROFF) -Thtml $< >$@

%.ps: %.tr
	$(GROFF) -Tps $< >$@

%.pdf: %.ps
	pstopdf $< $@
