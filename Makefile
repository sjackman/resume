GROFF=groff -M. -mresume -rS12

all: ShaunJackman.html ShaunJackman.pdf

clean:
	rm -f ShaunJackman.html ShaunJackman.pdf ShaunJackman.ps

.PHONY: all clean

%.html: %.tr
	$(GROFF) -Thtml $< >$@

%.ps: %.tr
	$(GROFF) -Tps $< >$@

%.pdf: %.ps
	pstopdf $< $@
