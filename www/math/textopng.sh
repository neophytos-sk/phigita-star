#!/bin/sh

latex \\nonstopmode\\input ${1}.tex >/dev/null 2>&1

/usr/bin/dvipng -q --t1lib1 -D 110 -o ${1}.png -T tight -bg 'rgb 0.75 0.75 0.75' -bg 'Transparent' ${1}.dvi 


exit

