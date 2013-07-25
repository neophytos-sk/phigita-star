#!/bin/bash

latex \\nonstopmode\\input $1 >/dev/null 2>&1

dvips -q -f test.dvi > temp.ps

gs -q -dNOPAUSE -dNO_PAUSE -dBATCH -sDEVICE=ppmraw -r85 -sOutputFile=temp.ppm temp.ps

(pnmcrop temp.ppm | ppmtogif -interlace -transparent rgb:b2/b2/b2 > temp.gif) > /dev/null 2>&1

(pnmcrop temp.ppm | pnmgamma 1.0 | ppmdim 0.7 | pnmscale 0.75 | ppmtogif -interlace -transparent rgb:b2/b2/b2 > temp.gif) > /dev/null 2>&1
