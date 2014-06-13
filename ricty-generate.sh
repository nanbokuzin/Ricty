#!/usr/bin/env bash
set -E

RICTY_VERSION="3.2.3"

FONT_FAMILY="Ricty"
FONT_ASCENT=835
FONT_DESCENT=215

ASCII_REGULAR_WIDTH=0
ASCII_BOLD_WIDTH=60
FULLWIDTH_AMBIGUOUS=true
SCALING_DOWN=true

FONTFORGE="/usr/bin/env fontforge"
if ! which $FONTFORGE > /dev/null 2>&1; then
    echo "${FONTFORGE} command not found" >&2
    exit 1
fi

GEN_INCONSOLATA="Inconsolata.pe"
GEN_MIGU1M="Migu 1M.pe"
GEN_RICTY="Ricty.pe"

INCONSOLATA_REGULAR="Inconsolata.otf"
INCONSOLATA_BOLD="Inconsolata-Bold.otf"
MIGU1M_REGULAR="migu-1m-regular.ttf"
MIGU1M_BOLD="migu-1m-bold.ttf"

MOD_INCONSOLATA_REGULAR="Mod-${INCONSOLATA_REGULAR}.sfd"
MOD_INCONSOLATA_BOLD="Mod-${INCONSOLATA_BOLD}.sfd"
MOD_MIGU1M_REGULAR="Mod-${MIGU1M_REGULAR}.sfd"
MOD_MIGU1M_BOLD="Mod-${MIGU1M_BOLD}.sfd"

SEED="$(date "+%Y%m%d%H%M%S").$$"
BUILD_PATH="/tmp/RICTY.${SEED}"

mktemp -d "$BUILD_PATH" || exit 2

trap "[[ -d \"BUILD_PATH\" ]] && rm -rf $BUILD_PATH && echo 'Abnormally terminated.' exit 3" HUP INT QUIT
trap "[[ -d \"BUILD_PATH\" ]] && rm -rf $BUILD_PATH && echo 'Abnormally terminated.'" ERR

cat > "${BUILD_PATH}/${GEN_INCONSOLATA}" <<EOF
#!$FONTFORGE

Print("Open ${INCONSOLATA_REGULAR}")
Open("${INCONSOLATA_REGULAR}")
    ScaleToEm(860, 140)
    if ("${FULLWIDTH_AMBIGUOUS}" == "true")
        Select(0u00a4); Clear() # currency
        Select(0u00a7); Clear() # section
        Select(0u00a8); Clear() # dieresis
        Select(0u00ad); Clear() # soft hyphen
        Select(0u00b0); Clear() # degree
        Select(0u00b1); Clear() # plus-minus
        Select(0u00b4); Clear() # acute
        Select(0u00b6); Clear() # pilcrow
        Select(0u00d7); Clear() # multiply
        Select(0u00f7); Clear() # divide
        Select(0u2018); Clear() # left '
        Select(0u2019); Clear() # right '
        Select(0u201c); Clear() # left "
        Select(0u201d); Clear() # right "
        Select(0u2020); Clear() # dagger
        Select(0u2021); Clear() # double dagger
        Select(0u2026); Clear() # ...
        Select(0u2122); Clear() # TM
        Select(0u2191); Clear() # uparrow
        Select(0u2193); Clear() # downarrow
    endif
    
    SelectWorthOutputting()
    ClearInstrs()
    Save("${BUILD_PATH}/${MOD_INCONSOLATA_REGULAR}")
    Print("Save ${MOD_INCONSOLATA_REGULAR}")
    
    SelectWorthOutputting()
    ExpandStroke(${ASCII_BOLD_WIDTH}, 0, 0, 0, 1)
    Select(0u003e) # >
    Copy()
    Select(0u003c) # <
    Paste()
    HFlip()
    
    RoundToInt()
    RemoveOverlap()
    RoundToInt()
    Save("${BUILD_PATH}/${MOD_INCONSOLATA_BOLD}")
    Print("Save ${MOD_INCONSOLATA_BOLD}")
Close()

Quit()
EOF

cat > "${BUILD_PATH}/${GEN_MIGU1M}" <<EOF
#!$FONTFORGE

src = ["${MIGU1M_REGULAR}", "${MIGU1M_BOLD}"]
dst = ["${MOD_MIGU1M_REGULAR}", "${MOD_MIGU1M_BOLD}"]

i = 0
while (i < SizeOf(src))
    Print("Open " + src[i])
    Open(src[i])
        ScaleToEm(860, 140)
        SelectWorthOutputting()
        ClearInstrs()
        UnlinkReference()
        if ("${SCALING_DOWN}" == "true")
            SetWidth(-1, 1)
            Scale(91, 91, 0, 0)
            SetWidth(110, 2)
            SetWidth(1, 1)
            Move(23, 0)
            SetWidth(-23, 1)
        endif

        RoundToInt()
        RemoveOverlap()
        RoundToInt()
        Save("${BUILD_PATH}/" + dst[i])
        Print("Save " + dst[i])
    Close()
    ++i
endloop

Quit()
EOF

cat > "${BUILD_PATH}/${GEN_RICTY}" <<EOF
#!$FONTFORGE

src_i     = ["${BUILD_PATH}/${MOD_INCONSOLATA_REGULAR}", \\
             "${BUILD_PATH}/${MOD_INCONSOLATA_BOLD}"]
