#!/bin/sh
for file in `ls images/*`
do
    convert -sample 80x80 $file ${file}-sample-80x80.jpg
done
