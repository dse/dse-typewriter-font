SRC    = src/dse-typewriter-font.sfd
TTF    = ttf/dse-typewriter-font.ttf

# variants
TTF_LH = ttf/dse-typewriter-font-lh.ttf
TTF_NH = ttf/dse-typewriter-font-nh.ttf
TTF_AH = ttf/dse-typewriter-font-ah.ttf

TTFS = $(TTF) $(TTF_LH) $(TTF_NH) $(TTF_AH)

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

TTFAUTOHINT_DEHINT = ttfautohint \
	--dehint \
	--windows-compatibility \
	--ignore-restrictions \
	--verbose

CONVERT_LH_FONT = --line-height=1.2 \
                  --font-name='DSETypewriterLH' \
                  --family-name='DSE Typewriter LH' \
                  --full-name='DSE Typewriter LH'

CONVERT_NH_FONT = --font-name='DSETypewriterNH' \
                  --family-name='DSE Typewriter NH' \
                  --full-name='DSE Typewriter NH'

CONVERT_AH_FONT = --font-name='DSETypewriterAH' \
                  --family-name='DSE Typewriter AH' \
                  --full-name='DSE Typewriter AH'

FFGLYPHS = $(shell which ffglyphs)

.PHONY: default
default: fonts glyphs.txt glyphs.html coverage-detail.html coverage-summary.html

.PHONY: fonts
fonts: $(TTFS)

ttf/%.ttf: src/%.sfd Makefile
	bin/check $(SRC)
	bin/convert --version="$(VERSION)" $< $@.tmp.ttf
	mv $@.tmp.ttf $@

ttf/%-lh.ttf: src/%.sfd Makefile
	bin/check $(SRC)
	bin/convert --version="$(VERSION)" $(CONVERT_LH_FONT) $< $@.tmp.ttf
	mv $@.tmp.ttf $@

ttf/%-nh.ttf: src/%.sfd Makefile
	bin/check $(SRC)
	bin/convert --version="$(VERSION)" $(CONVERT_NH_FONT) $< $@.tmp.ttf
	$(TTFAUTOHINT_DEHINT) $@.tmp.ttf $@.tmp.2.ttf
	mv $@.tmp.2.ttf $@
	rm $@.tmp.ttf

ttf/%-ah.ttf: src/%.sfd Makefile
	bin/check $(SRC)
	bin/convert --version="$(VERSION)" $(CONVERT_AH_FONT) $< $@.tmp.ttf
	$(TTFAUTOHINT) $@.tmp.ttf $@.tmp.2.ttf
	mv $@.tmp.2.ttf $@
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

publish:
	ssh dse@webonastick.com "bash -c 'cd /www/webonastick.com/htdocs/fonts/dse-typewriter && git pull'"

clean:
	rm -f $(TTFS) *~ '#'*'#'
