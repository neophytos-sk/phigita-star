#!/bin/sh
rm -rf ../tc/model
./rainbow -d ../tc/model/ --lex-white --index ../tc/news-in-greek/*
./rainbow -d ../tc/model/ --lex-white --forking-query-server=1821
