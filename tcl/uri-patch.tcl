ns_eval {
    package require uri

    namespace eval ::uri {
	namespace eval basic {
	    variable        alphaDigitMinusUnderscore {[A-Za-z0-9\-\_]}
	    variable        domainlabel     \
		"(${alphaDigit}${alphaDigitMinusUnderscore}*${alphaDigit}|${alphaDigit})"
	    variable        hostname        \
		"((${domainlabel}\\.)*${toplabel})"
	    variable        hostnumber      \
		"(${digits}\\.${digits}\\.${digits}\\.${digits})"
	    variable        host            "(${hostname}|${hostnumber})"
	    variable        port            $digits
	    variable        hostOrPort      "${host}(:${port})?"
	}
    }
}
