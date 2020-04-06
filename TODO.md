# TODO

-   find whatever cedilla they're using to generate all the letters
    with the cedilla

-   ogonek

## Glyph Substitutions

(example from Consolas)

| Subtable | -                | -                  | Replacement Glyph Name |
|:---------|:-----------------|:-------------------|:-----------------------|
| ss08     | Style Set 8      | lookup 31 subtable | zero.ss07              |
| ss07     | Style Set 7      | lookup 30 subtable | zero.ss08              |
| onum     | Oldstyle Figures | lookup 16 subtable | zero.oldstyle          |
| subs     | Subscript        | lookup 15 subtable | U+2080                 |
| dnom     | Denominators     | lookup 13 subtable | zero.dnom              |
| numr     | Numerators       | lookup 10 subtable | U+2070                 |

zero.ss08 dotted zero
zero.ss07 slashless zero
zero.oldstyle old style zero
zero.oldstyle.ss08 old style dotted zero
zero.oldstyle.ss07 old style slashless zero

## Alt Subs

(example from Consolas)

| Subtable | -                      | -                  | Replacement Glyph Names |
|:---------|:-----------------------|:-------------------|:------------------------|
| salt     | Stylistic Alternatives | lookup 21 subtable | zero.ss07 zero.ss08     |

## How-To

Create two lookups and associated subtables.

-   Lookup type: Single Substitution
-   Feature: 'onum' for Old Style Figures
-   Make the feature apply to multiple scripts, including 'DFLT'.

-   Open Element -> Font Info.
-   Select 'Lookups' on left.
-   Make sure the 'GSUB' tab is selected.
-   Click 'Add Lookup'.
-   For Type, select 'Single Substitution'.
-   Under the Feature column, click '<New>'.
-   For Feature, enter: onum
-   For Scripts & Languages, default should be: DFLT{dflt} latn{dflt} grek{dflt} cyrl{dflt}
-   For Lookup Name, enter: 'onum' Oldstyle Figures lookup 16

-   Now click 'Add Subtable'.
-   Name should be populated by default: `'onum' Oldstyle Figures lookup 16-1`
    Good to change it to: `'onum' Oldstyle Figures lookup 16 subtable`
