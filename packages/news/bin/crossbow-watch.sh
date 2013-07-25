#!/bin/sh
watch -n 1 "ps ax | grep tc-crossbow-one.sh | head -n 1 && echo --- && ls -r ~/data/news/model-crossbow/*/crossbow-words-* | head -n 1 && echo --- && ps ax | grep psql | head -n 1 && echo --- && ls -r ~/data/news/model-crossbow/*/crossbow-words.done 2> /dev/null"
