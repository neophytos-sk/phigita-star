#!/usr/bin/tclsh

namespace eval ::ttext {;}
namespace eval ::ttext::ss {;}

proc ::ttext::ss::Process {paragraph} {

    # Split the paragraph into words
    set words [split $paragraph " "]
    set lastIndex [expr {[llength $paragraph] - 1}]
    set sentence ""
    set prev_word ""
    set prev_prev_word ""
    set i 0
    foreach newword $words {

	# Print the words
	#puts "word is: ($newword)";


	# Check the existence of a candidate (perl: rindex)
	set pos -1
	set candidate ""
	foreach candidate_char {. ? ! ; :} {
	    set candidate_pos [string first $candidate_char $newword]
	    if { $candidate_pos > $pos } {
		set pos $candidate_pos
		set candidate $candidate_char
	    }
	}

	# Do the following only if the word has a candidate
	if { $pos != -1 } {
	    # Check the previous word
	    if { $prev_word eq {} } {
		set wm1 NP
		set wm1C NP
		set wm2 NP
		set wm2C NP
	    } else {
		set wm1 $prev_word
		set wm1C [::ttext::ss::StartsWithCapital $wm1]

		# Check the word before the previous one 
		if { $prev_prev_word eq {} } {
		    set wm2 NP
		    set wm2C NP
		} else {
		    set wm2 $prev_prev_word
		    set wm2C [::ttext::ss::StartsWithCapital $wm2]
		}

		# Check the next word
		set next_word_i [expr {$i + 1}]
		if { $next_word_i > $lastIndex } {
		    set wp1 NP
		    set wp1C NP
		    set wp2 NP
		    set wp2C NP
		} else {
		    set wp1 [lindex $words $next_word_i]
		    set wp1C [::ttext::ss::StartsWithCapital $wp1]
		    
		    # Check the word after the next one 
		    set next_next_word_i [expr {$next_word_i + 1}]
		    if { $next_next_word_i > $lastIndex } {
			set wp2 "NP"
			set wp2C "NP"
		    } else {
			set wp2 [lindex $words $next_next_word_i]
			set wp2C [::ttext::ss::StartsWithCapital $wp2]
		    }
		}

		# Define the prefix
		if { $pos == 0 } {
		    set prefix "sp"
		} else {
		    set prefix [string range $newword 0 $pos]
		}
		set prC [::ttext::ss::StartsWithCapital $prefix]
		
		# Define the suffix
		if { $pos == [string length $newword] - 1 } {
		    set suffix "sp"
		} else {
		    set suffix [string range [expr {$pos + 1}] end]
		}
		
		set suC [::ttext::ss::StartsWithCapital $suffix]
		
		# Call the Sentence Boundary subroutine
		set prediction [::ttext::ss::Boundary \
				    $candidate $wm2 $wm1 $prefix $suffix \
				    $wp1 $wp2 $wm2C $wm1C $prC $suC \
				    $wp1C $wp2C]


		# Append the word to the sentence
		append sentence " "
		append sentence $newword

		if { $prediction eq {Y} } {
		    # Eliminate any leading whitespace
		    set sentence [string trim $sentence]
		    puts $sentence
		    set sentence ""
		}
	    } 
	} else {
	    # If the word doesn't have a candidate, then append the word to the sentence
	    append sentence " "
	    append sentence $newword
	}

	set prev_prev_word $prev_word
	set prev_word $newword
	incr i

    }

    if { $sentence ne {} } {
	# Eliminate any leading whitespace
	set sentence [string trim $sentence]
    }
    puts $sentence 
    set sentence ""

}


