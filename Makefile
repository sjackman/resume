GROFF=groff -M. -mcv -rS12

all: sdj-cv.pdf sdj-cv.html

clean:
	rm -f sdj-cv.html sdj-cv.pdf sdj-cv.ps

.PHONY: all clean

%-cv.html: %.cv
	$(GROFF) -Thtml $< >$@

%-cv.ps: %.cv
	$(GROFF) -Tps $< >$@

%.pdf: %.ps
	ps2pdf $< $@
