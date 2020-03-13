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

    if not bg.isEmpty():
        width = glyph.width

        # save anchor points
        glyph.activeLayer = 'Fore'
        anchorPoints = glyph.anchorPoints

        copyLayer(glyph, src = 'Back', dest = 'Fore')

        strokeWidth = 96

        moveUp = psMat.translate(0, strokeWidth / 2)
        moveDown = psMat.translate(0, -strokeWidth / 2)
        moveLeft = psMat.translate(-strokeWidth / 2, 0)
        moveRight = psMat.translate(strokeWidth / 2, 0)

        if glyph.unicode >= 0x2500 and glyph.unicode < 0x2600:
            heavyHorizontal = False
            heavyVertical = False

            if glyph.unicode == 0x2501:
                heavyHorizontal = True
            if glyph.unicode == 0x2503:
                heavyVertical = True
            if glyph.unicode == 0x2505:
                heavyHorizontal = True
            if glyph.unicode == 0x2507:
                heavyVertical = True
            if glyph.unicode == 0x2509:
                heavyHorizontal = True
            if glyph.unicode == 0x250b:
                heavyVertical = True

            if heavyHorizontal:
                copyLayer(glyph, src = 'Back', dest = 'Temp')
                glyph.activeLayer = 'Temp'
                contours = [contour for contour in glyph.layers['Temp']]
                for c in contours:
                    c.transform(moveUp)
                    glyph.layers['Temp'] += c
                    c.transform(moveDown)
                for c in contours:
                    c.transform(moveDown)
                    glyph.layers['Temp'] += c
                    c.transform(moveUp)
            if heavyVertical:
                copyLayer(glyph, src = 'Back', dest = 'Temp')
                glyph.activeLayer = 'Temp'
                contours = [contour for contour in glyph.layers['Temp']]
                for c in contours:
                    c.transform(moveLeft)
                    glyph.layers['Temp'] += c
                    c.transform(moveRight)
                for c in contours:
                    c.transform(moveLeft)
                    glyph.layers['Temp'] += c
                    c.transform(moveRight)

            if heavyHorizontal or heavyVertical:
                copyLayer(glyph, src = 'Temp', dest = 'Fore')

        if glyph.unicode >= 0x2500 and glyph.unicode < 0x2600:
            # Box Drawing Characters
            lineCap = 'butt'
            lineJoin = 'round'
        else:
            lineCap = 'round'
            lineJoin = 'round'

        glyph.activeLayer = 'Fore'
        glyph.stroke('circular', strokeWidth, lineCap, lineJoin, ('removeinternal'))
        glyph.removeOverlap()
        glyph.addExtrema()
        glyph.width = width

        # restore anchor points
        glyph.activeLayer = 'Fore'
        for anchorPoint in anchorPoints:
            glyph.addAnchorPoint(*anchorPoint)

activeFont = fontforge.activeFont()

if activeFont == None:
    raise Exception('No active font.')

if not("Temp" in activeFont.layers):
    activeFont.layers.add("Temp", False, True)

codes = [code for code in activeFont.selection]

for code in codes:
    glyph = activeFont[code]
    updateGlyph(activeFont, glyph)
