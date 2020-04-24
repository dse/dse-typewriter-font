SRC = src/dse-typewriter-font.sfd
TTF = ttf/dse-typewriter-font.ttf

# 1.2 line height variant
TTF_LH = ttf/dse-typewriter-font-lh.ttf

# nohint and autohint variants
TTF__NH = testing/dse-typewriter-font--nh.ttf
TTF__AH = testing/dse-typewriter-font--ah.ttf

TTFS = $(TTF) $(TTF_LH) $(TTF__NH) $(TTF__AH)

VERSION = $(shell date +"%Y.%m.%d")
SFNT_REVISION = $(shell date +"%Y%m.%d")

TTFAUTOHINT = ttfautohint \
	--hinting-range-min=2 \
	--hinting-limit=50 \
	--fallback-stem-width=96 \
	--detailed-info \
	--windows-compatibility \
	--ignore-restrictions \
	--verbose

FFGLYPHS = $(shell which ffglyphs)

default: $(TTFS) glyphs.txt glyphs.html

ttf/%.ttf: src/%.sfd Makefile
	bin/check $(SRC)
	ffscript \
		--encode-unicode \
		--version="$(VERSION)" \
		$< $@.tmp.ttf
	mv $@.tmp.ttf $@

ttf/%-lh.ttf: src/%.sfd Makefile
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

testing/%--nh.ttf: src/%.sfd Makefile
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
	ffscript \
		--font-name='DSETypewriterAH' \
		--family-name='DSE Typewriter AH' \
		--full-name='DSE Typewriter AH' \
		$< $@.tmp.ttf
	$(TTFAUTOHINT) $@.tmp.ttf $@
	rm $@.tmp.ttf

glyphs.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --list-blocks --class="glyphs" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
glyphs-table.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --list-blocks --class="glyphs" --format=html2 $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
glyphs.txt: $(SRC) Makefile
	ffglyphs --list-blocks $(SRC) >$@.tmp.txt
	mv $@.tmp.txt $@
glyphs.html: glyphs.inc.html glyphs-table.inc.html glyphs.ssi.html Makefile
	ssi glyphs.ssi.html >$@.tmp.html
	mv $@.tmp.html $@
macedit:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(SRC))"
maceditttf:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(TTF))"
maceditttfah:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(TTF__AH))"
publish:
	ssh dse@webonastick.com "bash -c 'cd /www/webonastick.com/htdocs/fonts/dse-typewriter && git pull'"

clean:
	rm -f $(TTFS) *~ '#'*'#'
