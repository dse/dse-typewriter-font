SRC = dse-typewriter-font.sfd
TTF = dse-typewriter-font.ttf

# 1.2 line height variant
TTF_LH = dse-typewriter-font-lh.ttf

# nohint and autohint variants
TTF__NH = testing/dse-typewriter-font--nh.ttf
TTF__AH = testing/dse-typewriter-font--ah.ttf

TTFS = $(TTF) $(TTF_LH) $(TTF__NH) $(TTF__AH)

VERSION = $(shell date +"%Y.%m.%d")
SFNT_REVISION = $(shell date +"%Y%m.%d")

default: $(TTFS)

%.ttf: %.sfd Makefile
	bin/check $(SRC)
	ffscript \
		--encode-unicode \
		--version="$(VERSION)" \
		$< $@.tmp.ttf
	mv $@.tmp.ttf $@

%-lh.ttf: %.sfd Makefile
	bin/check $(SRC)
	ffscript \
		--encode-unicode \
		--version="$(VERSION)" \
		--line-height=1.2 \
		--font-name='DSETypewriterLH' \
		--family-name='DSE Typewriter LH' \
		--full-name='DSE Typewriter LH' \
		$< $@.tmp.ttf
	mv $@.tmp.ttf $@

testing/%--nh.ttf: %.sfd Makefile
	bin/check $(SRC)
	mkdir -p testing
	ffscript \
		--encode-unicode \
		--version="$(VERSION)" \
		--no-hints \
		--omit-instructions \
		--font-name='DSETypewriterNH' \
		--family-name='DSE Typewriter NH' \
		--full-name='DSE Typewriter NH' \
		$< $@.tmp.ttf
	mv $@.tmp.ttf $@

testing/%--ah.ttf: testing/%--nh.ttf Makefile
	mkdir -p testing
	ttfautohint $< $@.tmp.ttf
	ffscript \
		--font-name='DSETypewriterAH' \
		--family-name='DSE Typewriter AH' \
		--full-name='DSE Typewriter AH' \
		$@.tmp.ttf $@.tmp.ttf
	mv $@.tmp.ttf $@

macedit:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(SRC))"
maceditttf:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(TTF))"

clean:
	rm -f $(TTFS) *~ '#'*'#'