# This subroutine does all the boundary determination stuff
# It returns "Y" if it determines the candidate to be a sentence boundary,
# "N" otherwise
proc ::ttext::ss::Boundary {candidate wm2 wm1 prefix suffix wp1 wp2 wm2C wm1C prC suC wp1C wp2C} {

    # HERE: Debug
    #puts "candidate=$candidate, wm2=$wm2, wm1=$wm1, prefix=$prefix, suffix=$suffix, wp1=$wp1, wp2=$wp2, wm2C=$wm2C, wm1C=$wm1C, prC=$prC, suC=$suC, wp1C=$wp1C, wp2C=$wp2C"


    # Check if the candidate was a question mark or an exclamation mark
    if { $candidate eq {?} || $candidate eq {!} } {

	# Check for the end of the file
	if { $wp1 eq {NP} && $wp2 eq {NP} } {
	    return "Y"
	}

	# Check for the case of a question mark followed by a capitalized word
	if { $suffix eq {sp} && $wp1C eq {Y} } {
	    return "Y"
	}
	if { $suffix eq {sp} && [::ttext::ss::StartsWithQuote $wp1] } {
	    return "Y"
	}
	if { $suffix eq {sp} && $wp1 eq {--} && $wp2C eq {Y} } {
	    return "Y"
	}
	if { $suffix eq {sp} && $wp1 eq {-RBR-} && $wp2C eq {Y} } {
	    return "Y"
	}

	# This rule takes into account vertical ellipses, as shown in the
	# training corpus. We are assuming that horizontal ellipses are
	# represented by a continuous series of periods. If this is not a
	# vertical ellipsis, then it's a mistake in how the sentences were
	# separated.
	if { $suffix eq "sp" && $wp1 eq {.} } {
	    return "Y"
	}
	if { [::ttext::ss::IsRightEnd $suffix] && [::ttext::ss::IsLeftStart $wp1] } {
	    return "Y"
	} else {
	    return "N"
	}
    } else {
	# Check for the end of the file
	if { $wp1 eq {NP} && $wp2 eq {NP} } {
	    return "Y"
	}
	if { $suffix eq {sp} && [::ttext::ss::StartsWithQuote $wp1] } {
	    return "Y"
	}
	if { $suffix eq {sp} && [::ttext::ss::StartsWithLeftParen $wp1] } {
	    return "Y"
	}
	if { $suffix eq {sp} && $wp1 eq {-RBR-} && $wp2 eq {--} } {
	    return "N"
	}
	if { $suffix eq {sp} && [::ttext::ss::IsRightParen $wp1] } {
	    return "Y"
	}
	# Added by Ramya Nagarajan 6/19/01
	# This takes account of the numbered lists seen in the TREC/TIPSTER_V3
	# data files.
	if { $candidate eq {.} && $suffix eq {sp} && [EndsWithRightParen $wp1] && $wp2C eq {Y} } {
	    return "Y"
	}
	# This rule takes into account vertical ellipses, as shown in the
	# training corpus. We are assuming that horizontal ellipses are
	# represented by a continuous series of periods. If this is not a
	# vertical ellipsis, then it's a mistake in how the sentences were
	# separated.
	if { $prefix eq {sp} && $suffix eq {sp} && $wp1 eq {.} } {
	    return "N"
	}
	if { $suffix eq {sp} && $wp1 eq {.} } {
	    return "Y"
	}
	if { $suffix eq {sp} && $wp1 eq {--} && $wp2C eq {Y} && [EndsInQuote $prefix] } {
	    return "N"
	}
	if { $suffix eq {sp} && $wp1 eq {--} && ( $wp2C eq {Y} || [::ttext::ss::StartsWithQuote $wp2] ) } {
	    return "Y"
	}
	if { $suffix eq {sp} && $wp1C eq {Y} && ( $prefix eq {p.m} || $prefix eq {a.m} ) && [::ttext::ss::IsTimeZone $wp1] } {
	    return "N"
	}
	# Check for the case when a capitalized word follows a period,
	# and the prefix is a honorific
	if { $suffix eq {sp} && $wp1C eq {Y} && [::ttext::ss::IsHonorific ${prefix}.] } {
	    return "N"
	}
	# Check for the case when a capitalized word follows a period,
	# and the prefix is a honorific
	if { $suffix eq {sp} && $wp1C eq {Y} && [::ttext::ss::StartsWithQuote $prefix] } {
	    return "N"
	}
	# This rule checks for prefixes that are terminal abbreviations
	if { $suffix eq {sp} && $wp1C eq {Y} && [::ttext::ss::IsTerminal $prefix] } {
	    return "Y"
	}
	# Check for the case when a capitalized word follows a period and the
	# prefix is a single capital letter
	if { $suffix eq {sp} && $wp1C eq {Y} && [regexp -- {^([A-ZΑ-ΩΆΈΊΪΫ]\.)*[A-ZΑ-ΩΆΈΊΪΫ]$} $prefix] } {
	    return "N"
	}
	# Check for the case when a capitalized word follows a period
	if { $suffix eq {sp} && $wp1C eq {Y} } {
	    return "Y"
	}
	if { [::ttext::ss::IsRightEnd $suffix] && [::ttext::ss::IsLeftStart $wp1] } {
	    return "Y"
	}
    }
    return "N"
}


# This subroutine checks to see if the input string is equal to an element
# of the @honorifics array.
proc ::ttext::ss::IsHonorific { word } {

    global HONORIFICS
    return [info exists HONORIFICS($word)]

}

# This subroutine checks to see if the string is a terminal abbreviation.
proc ::ttext::ss::IsTerminal { word } {

    global TERMINALS
    return [info exists TERMINALS($word)]

}

# This subroutine checks if the string is a standard representation of a U.S.
# timezone
proc ::ttext::ss::IsTimeZone { word } {

    global TIMEZONES
    return [info exists TIMEZONES($word)]

}

