#!/usr/bin/tclsh


set input_filename [lindex $argv 0]

set base "."

set sentencebound ${base}/tmp/sentbound.tmp
set wordsplit ${base}/tmp/wordsplit.tmp
set columninput ${base}/tmp/columninput.tmp
set classout ${base}/tmp/classout.tmp
set finalcolumn ${base}/tmp/finalcolumn.tmp
set FEX ${base}
set INFERENCEDIR ${base}/cscl
set SNOW ${base}/snow/snow
set LISTNE ${base}/newlistne/UpperCaseNEAll.tcl
set LISTCOLIFY ${base}/newlistne/makelistscolumn.tcl
set TARGETLEXICON ${base}/labelsFromLexicon.txt

# listne related files

set listoutput ${base}/tmp/listoutput.tmp
set listcolumn ${base}/tmp/listcolumn.tmp
set colone ${base}/tmp/colone.tmp
set colrest ${base}/tmp/colrest.tmp

namespace eval ::util {;}

proc ::util::exec {cmd} {
    append cmd  " || exit 0"
    puts "### Executing $cmd"
    ::exec -- /bin/sh -c $cmd 2> /dev/null
}

puts "### Preprocess - sentence boundary"

::util::exec "${base}/sentence-boundary/sentence-boundary.tcl ${base}/sentence-boundary/HONORIFICS $input_filename > $sentencebound"

puts "### Preprocess - word splitter"

::util::exec "${base}/wordsplitter/word-splitter.tcl $sentencebound > $wordsplit"

puts "### Creating col format text... writing to $columninput..."

::util::exec "${base}/NEClassifier.pl test.txt"