#!/bin/bash
testtextcat="../libtool --mode=execute -dlopen ../src/.libs/libexttextcat*.la"
if [ "$VALGRIND" != "" ]; then
    testtextcat="$testtextcat valgrind --tool=$VALGRIND --leak-check=yes --show-reachable=yes --quiet --error-exitcode=101"
fi
testtextcat="$testtextcat ../src/testtextcat"
#take second guess
res=`cat ../langclass/ShortTexts/$1.txt | $testtextcat ../langclass/fpdb.conf ../langclass/LM/ | sed -e "s/^.[^]]*]//" | sed -e "s/].*/]/" | sed -e "s/zh-CN/zh-Hans/" | sed -e "s/zh-TW/zh-Hant/" | sed -e "s/--utf8//" | sed -e "s/-utf8//" | sed -e "s/^\[sh\]$/\[sr-Latn\]/"`
if [ $res == "[$1]" ]; then
    exit 0
else
    exit 1
fi
