namespace eval ::pattern {
    namespace ensemble create -subcommands {to_fmt from_fmt match matchall}

    variable fmt_to_pattern
    variable pattern_to_fmt

    array set fmt_to_pattern {
        %A alpha
        %F alnum_plus_ext
        %T lc_alnum_dash_title_optional_ext
        %N naturalnum
        %U uuid
        %H sha1_hex
    }

    foreach {format_group pattern_name} [array get fmt_to_pattern] {
        set pattern_to_fmt($pattern_name) $format_group
    }

}

proc ::pattern::to_fmt {pattern_names} {
    variable pattern_to_fmt
    set result [list]
    foreach pattern_name $pattern_names {
        lappend result $pattern_to_fmt($pattern_name)
    }
    return $result
}

proc ::pattern::from_fmt {format_groups} {
    variable fmt_to_pattern
    set result [list]
    foreach format_group $format_groups {
        lappend result $fmt_to_pattern($format_group)
    }
    return $result
}

proc ::pattern::matchall {pattern_names valueVar} {
    upvar $valueVar value

    foreach pattern_name ${pattern_names} {
        if { ![::pattern::match $pattern_name value] } {
            return 0
        }
    }
    return 1
}

proc ::pattern::match {pattern_name valueVar} {
    upvar $valueVar value

    set llen_pattern [llength $pattern_name]

    if { $llen_pattern > 1 } {

        # composite pattern name

        set llen_value [llength $value]
        if { $llen_value != $llen_pattern } {
            return 0
        }

        foreach p $pattern_name v $value {
            if { ![::pattern::match $p v] } {
                return 0
            }
        }

    } else {

        if { ![::pattern::check=$pattern_name value] } {
            return 0
        }

    }
    return 1
}

proc ::pattern::typeof {value {names ""}} {
    set result [list]
    if { $names eq {} } {
        set names [map x [info procs ::pattern::check=*] {lindex [split [namespace tail $x] {=}] 1}]
    }
    foreach name $names {
        set procname "::pattern::check=${name}"
        if { [${procname} value] } {
            lappend result ${name}
        }
    }
    return ${result}
}

proc ::pattern::check=varchar {valueVar} {
    upvar $valueVar value
    # do nothing, for now
    return 1
}

proc ::pattern::check=bytearr {valueVar} {
    upvar $valueVar value
    # do nothing, for now
    return 1
}

proc ::pattern::check=tcl_namespace {valueVar} {
    upvar $valueVar value
    set re {^(?:\:\:[a-zA-Z_][a-zA-Z_0-9]*)+$}
    return [regexp -- $re $value]
}

proc ::pattern::check=tcl_varname {valueVar} {
    upvar $valueVar value
    set re {^[a-zA-Z_][a-zA-Z_0-9]*$}
    return [regexp -- $re $value]
}

# TODO: sysdb_namespace and sysdb_slot_name belongs to persistence package
# TODO: implement "pattern register" and "pattern unregister" 
proc ::pattern::check=sysdb_namespace {valueVar} {
    upvar $valueVar value
    set re {^(?:\:\:[a-zA-Z_][a-zA-Z_0-9]*)+$}
    return [regexp -- $re $value]
}

proc ::pattern::check=sysdb_slot_name {valueVar} {
    upvar $valueVar value
    set re {^[a-zA-Z_][a-zA-Z_0-9]*$}
    return [regexp -- $re $value]
}

proc ::pattern::check=langclass {valueVar} {
    upvar ${valueVar} value
    # todo: get all valid language codes from db
    # or check the given one with a db query
    lassign [split $value {.}] lang enc
    if { ([string length ${lang}] == 2) && [string is alpha -strict $lang] && $enc in {utf8} } {
        return 1
    }
    return 0
}

proc ::pattern::check=month {valueVar} {
    upvar ${valueVar} value
    if { [string is integer -strict ${value}] && ${value} >= 1 && ${value} <= 12 } {
        return 1
    }
    return 0
}

proc ::pattern::check=year_month {valueVar} {
    upvar ${valueVar} value

    set parts [split ${value} {-}]
    if { [llength ${parts}] == 2 } {
        lassign ${parts} year month
        if { [check=naturalnum year] && [check=month month] } {
            return 1
        }
    }
    return 0
}

