#!/bin/sh

psql -q -h turing -U postgres -f $1 newsdb
rm -f $1

