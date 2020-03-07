#!/usr/bin/env fontforge -lang=py

import fontforge

def updateGlyph(font, glyph):
    bg = glyph.background
    print("    glyph.background = %s" % bg)
    fg = glyph.foreground
    print("    glyph.foreground = %s" % fg)
    if not bg.isEmpty():
        glyph.activeLayer = 'Fore'
        pen = glyph.glyphPen()
        glyph.activeLayer = 'Back'
        glyph.draw(pen)
        pen = None

        glyph.activeLayer = 'Fore'
        # glyph.round()
        glyph.stroke('circular', 96, 'round', 'round')
        glyph.removeOverlap()
        glyph.addExtrema()

        # font.selection.select(glyph)
        # font.cut()

        # glyph.activeLayer = 'Back'
        # font.selection.select(glyph)
        # font.copy()

        # glyph.activeLayer = 'Fore'
        # font.selection.select(glyph)
        # font.paste()

        # glyph.round()
        # glyph.stroke('circular', 96, 'round', 'round')
        # glyph.removeOverlap()
        # glyph.addExtrema()

activeFont = fontforge.activeFont()

if activeFont == None:
    raise Exception('No active font.')

codes = [code for code in activeFont.selection]
print("codes = %s" % codes)

for code in codes:
    print("code = %s" % code)
    glyph = activeFont[code]
    print("glyph = %s" % glyph)
    updateGlyph(activeFont, glyph)