# This subroutine checks to see if the input word ends in a closing double
# quote.
proc ::ttext::ss::EndsInQuote { word } {

    set lastChar [string index $word end]
    if { $lastChar eq "'" || $lastChar eq "\"" } {
	return 1
    } else {
	return 0
    }

}

# This subroutine checks to see if a given word starts with one or more quotes
proc ::ttext::ss::StartsWithQuote { word } {

    set firstChar [string index $word 0]
    if { $firstChar eq "'" || $firstChar eq "\"" } {
      return 1
    } else {
      return 0
    }
}

# This subroutine checks to see if a word starts with a left parenthesis, be it
# {, ( or <
proc ::ttext::ss::StartsWithLeftParen { word } {
    set firstChar [string index $word 0]
    if { $firstChar eq "\{" || $firstChar eq "(" || [string range $word 0 4] eq {-LBR-} } {
	return 1
    } else {
	return 0
    }
}

# Added by Ramya Nagarajan 6/19/01
# This subroutine checks to see if a word ends with a right parenthesis, be it
# }, ) or >
proc ::ttext::ss::EndsWithRightParen { word } {

    set lastChar [string index $word end]

    if { $lastChar eq "\}" || $lastChar eq ")" || [string range $word end-3 end] eq {-RBR-} } {
	return 1
    } else {
	return 0
    }

}


# This subroutine checks to see if a word starts with a left quote, be it
# `, ", "`, `` or ```
proc ::ttext::ss::StartsWithLeftQuote { word } {

    set firstChar [string index $word 0]
    if { $firstChar eq "`" || firstChar eq "\"" || firstChar eq "'" } {
	return 1
    } else {
	return 0
    }

}


proc ::ttext::ss::IsRightEnd { word } {
    
    if { [::ttext::ss::IsRightParen $word] || [::ttext::ss::IsRightQuote $word] } {
	return 1
    } else {
	return 0
    }

}

# This subroutine detects if a word starts with a start mark.
proc ::ttext::ss::IsLeftStart { word } {

    if { [::ttext::ss::StartsWithLeftQuote $word] || [::ttext::ss::StartsWithLeftParen $word] || [::ttext::ss::StartsWithCapital $word] eq "Y" } {
	return 1
    } else {
	return 0
    }

}

# This subroutine checks to see if a word is a right parenthesis, be it ), }
# or >
proc ::ttext::ss::IsRightParen { word } {

    if { $word eq "\}" ||  $word eq ")" || $word eq {-RBR-} } {
	return 1
    } else {
	return 0
    }

}

proc ::ttext::ss::IsRightQuote { word } {

    if { $word eq {'} ||  $word eq {''} || $word eq {'''} || $word eq "\"" || $word eq "'\"" } {
	return 1
    } else {
	return 0
    }

}

# This subroutine returns "Y" if the argument starts with a capital letter.
proc ::ttext::ss::StartsWithCapital { word } {

    global CAPITAL_LETTERS

    set firstChar [string index $word 0]
    if { [info exists CAPITAL_LETTERS($firstChar)] } {
	return "Y"
    } else {
	return "N"
    }

}

########


set honorifics_file [lindex $argv 0]
set input_file [lindex $argv 1]



global HONORIFICS
set honorifics_fp [open $honorifics_file r]
array set honorifics [list]
while {![eof $honorifics_fp]} {
    set HONORIFICS([string trim [gets $honorifics_fp]]) ""
}
close $honorifics_fp

global TERMINALS
array set TERMINALS [list]
foreach terminal {Esq Jr Sr M.D} {
    set TERMINALS($terminal) ""
}

global TIMEZONES
array set TIMEZONES [list]
foreach timezone {EDT CST EST} {
    set TIMEZONES($timezone) ""
}

global CAPITAL_LETTERS
foreach letter {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z Α Β Γ Δ Ε Ζ Η Θ Ι Κ Λ Μ Ν Ξ Ο Π Ρ Σ Τ Υ Φ Χ Ψ Ω Ά Έ Ί Ϊ Ϋ} {
    set CAPITAL_LETTERS($letter) ""
}

set input_fp [open $input_file r]
set paragraph ""
while {![eof $input_fp]} {

    # Read a line
    set newline [string trim [gets $input_fp]]

    if { [string trim $newline] eq {} } { 
	# If next line is empty

	::ttext::ss::Process $paragraph
	set paragraph ""

    } else {
	# If next line is not empty

	# Eliminate any leading whitespace
	set newline [string trim $newline]

	# Take care of the hyphens
	if { [string index $paragraph end] eq {-} && [string index $paragraph end-1] ne {-} } {
	    set paragraph [string trimleft $paragraph {-}]
	    append paragraph $newline
	} else {
	    append paragraph " "
	    append paragraph $newline
	}
    }
}
::ttext::ss::Process $paragraph
close $input_fp