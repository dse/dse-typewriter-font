SRC = dse-typewriter-font.sfd
TTF = dse-typewriter-font.ttf

# 1.2 line height variant
TTF_LH = dse-typewriter-font-lh.ttf

VERSION = $(shell date +"%Y.%m.%d")
SFNT_REVISION = $(shell date +"%Y%m.%d")

default: $(TTF) $(TTF_LH)

%.ttf: %.sfd Makefile
	sfd2ttf \
		--version="$(VERSION)" \
		$< $@.tmp.ttf
	mv $@.tmp.ttf $@

%-lh.ttf: %.sfd Makefile
	sfd2ttf \
		--version="$(VERSION)" \
		--line-height=1.2 \
		--font-name='DSETypewriterLH' \
		--family-name='DSE Typewriter LH' \
		--full-name='DSE Typewriter LH' \
		$< $@.tmp.ttf
	mv $@.tmp.ttf $@

macedit:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(SRC))"
maceditttf:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(TTF))"

clean:
	rm -f $(TTF) $(TTF_LH) *~ #*#
