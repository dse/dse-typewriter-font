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

activeFont = fontforge.activeFont()

if activeFont == None:
    raise Exception('No active font.')

codes = [code for code in activeFont.selection]

for code in codes:
    if code >= 0x2800 and code < 0x2900: # BRAILLE
        ffutils.generateBraille(activeFont, code)
    elif code in activeFont:
        glyph = activeFont[code]
        ffutils.updateBackgroundStrokeGlyph(glyph)
    else:
        sys.stderr.write("%d: no such glyph\n" % code)