proc ::pattern::check=email {valueVar} {
    upvar ${valueVar} value
    set re {^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$}
    if { [regexp -nocase -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=uri {valueVar} {
    upvar ${valueVar} value
    set re {^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$}
    if { [regexp -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=url {valueVar} {
    upvar ${valueVar} value

    set re {^(https?|ftp|file)://.+$}
    if { [check=uri value] && [regexp -nocase -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=ip {valueVar} {
    upvar ${valueVar} value
    set re {^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$}
    if { [regexp -nocase -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=domain {valueVar} {
    upvar ${valueVar} value

    # Below pattern makes sure domain name matches the following criteria :
    #
    # The domain name should be a-z | A-Z | 0-9 and hyphen(-)
    # The domain name should between 1 and 63 characters long
    # Last Tld must be at least two characters, and a maximum of 6 characters
    # The domain name should not start or end with hyphen (-) (e.g. -google.com or google-.com)
    # The domain name can be a subdomain (e.g. mkyong.blogspot.com)
    #
    # http://www.mkyong.com/regular-expressions/domain-name-regular-expression-example/

    set re {^(?:(?:[^\-])[A-Za-z0-9-]{0,62}(?:[^\-])\.)+[A-Za-z]{2,6}$}

    if { [regexp -nocase -- ${re} ${value}] } {

        # https://publicsuffix.org/list/public_suffix_list.dat
        #
        # TODO: Once it passes the initial check, check against 
        # full suffix list (see below) as follows:
        # 1. Retrieve list from database, or file.
        # 2. Retrieve (updated) list from the given url.
        #
        # TODO: Create a wrapper/feed for the given url.

        return 1
    }
    return 0

}

proc ::pattern::check=reversedomain {valueVar} {
    upvar ${valueVar} value
    set domain [join [lreverse [split ${value} {.}]] {.}]
    return [check=domain domain]
}


proc ::pattern::check=sha1_hex {valueVar} {
    upvar ${valueVar} value
    set re {^[0123456789abcdef]{40}$}
    if { [regexp -nocase -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=md5_hex {valueVar} {
    upvar ${valueVar} value
    set re {^[0123456789abcdef]{32}$}
    if { [regexp -nocase -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=lc_alnum_dash_title_optional_ext {valueVar} {
    upvar ${valueVar} value
    set re {^-?(?:[a-z0-9]+-)+[a-z0-9]+-?(?:\.[a-z0-9]{1,4})?$}
    return [regexp -- ${re} ${value}]
}

proc ::pattern::check=alnum_plus_ext {valueVar} {
    upvar ${valueVar} value
    set re {^[A-Za-z0-9]+\.[a-z0-9]{1,4}$}
    return [regexp -- ${re} ${value}]
}

proc ::pattern::check=boolean {valueVar} {
    upvar ${valueVar} value
    return [string is boolean -strict ${value}]
}

proc ::pattern::check=notnull {valueVar} {
    upvar ${valueVar} value
    return [expr { $value ne {} }]
}

proc ::pattern::check=required {valueVar} {
    upvar ${valueVar} value
    return [info exists {value}]
}

proc ::pattern::check=uuid {valueVar} {
    upvar ${valueVar} value
    set re {^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{6,}$}
    return [regexp -- ${re} ${value}]
}


# -------------------------------- strings ----------------------------------------

proc ::pattern::check=uppercase {valueVar} {
    upvar ${valueVar} value
    if { [string toupper ${value}] eq ${value} } {
        return 1
    }
    return 0
}

proc ::pattern::check=lowercase {valueVar} {
    upvar ${valueVar} value
    if { [string tolower ${value}] eq ${value} } {
        return 1
    }
    return 0
}

proc ::pattern::check=alpha {valueVar} {
    upvar ${valueVar} value
    return [string is alpha -strict ${value}]
}

proc ::pattern::check=alnum {valueVar} {
    upvar ${valueVar} value
    return [string is alnum -strict ${value}]
}

proc ::pattern::check=ascii {valueVar} {
    upvar ${valueVar} value
    return [string is ascii -strict ${value}]
}


# -------------------------------- numbers ----------------------------------------

proc ::pattern::check=integer {valueVar} {
    upvar ${valueVar} value
    return [string is integer -strict ${value}]
}

proc ::pattern::check=naturalnum {valueVar} {
    upvar ${valueVar} value
    if { [string is entier -strict ${value}] && ${value} >= 0 } {
        return 1
    }
    return 0
}

# clock format 0 -format "%Y%m%dT%H:%M"
# => 19700101T03:01
proc ::pattern::check=timestamp {valueVar} {
    upvar ${valueVar} value
    return [check=naturalnum value]
}

proc ::pattern::check=double {valueVar} {
    upvar ${valueVar} value
    return [string is double -strict ${value}]
}

# proc ::pattern::check=entier {valueVar} {
#    upvar ${valueVar} value
#    return [string is entier -strict ${value}]
# }


proc ::pattern::check=float {valueVar} {
    upvar ${valueVar} value
    set re {^[-+]?[0-9]*\.?[0-9]+$}
    if { [regexp -- ${re} ${value}] } {
        return 1
    }
    return 0
}

proc ::pattern::check=float_optional_exp {valueVar} {
    upvar ${valueVar} value
    set re {^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$}
    if { [regexp -- ${re} ${value}] } {
        return 1
    }
    return 0
}

# -------------------------------- dates ------------------------------------------

proc ::pattern::is_valid_date {valueVar re submatch_vars} {
    upvar ${valueVar} value

    set match_p [regexp -nocase -- ${re} ${value} _dummy_ {*}${submatch_vars}] 

    if { ${match_p}} {

        if { ${day} == 31 && (${month} == 4 || ${month} == 6 || ${month} == 9 || ${month} == 11) } {

            return 0; # 31st of a month with 30 days

        } elseif { ${day} >= 30 && ${month} == 2 } {

            return 0; # February 30th or 31st

        } elseif { ${month} == 2 && ${day} == 29 && !(${year} % 4 == 0 && (${year} % 100 != 0 || ${year} % 400 == 0)) } {

            return 0; # February 29th outside a leap year

        } else {

            return 1; # Valid date

        }

    }
    return 0
}

# matches a date in yyyy-mm-dd format from between 1900-01-01 and 2099-12-31, 
# with a choice of four separators.
# require the delimiters to be consistent, it will match 1999-01-01 but not 1999/01-01
proc ::pattern::check=yyyy-mm-dd {valueVar} {
    upvar ${valueVar} value
    set re {^((?:19|20)\d\d)([- /.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])$}
    return [is_valid_date value ${re} {year delimiter month day}]
}

proc ::pattern::check=mm-dd-yyyy {valueVar} {
    upvar ${valueVar} value
    set re {^(0[1-9]|1[012])([- /.])(0[1-9]|[12][0-9]|3[01])\2((?:19|20)\d\d)$}
    return [is_valid_date value ${re} {month delimiter day year}]
}

proc ::pattern::check=dd-mm-yyyy {valueVar} {
    upvar ${valueVar} value
    set re {^(0[1-9]|[12][0-9]|3[01])([- /.])(0[1-9]|1[012])\2((?:19|20)\d\d)$}
    return [is_valid_date value ${re} {day delimiter month year}]
}

proc ::pattern::check=date_YYYYmmdd {valueVar} {
    upvar ${valueVar} value
    set re {^((?:19|20)\d\d)(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$}
    return [is_valid_date value ${re} {year month day}]
}

proc ::pattern::check=time_HHMM {valueVar} {
    upvar ${valueVar} value

    if { [string length $value] != 4 } {
        return 0
    }

    set hours [string range $value 0 1]
    set minutes [string range $value 2 3]
    
    if { $hours >= 0 && $hours <= 23 } {
        if { $minutes >= 0 && $minutes <= 59 } {
            return 1
        }
    }
    return 0
}

# datetime_YYYYmmddTHH:MM
proc ::pattern::check=datetime {valueVar} {
    upvar $valueVar value
    lassign [split $value {T}] date time
    return [expr { [check=date_YYYYmmdd date] && [check=time_HHMM time] }]
}



# -------------------------------- credit card numbers ----------------------------
# see http://www.regular-expressions.info/creditcard.html

# All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13. 
proc ::pattern::check=cc_visa {valueVar} {
    upvar ${valueVar} value
    set re {^4[0-9]{12}(?:[0-9]{3})?$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# All MasterCard numbers start with the numbers 51 through 55. All have 16 digits. 
proc ::pattern::check=cc_mastercard {valueVar} {
    upvar ${valueVar} value
    set re {^5[1-5][0-9]{14}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# American Express card numbers start with 34 or 37 and have 15 digits
proc ::pattern::check=cc_amex {valueVar} {
    upvar ${valueVar} value
    set re {^3[47][0-9]{13}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits. 
# There are Diners Club cards that begin with 5 and have 16 digits. 
# These are a joint venture between Diners Club and MasterCard, and should be 
# processed like a MasterCard. 
proc ::pattern::check=cc_diners_club {valueVar} {
    upvar ${valueVar} value
    set re {^3(?:0[0-5]|[68][0-9])[0-9]{11}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# Discover card numbers begin with 6011 or 65. All have 16 digits. 
proc ::pattern::check=cc_discover {valueVar} {
    upvar ${valueVar} value
    set re {^6(?:011|5[0-9]{2})[0-9]{12}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits. 

proc ::pattern::check=cc_jcb {valueVar} {
    upvar ${valueVar} value
    set re {^(?:2131|1800|35\d{3})\d{11}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}



# ---------------------------------------------------------------------------------




proc ::pattern::check=novirus {valueVar} {
    upvar ${valueVar} value
    # TODO: check with clamav
    if { 0 } {
	return 1
    }
    return 0
}


