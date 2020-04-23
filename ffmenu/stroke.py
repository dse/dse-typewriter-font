#!/usr/bin/env fontforge -lang=py
#
# Add this script to FontForge:
#
# -   File -> Preferences
# -   Script Menu
# -   Menu Name: Update Stroke
# -   Script File: point to this script.
#     You may have to change the filter to *.py.

import fontforge
import psMat
import sys
import unicodedata
import re
import os

sys.path.append(os.environ['HOME'] +
                "/git/dse.d/fontforge-utilities/lib")
import ffutils

def updateGlyph(font, glyph):
    bg = glyph.background
    fg = glyph.foreground
    clip = False

    if not bg.isEmpty():
        savedWidth = glyph.width

        # make heavy box drawing character segments heavier
        middleX = int(0.5 + 1.0 * glyph.width / 2)
        middleY = int(0.5 + 1.0 * (font.ascent - abs(font.descent)) / 2)
        backLayer = glyph.layers['Back']

        # legacy
        if (glyph.unicode >= 0x2500 and glyph.unicode <= 0x254f) or (glyph.unicode >= 0x2574 and glyph.unicode <= 0x257f):
            modifyBackLayer = False
            contours = []
            newContours = []
            for contour in backLayer:
                contours += [contour]
                newContour = fontforge.contour()
                for point in contour:
                    if point.x == middleX - 48:
                        modifyBackLayer = True
                        point.x = middleX - 96
                    if point.x == middleX + 48:
                        modifyBackLayer = True
                        point.x = middleX + 96
                    if point.y == middleY - 48:
                        modifyBackLayer = True
                        point.y = middleY - 96
                    if point.y == middleY + 48:
                        modifyBackLayer = True
                        point.y = middleY + 96
                    newContour += point
                newContours += [newContour]
            if modifyBackLayer:
                glyph.layers['Back'] = fontforge.layer()
                for contour in newContours:
                    glyph.layers['Back'] += contour
                backLayer = glyph.layers['Back']

        # save anchor points
        glyph.activeLayer = 'Fore'
        anchorPoints = glyph.anchorPoints

        # save foreground references, for glyphs combining
        # foreground-layer references and background-layer strokes
        references = glyph.layerrefs[1]
        print("references: %r" % (references,))
        for reference in references:
            print("    reference: %r" % (reference,))

        ffutils.copyLayer(glyph, src = 'Back', dest = 'Fore')

        strokeWidth = 96

        if (ffutils.isBoxDrawingCharacter(glyph) and not
            ffutils.isDiagonalBoxDrawingCharacter(glyph)):
            # Box Drawing Characters
            lineCap = 'butt'
            lineJoin = 'round'
        else:
            lineCap = 'round'
            lineJoin = 'round'

        glyph.activeLayer = 'Fore'
        glyph.stroke('circular', strokeWidth, lineCap, lineJoin)
        glyph.removeOverlap()
        glyph.width = savedWidth

        # originally for U+2571 through U+2573 but would not work
        if clip:
            ffutils.clipGlyph(glyph)

        glyph.addExtrema()

        # restore anchor points
        glyph.activeLayer = 'Fore'
        for anchorPoint in anchorPoints:
            glyph.addAnchorPoint(*anchorPoint)

        for reference in references:
            glyph.addReference(reference[0], reference[1])

fw = ffutils.FontWrapper()
fw.setFont(fontforge.activeFont())
fw.setFontData()

activeFont = fontforge.activeFont()

if activeFont == None:
    raise Exception('No active font.')

codes = [code for code in activeFont.selection]

for code in codes:
    print(code)
    if code >= 0x2800 and code < 0x2900: # BRAILLE
        ffutils.generateBraille(activeFont, code)
    elif code in activeFont:
        glyph = activeFont[code]
        updateGlyph(activeFont, glyph)
    else:
        sys.stderr.write("%d: no such glyph\n" % code)
