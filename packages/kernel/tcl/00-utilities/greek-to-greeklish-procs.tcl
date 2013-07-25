     proc greek_to_greeklish {str} {
	set refgr "αάβγδεέζηήθιΐϊίκλμνξοόπρσςτΰϋυύφχωώ;�ΑΒΓΔΈΕΖΉΗΘΊΙΚΛΜΝΞΌΟΠΡΣΤΎΥΦΧΏΩψ`Ψ"
	set refen "aavgdeezhh8iiiiklmn3ooprsstyyyyfxww?AAVGDEEZHH8IIKLMN3OOPRSTYYFXWWpsPS"
	
	for { set __i 0 } { ${__i} < [string length ${refgr}] } {incr __i} {
		append charmap "[string index ${refgr} ${__i}] [string index ${refen} ${__i}] "
	}
	append charmap ". ."
	return [string map ${charmap} ${str}]
     }
