#!/bin/sh

latex \\nonstopmode\\input ${1}.tex >/dev/null 2>&1


(dvips -E -q -f ${1}.dvi | gs -q -dNOPAUSE -dNO_PAUSE -dBATCH -dSAFER -sDEVICE=ppmraw -dTextAlphaBits=4 -r100 -sOutputFile=- - | pnmcrop | ppmtogif -interlace -transparent rgb:b2/b2/b2 > ${1}.gif) > /dev/null 2>&1

exit

# (dvips -E -q -f ${1}.dvi | gs -q -dNOPAUSE -dNO_PAUSE -dBATCH -dSAFER -sDEVICE=ppmraw -dTextAlphaBits=4 -r150 -sOutputFile=- - | pnmgamma 1.0 | ppmdim 0.7 | pnmscale 0.75 | pnmcrop | ppmtogif -interlace -transparent rgb:b2/b2/b2 > ${1}.gif) > /dev/null 2>&1

# gs -q -dNOPAUSE -dNO_PAUSE -dBATCH -dSAFER -sDEVICE=ppmraw -dTextAlphaBits=4 -r100x100 -sOutputFile=${1}.ppm ${1}.ps

# (pnmcrop ${1}.ppm | pnmgamma 1.0 | ppmdim 0.7 | pnmscale 0.75 | ppmtogif -interlace -transparent rgb:b2/b2/b2 > ${1}.gif) > /dev/null 2>&1
