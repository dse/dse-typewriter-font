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

print("===============================================================================")

def copyLayer(glyph, src, dest, replace = True):
    glyph.activeLayer = dest
    pen = glyph.glyphPen(replace = replace)
    glyph.activeLayer = src
    glyph.draw(pen)
    pen = None

def updateGlyph(font, glyph):
    bg = glyph.background
    fg = glyph.foreground
    clip = False

    if not bg.isEmpty():
        width = glyph.width

        # save anchor points
        glyph.activeLayer = 'Fore'
        anchorPoints = glyph.anchorPoints

        # save foreground references, for glyphs combining
        # foreground-layer references and background-layer strokes
        references = glyph.layerrefs[1]
        print("references: %r" % (references,))
        for reference in references:
            print("    reference: %r" % (reference,))

        copyLayer(glyph, src = 'Back', dest = 'Fore')

        strokeWidth = 96

        if (glyph.unicode >= 0x2500 and glyph.unicode < 0x2600 and
            not (glyph.unicode >= 0x2571 and glyph.unicode <= 0x2573)):
            # Box Drawing Characters
            lineCap = 'butt'
            lineJoin = 'round'
        else:
            lineCap = 'round'
            lineJoin = 'round'

        glyph.activeLayer = 'Fore'
        glyph.stroke('circular', strokeWidth, lineCap, lineJoin)
        glyph.removeOverlap()
        glyph.width = width

        if clip:
            clipContour = fontforge.contour()
            clipContour.moveTo(0, font.ascent)
            clipContour.lineTo(1024, font.ascent)
            clipContour.lineTo(1024, -font.descent)
            clipContour.lineTo(0, -font.descent)
            clipContour.closed = True
            glyph.layers['Fore'] += clipContour
            glyph.intersect()

        glyph.addExtrema()

        # restore anchor points
        glyph.activeLayer = 'Fore'
        for anchorPoint in anchorPoints:
            glyph.addAnchorPoint(*anchorPoint)

        for reference in references:
            glyph.addReference(reference[0], reference[1])

activeFont = fontforge.activeFont()

if activeFont == None:
    raise Exception('No active font.')

codes = [code for code in activeFont.selection]

for code in codes:
    glyph = activeFont[code]
    updateGlyph(activeFont, glyph)