src_m     = ["${BUILD_PATH}/${MOD_MIGU1M_REGULAR}", \\
             "${BUILD_PATH}/${MOD_MIGU1M_BOLD}"]

copyright = "Copyright (c) 2006 Raph Levien\n" \\
          + "Copyright (c) 2006-2013 itouhiro\n" \\
          + "Copyright (c) 2002-2013 M+ FONTS PROJECT\n" \\
          + "Copyright (c) 2003-2011 " \\
          + "Information-technology Promotion Agency, Japan"
version   = Strftime("%Y", 0, 'C') + "." + Strftime("%m%d", 0, 'C')

i = 0
fontstyle_list = ["Regular", "Bold"]
weight_list = [400, 700]
panose_list = [5, 8]
while (i < SizeOf(fontstyle_list))
    New()
        Reencode("unicode")
        ScaleToEm(860, 140)

        SetOS2Value("Weight", weight_list[i])
        SetOS2Value("Width", 5)
        SetOS2Value("FSType", 0)
        SetOS2Value("VendorID", "PfEd")
        SetOS2Value("IBMFamily", 2057) # SS Typewriter Gothic
        SetOS2Value("TypoAscentIsOffset", 0)
        SetOS2Value("TypoDescentIsOffset", 0)
        SetOS2Value("HHeadAscentIsOffset", 0)
        SetOS2Value("HHeadDescentIsOffset", 0)
        SetOS2Value("WinAscentIsOffset", 0)
        SetOS2Value("WinDescentIsOffset", 0)
        SetOS2Value("TypoAscent", 860)
        SetOS2Value("TypoDescent", -140)
        SetOS2Value("TypoLineGap", 0)
        SetOS2Value("HHeadAscent", ${FONT_ASCENT})
        SetOS2Value("HHeadDescent", -${FONT_DESCENT})
        SetOS2Value("HHeadLineGap", 0)
        SetOS2Value("WinAscent", ${FONT_ASCENT})
        SetOS2Value("WinDescent", ${FONT_DESCENT})
        SetPanose([2, 11, panose_list[i], 9, 2, 2, 3, 2, 2, 7])

        Print("Merge " + src_i[i]:t + " + " + src_m[i]:t + "...")
        MergeFonts(src_i[i])
        MergeFonts(src_m[i])

        # zenkaku space
        Select(0u2610)
        Copy()
        Select(0u3000)
        Paste()
        Select(0u271a)
        Copy()
        Select(0u3000)
        PasteInto()
        OverlapIntersect()

        # zenkaku comma and period
        Select(0uff0c)
        Scale(150, 150, 100, 0)
        SetWidth(1000)
        Select(0uff0e)
        Scale(150, 150, 100, 0)
        SetWidth(1000)

        # zenkaku colon and semicolon
        Select(0uff0c)
        Copy()
        Select(0uff1b)
        Paste()
        Select(0uff0e)
        Copy()
        Select(0uff1b)
        PasteWithOffset(0, 400)
        CenterInWidth()
        Select(0uff1a)
        Paste()
        PasteWithOffset(0, 400)
        CenterInWidth()

        # zenkaku brackets
        Select(0u0028) # (
        Copy()
        Select(0uff08)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u0029) # )
        Copy()
        Select(0uff09)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u005b) # [
        Copy()
        Select(0uff3b)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u005d) # ]
        Copy()
        Select(0uff3d)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u007b) # {
        Copy()
        Select(0uff5b)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u007d) # }
        Copy()
        Select(0uff5d)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u003c) # <
        Copy()
        Select(0uff1c)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        Select(0u003e) # >
        Copy()
        Select(0uff1e)
        Paste()
        Move(250, 0)
        SetWidth(1000)

        # en dash
        Select(0u2013)
        Copy()
        PasteWithOffset(200, 0)
        PasteWithOffset(-200, 0)
        OverlapIntersect()

        # em dash
        Select(0u2014)
        Copy()
        PasteWithOffset(320, 0)
        PasteWithOffset(-320, 0)
        Select(0u007c)
        Copy()
        Select(0u2014)
        PasteInto()
        OverlapIntersect()

        # detach and remove .notdef
        Select(".notdef")
        DetachAndRemoveGlyphs()

        SelectWorthOutputting()
        RoundToInt()
        RemoveOverlap()
        RoundToInt()

        fontfamily = "${FONT_FAMILY}"
        fullfamily = fontfamily + " " + fontstyle_list[i]
        postscript_name = ToLower(fontfamily + "-" + fontstyle_list[i])
        SetFontNames(postscript_name, fontfamily, fullfamily, fontstyle_list[i], \\
                     copyright, version)
        
        Generate(postscript_name + ".ttf", "", 0x84)
        Print("Save " + postscript_name + ".ttf")
    Close()
    ++i
endloop

Quit()
EOF

$FONTFORGE -script "${BUILD_PATH}/${GEN_INCONSOLATA}" \
    2> /dev/null || exit 4
$FONTFORGE -script "${BUILD_PATH}/${GEN_MIGU1M}" \
    2> /dev/null || exit 4
$FONTFORGE -script "${BUILD_PATH}/${GEN_RICTY}" \
    2> /dev/null || exit 4

[[ -z "${KEEP_BUILD_PATH}" ]] && rm -rf "$BUILD_PATH"
