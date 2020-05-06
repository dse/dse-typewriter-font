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

default: $(TTFS) glyphs.txt glyphs.html coverage-detail.html coverage-summary.html

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
	ffglyphs --list-blocks --heading-tag-name='h3' --class="data-table glyph-table main-glyph-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
glyphs-table.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --list-blocks --class="data-table glyph-table compact-glyph-table" --format=html --compact $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
coverage.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --coverage-summary --class="data-table unicode-block-coverage-table coverage-summary-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
coverage-detail.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --coverage-detail --class="data-table glyph-table coverage-detail-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
coverage-summary.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --coverage-summary --with-anchors --anchor-page-url="coverage-detail.html" --class="data-table glyph-table coverage-summary-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
toc.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --table-of-contents --with-anchors --anchor-page-url="coverage-detail.html" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
glyphs.txt: $(SRC) Makefile
	ffglyphs --list-blocks $(SRC) >$@.tmp.txt
	mv $@.tmp.txt $@

glyphs.html: glyphs.ssi.html glyphs.inc.html glyphs-table.inc.html coverage.inc.html Makefile
	ssi $< >$@.tmp.html
	mv $@.tmp.html $@
coverage-detail.html: coverage-detail.ssi.html coverage-detail.inc.html toc.inc.html Makefile
	ssi $< >$@.tmp.html
	mv $@.tmp.html $@
coverage-summary.html: coverage-summary.ssi.html coverage-summary.inc.html toc.inc.html Makefile
	ssi $< >$@.tmp.html
	mv $@.tmp.html $@

pages: coverage-detail.html coverage-summary.html glyphs.html
.PHONY: pages

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
