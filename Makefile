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

PAGES = website/coverage-detail.html website/coverage-summary.html website/glyphs.html

FFGLYPHS = $(shell which ffglyphs)

.PHONY: default
default: fonts glyphs.txt $(PAGES)

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

# smelled like the north end of a south bound billy goat

website/glyphs.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --list-blocks --heading-tag-name='h3' --class="data-table glyph-table main-glyph-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
website/glyphs-table.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --list-blocks --class="data-table glyph-table compact-glyph-table" --format=html --compact $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
website/coverage.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --coverage-summary --class="data-table unicode-block-coverage-table coverage-summary-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
website/coverage-detail.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --coverage-detail --class="data-table glyph-table coverage-detail-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
website/coverage-summary.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --coverage-summary --with-anchors --anchor-page-url="coverage-detail.html" --class="data-table glyph-table coverage-summary-table" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
website/toc.inc.html: $(SRC) $(FFGLYPHS) Makefile
	ffglyphs --table-of-contents --with-anchors --anchor-page-url="coverage-detail.html" --format=html $(SRC) >$@.tmp.html
	mv $@.tmp.html $@
glyphs.txt: $(SRC) Makefile
	ffglyphs --list-blocks $(SRC) >$@.tmp.txt
	mv $@.tmp.txt $@

website/glyphs.html: website/glyphs.ssi.html website/glyphs.inc.html website/glyphs-table.inc.html website/coverage.inc.html Makefile
	ssi $< >$@.tmp.html
	mv $@.tmp.html $@
website/coverage-detail.html: website/coverage-detail.ssi.html website/coverage-detail.inc.html website/toc.inc.html Makefile
	ssi $< >$@.tmp.html
	mv $@.tmp.html $@
website/coverage-summary.html: website/coverage-summary.ssi.html website/coverage-summary.inc.html website/toc.inc.html Makefile
	ssi $< >$@.tmp.html
	mv $@.tmp.html $@

.PHONY: pages
pages: $(PAGES)

WEBSITE_DIR = /www/webonastick.com/htdocs/fonts/dse-typewriter
WEBSITE_REPOS_DIR = /home/dse/git/dse.d/fonts.d/dse-typewriter-font/website
REPOS_DIR = /home/dse/git/dse.d/fonts.d/dse-typewriter-font

.PHONY: publish
publish:
	ssh dse@webonastick.com "bash -c '\
		cd '$(WEBSITE_DIR)' && \
		git pull && \
		ln -n -f -s '$(REPOS_DIR)/website' '$(WEBSITE_DIR)'     \
	'"

.PHONY: clean
clean:
	rm -f $(TTFS) *~ '#'*'#'
