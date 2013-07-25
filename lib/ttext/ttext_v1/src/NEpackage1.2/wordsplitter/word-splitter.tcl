#!/usr/bin/tclsh


# description: Prepare raw text for input to the POS tagger.  Assumes that
# earlier preprocessing has done sentence segmentation placing each sentence on
# a single line, and leaving each line containing only one sentence.  After
# specifying the input filename on the command line, type "ispell" to get an
# ispell compatible segmentation as opposed to the default POS tagger compatible
# segmentation.


set input_file [lindex $argv 0]
set input_fp [open $input_file r]

set wordSplitForPOS 1 ;# 0 if for ispell

set i 0
while {![eof $input_fp]} {

    # Replace repeated punctuation marks with something equivalent.  These
    # replacements also make simplifying assumptions that will become useful later
    # in this function.
    set Sentence($i) [regsub -all -- {(--+)} [gets $input_fp] {}]
    
    set beforeChange ""
    while { $beforeChange ne $Sentence($i) } {
	set beforeChange $Sentence($i)
	set Sentence($i) [regsub -- {\'\'([^\'[:alpha:]]|$)} $Sentence($i) { \1}]
	set Sentence($i) [regsub -- {(^|[^\'[:alpha:]\.\,\:\;\!\?])\'\'} $Sentence($i) {\1 }]
    }

    # Remove leading and trailing whitespace.
    set Sentence($i) [regsub -- {^\s*(.*?)\s*$} $Sentence($i) {\1}]

    # Separate punctuation marks from each other.
    set Sentence($i) [regsub -- {([^[:alpha:]\s\`])([^[:alpha:]\s\`])} $Sentence($i) {\1 \2}]

    # Separate single quotes that don't look like apostrophes.
    set Sentence($i) [regsub -- {(^|[^[:alpha:]])(\')([:alpha:])} $Sentence($i) {\1\2 \3}]
    set Sentence($i) [regsub -- {([^[:alpha:]])(\')([^[:alpha:]]|$)} $Sentence($i) {\1 \2\3}]

    # The POS tagger wants separated contractions, but ispell doesn't.
    if ($wordSplitForPOS) { 
	set Sentence($i) [regsub -- {(\S)([^[:alpha:]\s\`\.\,\-])} $Sentence($i) {\1 \2}] 
    } else { 
	set Sentence($i) [regsub -- {(\S)([^[:alpha:]\s\`\'\.\,\-])} $Sentence($i) {\1 \2}]
    }
    set Sentence($i) [regsub -- {([^[:alpha:]\s\`\'\.\,\-])(\S)} $Sentence($i) {\1 \2}]

    # Separate opening single quotes from everything else, except keep repeated
    # opening single quotes in pairs.
    set Sentence($i) [regsub -- {([^\`])(\`)} $Sentence($i) {\1 \2}]
    set Sentence($i) [regsub -- {(\`)([^\`])} $Sentence($i) {\1 \2}]
    set beforeChange ""
    while {$beforeChange ne $Sentence($i)} {
	set beforeChange $Sentence($i)
	set Sentence($i) [regsub -- {(^|\s)\`\`\`} $Sentence($i) {\1\`\` \`}]
    }
    
    # Separate stray dashes when they don't seem to be connecting words usefully.
    set Sentence($i) [regsub -- {(\S)(\-)(\s|$)} $Sentence($i) {\1 \2\3}]
    set Sentence($i) [regsub -- {(^|\s)(\-)(\S)} $Sentence($i) {\1\2 \3}]

    # Separate commas from words, but not from within numbers.
    set Sentence($i) [regsub -- {(\S),(\s|$)} $Sentence($i) {\1 ,\2}]
    set Sentence($i) [regsub -- {(^|\s),(\S)} $Sentence($i) {\1, \2}]
    set Sentence($i) [regsub -- {(\D),(\S)} $Sentence($i) {\1 , \2}]
    set Sentence($i) [regsub -- {(\S),(\D)} $Sentence($i) {\1 , \2}]
    
    # Separate numbers from words.
    set Sentence($i) [regsub -- {(\d)([^[^[:alpha:]]\d])} $Sentence($i) {\1 \2}]
    set Sentence($i) [regsub -- {([^[^[:alpha:]]\d])(\d)} $Sentence($i) {\1 \2}]
    
    # Separate words from closing punctuation.
    set Sentence($i) [regsub -- {([:alpha:])(\.)([^[:alpha:]]*)$} $Sentence($i) {\1 \2 \3}]

    if ($wordSplitForPOS) {
	# POS tagger convention.
	set Sentence($i) [regsub -- {\[|\(|\{/\-LBR\-} $Sentence($i) {}]
	set Sentence($i) [regsub -- {\]|\)|\}/\-RBR\-} $Sentence($i) {}]
    }

    puts "$Sentence($i)";

    incr i
}


puts "Sentence count = $i ";



close $input_fp