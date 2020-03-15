SRC = dse-typewriter-font.sfd
TTF = dse-typewriter-font.ttf

default: $(TTF)

%.ttf: %.sfd Makefile
	sfd2ttf $< $@.tmp.ttf
	mv $@.tmp.ttf $@

macedit:
	/Applications/FontForge.app/Contents/Resources/opt/local/bin/fontforge "$$(realpath $(SRC))"

clean:
	rm -f $(TTF) *~ #*#
