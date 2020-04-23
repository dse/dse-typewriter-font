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

        if (glyph.unicode >= 0x2500 and glyph.unicode < 0x2600 and not (glyph.unicode >= 0x2571 and glyph.unicode <= 0x2573)):
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

def generateBraille(font, codepoint):
    glyphWidth = 1024
    glyphHeight = font.ascent + font.descent
    brailleScale = 0.75
    dotWidth = 112

    try:
        char = unichr(codepoint)
    except NameError:
        char = chr(codepoint)
    try:
        charName = unicodedata.name(char)
    except ValueError:
        sys.stderr.write("%d: not a valid codepoint." % codepoint)
        return

    matchBlank = re.search(' BLANK$', charName)
    matchDots = re.search('-([0-9]+)$', charName)
    if (not matchBlank) and (not matchDots):
        sys.stderr.write("%d: Glyph name '%s' does not look like a Unicode Braille glyph name." % (codepoint, charName))
        return
    if matchDots:
        dotString = matchDots.group(1)

    glyph = None
    if codepoint in activeFont:
        glyph = activeFont[codepoint]
        glyph.clear()
    else:
        glyph = activeFont.createChar(codepoint)

    if matchDots:
        # where dots 1 through 8 are located
        dotsXX = [0, 0, 0, 1, 1, 1, 0, 1]
        dotsYY = [0, 1, 2, 0, 1, 2, 3, 3]

        middleX = int(0.5 + float(glyphWidth) / 2.0)
        middleY = int(0.5 + (float(font.ascent) - float(abs(font.descent))) / 2)

        glyph.activeLayer = 'Fore'
        pen = glyph.glyphPen()
        for dotNumberChar in dotString:
            dotNumber = int(dotNumberChar) - 1
            dotXX = dotsXX[dotNumber]
            dotYY = dotsYY[dotNumber]
            dotX = int(0.5 + (
                float(middleX) + (float(dotXX) - 0.5) * float(glyphWidth) / 2 * brailleScale
            ))
            print("<%d %d %d %d>" % (middleX, dotXX, glyphWidth, dotX))
            dotY = int(0.5 + (
                float(middleY) - (float(dotYY) - 1.5) * float(glyphHeight) / 4 * brailleScale
            ))
            circle = fontforge.unitShape(0)
            circle.transform(psMat.scale(dotWidth))
            circle.transform(psMat.translate(dotX, dotY))
            circle.draw(pen)
        pen = None

    glyph.width = glyphWidth

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
        generateBraille(activeFont, code)
    elif code in activeFont:
        glyph = activeFont[code]
        updateGlyph(activeFont, glyph)
    else:
        sys.stderr.write("%d: no such glyph\n" % code)
