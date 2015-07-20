package provide stockquote 0.1

::xo::lib::require curl

namespace eval ::ext::StockQuote {;}

proc ::ext::StockQuote::readFile {filename args} {
    set fp [open $filename]
    foreach varName $args {
	upvar $varName __$varName
	::xo::io::readVarText $fp __$varName utf-8
    }
    close $fp
}

proc ::ext::StockQuote::writeFile {filename args} {
    set fp [open $filename w]
    foreach varName $args {
	upvar $varName __$varName
	::xo::io::writeVarText $fp [set __$varName] utf-8
    }
    close $fp
}

proc ::ext::StockQuote::get_daily_prices {metadataVar dataVar exchange {date ""}} {
    upvar ${metadataVar} metadata
    upvar ${dataVar} data

    array set provider {
	NYSE   Yahoo
	NASDAQ Yahoo
	CSE    CSE
	ASE    Stockwatch
    }


    ::ext::StockQuote::$provider($exchange).get_daily_prices metadata data $exchange $date
}



proc ::ext::StockQuote::get_daily_prices_if {metadataVar dataVar exchange {date ""}} {
    upvar $metadataVar metadata
    upvar $dataVar data

    set dir /web/data/finance/daily_prices
    file mkdir $dir
    set filename [file join $dir StockQuote.${exchange}.${date}.db]

    if { [file exists $filename] } {
	::ext::StockQuote::readFile $filename metadata data
    } else {
	::ext::StockQuote::get_daily_prices metadata data $exchange $date
	::ext::StockQuote::writeFile $filename metadata data
    }
    
}





proc ::ext::StockQuote::get_intraday_prices {metadataVar dataVar exchange symbol {date ""}} {
    upvar ${metadataVar} metadata
    upvar ${dataVar} data

    array set provider {
	NYSE   Yahoo
	NASDAQ Yahoo
	CSE    Xak
    }

    #CSE    CSE
    #ASE    Stockwatch

    ::ext::StockQuote::$provider($exchange).get_intraday_prices metadata data $exchange $symbol $date
}



proc ::ext::StockQuote::get_intraday_prices_if {metadataVar dataVar exchange symbol {date ""}} {
    upvar $metadataVar metadata
    upvar $dataVar data

    set dir /web/data/finance/intraday_prices
    file mkdir $dir
    set filename [file join $dir StockQuote.${exchange}.${date}.db]

    if { [file exists $filename] } {
	::ext::StockQuote::readFile $filename metadata data
    } else {
	::ext::StockQuote::get_intraday_prices metadata data $exchange $symbol $date
	::ext::StockQuote::writeFile $filename metadata data
    }
    
}



proc ::ext::StockQuote::get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar ${metadataVar} metadata
    upvar ${dataVar} data

    # NYSE - New York Stock Exchange
    # ASE - Athens Stock Exchange
    # CSE - Cyprus Stock Exchange
    # TSE - Toronto Stock Exchange
    array set provider_list {
	NYSE   {Yahoo Google}
	NASDAQ {Yahoo Google}
	CSE    Stockwatch
	ASE    Stockwatch
	TSE    {Google QuoteMedia}
	FX     OANDA
    }
    # FX <- GAIN Capital (ratedata.gaincapital.com)

    foreach provider $provider_list($exchange) {
	::ext::StockQuote::${provider}.get_historical_prices _metadata($provider) _data($provider) $exchange $symbol $start_date $end_date
    }

    # results to be returned
    set main_provider [lindex $provider_list($exchange) 0]
    set metadata $_metadata($main_provider)
    set data $_data($main_provider)

    # check that historical prices from different providers match
    foreach provider $provider_list($exchange) {
	if { $data ne $_data($provider) } {
	    set error_file_other "/web/data/finance/error_file_${symbol}_by_${provider}.data"
	    set error_file_main "/web/data/finance/error_file_${symbol}_by_${main_provider}.data"

	    set fp [open $error_file_other w]
	    puts $fp $_data($provider)
	    close $fp
	    set fp [open $error_file_main w]
	    puts $fp $data
	    close $fp
	    ns_log error "data from $provider does not match with $main_provider" "" ""
	}
    }

}


proc ::ext::StockQuote::compact_historical_prices {prefix} {
    set filelist [lsort -decreasing [glob -nocomplain ${prefix}.*.db]]
    if { 1==[llength $filelist] } {
	return
    }

    set timestamp [clock seconds]
    set ofp [open ${prefix}.${timestamp}.db-merge w]
    foreach filename $filelist {
	set ifp [open $filename]
	puts $ofp [read $ifp]	
	close $ifp
	file delete $filename
    }
    close $ofp
}


namespace eval ::util {;}
proc ::util::versioned_file_compare {splitChars index file1 file2} {
    set n1 [lindex [split $file1 $splitChars] $index]
    set n2 [lindex [split $file2 $splitChars] $index]
    if { $n1 < $n2 } {
	return -1
    } elseif { $n1 > $n2 } {
	return 1
    } else {
	return 0
    }
}



proc ::ext::StockQuote::load_historical_prices_if {metadataVar dataVar exchange symbol} {
    upvar $metadataVar metadata
    upvar $dataVar data

    set dir /web/data/finance/historical_prices
    set prefix StockQuote.${exchange}.${symbol}
    set dbFileList [lsort -integer -increasing -command [list ::util::versioned_file_compare "." end-1] [glob -nocomplain -directory $dir ${prefix}.*.db]]

    #ns_log notice "load_historical_prices_if dbFileList = $dbFileList"

    # TODO: check by date range, and get ranges not covered by our data

    if { $dbFileList ne {} } {

	set metadata_chunks [list]
	set data_chunks [list]

	foreach dbFileName ${dbFileList} {
	    ::ext::StockQuote::readFile $dbFileName metadata_chunk data_chunk
	    #set fp [open $dbFileName]
	    #::xo::io::readVarText $fp metadata_chunk
	    #::xo::io::readVarText $fp data_chunk
	    #close $fp
	    
	    lappend metadata_chunks $metadata_chunk
	    lappend data_chunks $data_chunk
	}

	set metadata $metadata_chunk
	dict set metadata range StartDate [dict get [lindex $metadata_chunks 0] range StartDate]
	
	set data [join ${data_chunks}]
	return 1
    }

    return 0
}

proc ::ext::StockQuote::get_historical_prices_if {metadataVar dataVar exchange symbol start_date {end_date ""} {datasourceVar ""}} {
    upvar $metadataVar metadata
    upvar $dataVar data

    set dir /web/data/finance/historical_prices
    file mkdir $dir

    if { $end_date eq {} } {
	set end_date [::xo::dt::today]
    }

    if { $datasourceVar ne {} } {
	upvar $datasourceVar datasource
    }

    if { [load_historical_prices_if metadata data ${exchange} ${symbol}] } {

	set cache_start_date [dict get $metadata range StartDate]
	set cache_end_date [dict get $metadata range EndDate]

	# start from where we stopped last time
	set format "%Y-%m-%d"
	set start_date [clock format [clock add [clock scan $cache_end_date -format $format] 1 days] -format $format] ;# add 1 day to $cache_end_date

	ns_log notice "new_start_date = $start_date"
    }

    if { [::xo::dt::date_compare $start_date $end_date] <= 0 } {
	set metadata ""
	set data ""
	set errorcode [get_historical_prices metadata data $exchange $symbol $start_date $end_date]

	dict set metadata auditing last_ping [clock seconds]

	if { $errorcode } {
	    return $errorcode
	} else {
	    
	    set timestamp [clock seconds]
	    set dbFileName [file join $dir StockQuote.${exchange}.${symbol}.${timestamp}.db]

	    ::ext::StockQuote::writeFile $dbFileName metadata data
	    #set fp [open $dbFileName w]
	    #::xo::io::writeVarText $fp $metadata
	    #::xo::io::writeVarText $fp $data
	    #close $fp

	    #compact_historical_prices ${prefix}
	}

    }

    load_historical_prices_if metadata data ${exchange} ${symbol}

    return 0
}


# A stock split occurs when a company replaces each of their 
# existing shares with a number of new shares, in such a way
# that the company's total market capital is unchanged. The 
# most common split is a "2:1" or "two for one" split, where 
# each share is replaced with two new ones at half the price. 
# However, other splits are possible, including reverse splits, 
# such as "1:3", where every three shares are replaced with a 
# single new share that's worth three times as much.
#
proc ::ext::StockQuote::get_splits {metadataVar dataVar exchange symbol start_date end_date} {
    upvar ${metadataVar} metadata
    upvar ${dataVar} data

    array set provider {
	NYSE   Yahoo
	NASDAQ Yahoo
    }
    # CSE    Stockwatch
    # ASE    Stockwatch
    # FX     OANDA
    # FX <- GAIN Capital (ratedata.gaincapital.com)

    ::ext::StockQuote::$provider($exchange).get_splits metadata data $exchange $symbol $start_date $end_date

}


proc ::ext::StockQuote::get_dividends {metadataVar dataVar exchange symbol start_date end_date} {

    upvar ${metadataVar} metadata
    upvar ${dataVar} data

    array set provider {
	NYSE   Yahoo
	NASDAQ Yahoo
    }
    # CSE    Stockwatch
    # ASE    Stockwatch
    # FX     OANDA
    # FX <- GAIN Capital (ratedata.gaincapital.com)

    ::ext::StockQuote::$provider($exchange).get_dividends metadata data $exchange $symbol $start_date $end_date

}


# Get historical prices for the given ticker symbol.
# Date format is 'YYYY-MM-DD'
# Returns 0 if all is good, and a nested list in dataVar

# yahoo quotes works with currencies too, e.g. use symbol=EURUSD=x s=EURUSD=x
# TODO: consider currency pairs quotes precision (yahoo data only shows two decimal places)

proc ::ext::StockQuote::Yahoo.get_splits {metadataVar dataVar exchange symbol start_date end_date} {

    upvar $metadataVar metadata
    upvar $dataVar data

    lassign [split $start_date {-}] from_y from_m from_d ;# c a b
    lassign [split $end_date {-}] to_y to_m to_d         ;# f d e
    incr $to_d -1

    set url "http://ichart.yahoo.com/x?s=${symbol}&f=${to_y}&d=${to_m}&e=${to_d}&c=${from_y}&a=${from_m}&b=${from_d}&g=v&y=0&z=30000&ignore=.csv"
    puts "getSplits: $url"

    set errorcode [::http::fetch days $url]
    if { $errorcode == 0 } {


	set data [list]
	set skipLines 1
	set new_days [lrange [split $days "\n"] $skipLines end-4]
	foreach day $new_days {
	    lassign [split $day {,}] split_or_dividend date split_ratio
	    if { $split_or_dividend eq {SPLIT} } {
		lappend data [list [string trim $date] $split_ratio]
	    }
	}

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Split]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]

    }
    return $errorcode
}

proc ::ext::StockQuote::Yahoo.get_dividends {metadataVar dataVar exchange symbol start_date end_date} {

    upvar $metadataVar metadata
    upvar $dataVar data

    lassign [split $start_date {-}] from_y from_m from_d ;# c a b
    lassign [split $end_date {-}] to_y to_m to_d         ;# f d e
    incr $to_d -1

    set url "http://ichart.yahoo.com/x?s=${symbol}&f=${to_y}&d=${to_m}&e=${to_d}&c=${from_y}&a=${from_m}&b=${from_d}&g=v&y=0&z=30000&ignore=.csv"
    puts "getSplits: $url"

    set errorcode [::http::fetch days $url]
    if { $errorcode == 0 } {


	set data [list]
	set skipLines 1
	set new_days [lrange [split $days "\n"] $skipLines end-4]
	foreach day $new_days {
	    lassign [split $day {,}] split_or_dividend date dividend
	    if { $split_or_dividend eq {DIVIDEND} } {
		lappend data [list [string trim $date] $dividend]
	    }
	}

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Dividend]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]

    }
    return $errorcode
}



proc ::ext::StockQuote::Yahoo.get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar $metadataVar metadata
    upvar $dataVar data

    lassign [split $start_date {-}] from_y from_m from_d ;# c a b
    lassign [split $end_date {-}] to_y to_m to_d         ;# f d e

    # Example, from 2010-01-17 to 2011-05-23
    # http://ichart.finance.yahoo.com/table.csv?s=IBM&a=00&b=17&c=2010&d=04&e=23&f=2011&g=d&ignore=.csv
    incr from_m -1 ;# parameter 'a', starts from 00
    incr to_m -1
    set url "http://ichart.yahoo.com/table.csv?s=${symbol}&c=${from_y}&a=${from_m}&b=${from_d}&f=${to_y}&d=${to_m}&e=${to_d}&g=d&ignore=.csv"
    ns_log notice url=$url

    set errorcode [::http::fetch days $url]
    if { $errorcode == 0 } {

	set data [list]
	set skipLines 1
	foreach day [split $days "\n"] {
	    if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $day] eq {} } { continue }
	    lassign [split $day {,}] _date _open _high _low _close _volume _adjclose
	    lappend data [list $_date $_open $_high $_low $_close $_volume]
	}
	set data [lreverse $data]

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Open High Low Close Volume]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]
    }
    return $errorcode
}

set ::MONTHS_ABBREV {Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec}
proc ::ext::StockQuote::Google.get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar $metadataVar metadata
    upvar $dataVar data

    #set start_date [clock format [clock add [clock scan $start_date] -2 day] -format "%Y-%m-%d"]
    #set end_date [clock format [clock add [clock scan $end_date] -2 day] -format "%Y-%m-%d"]

    lassign [split $start_date {-}] from_y from_m from_d
    lassign [split $end_date {-}] to_y to_m to_d

    #incr from_d -2
    #incr to_d -2

    #set from_m_abbrev [lindex $::MONTHS_ABBREV [string trimleft $from_m 0]]
    #set to_m_abbrev [lindex $::MONTHS_ABBREV [string trimleft $to_m 0]]

    # Example: http://finance.google.com/finance/historical?q=NYSE:IBM&startdate=10-14-2010&enddate=11-14-2010&output=csv
    set url_start_date "${from_m}-${from_d}-${from_y}"
    set url_end_date "${to_m}-${to_d}-${to_y}"
    set url "http://www.google.com/finance/historical?q=${exchange}:${symbol}&startdate=${url_start_date}&enddate=${url_end_date}&output=csv"
    ns_log notice "url=$url"

    set errorcode [::http::fetch days $url]
    if { $errorcode == 0 } {

	set data [list]
	set skipLines 1
	foreach day [split $days "\n"] {
	    if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $day] eq {} } { continue }
	    lassign [split $day {,}] _date _open _high _low _close _volume
	    set _date [clock format [clock scan $_date] -format "%Y-%m-%d"]

	    # Note that IBM on Jan 18, 2010 had the following OHLCV data
	    # 131.78 131.78 131.78 131.78 0
	    #
	    # provider=Yahoo does not seem to show quotes for days 
	    # with no volume for the given symbol so we skip 
	    # those days here as well (for consistency)

	    if { $_volume == 0 } {continue}
	    lappend data [list $_date $_open $_high $_low $_close $_volume]
	}
	set data [lreverse $data]

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Open High Low Close Volume]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]
    }
    return $errorcode
}


proc ::ext::StockQuote::Stockwatch.get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar $metadataVar metadata
    upvar $dataVar data 

    set mdate [clock format [clock scan $start_date] -format "%d/%m/%Y"]
    set xdate [clock format [clock scan $end_date] -format "%d/%m/%Y"]
    set url "http://www.stockwatch.com.cy/nqcontent.cfm?a_name=prices2excel&sort=date%20desc&code=${symbol}&mdate=${mdate}&xdate=${xdate}"

    ns_log notice "url=$url"
    set xlsfile /web/data/finance/cse_${symbol}-quotes.xls
    set errorcode [curl::transfer -file $xlsfile -url $url \
		       -infohttpcode httpcode \
		       -infocontenttype contenttype]

    if { $errorcode == 0 && $httpcode == 200} {

	set txtfile /web/data/finance/cse_${symbol}-quotes.txt
	exec -- /bin/sh -c "/opt/naviserver/bin/xls2csv $xlsfile > $txtfile || exit 0" 2> /dev/null
	set fp [open $txtfile]
	set days [string map {"\"" {} {;} { }} [read $fp]]
	close $fp

	# Value is Volume in terms of Money

	set data [list]
	
	set skipLines 4
	foreach day [split $days "\n"] {
	    if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $day] eq {} } { continue }

	    lset day 0 [clock format [clock scan [lindex $day 0] -format "%d/%m/%Y"] -format "%Y-%m-%d"]

	    lappend data [string trim $day]
	}
	set data [lreverse $data]

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Close Mid Buy Sell Currency Value Volume Open High Low]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]

    }

    return $errorcode
}


proc ::ext::StockQuote::Investopedia.get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar $metadataVar metadata
    upvar $dataVar data

    set url "http://www.investopedia.com/markets/stocks/${symbol}/historical/?searchtype=Daily&startdate=${start_date}&enddate=${end_date}&download=1"
    ns_log notice url=$url
 
    set errorcode [::http::fetch html $url]
    if { $errorcode == 0 } {

	::xo::html::extract days html {//tr/td[@class='text-align-right']} "" "returnstring"


	set data [list]
	set skipLines 2
	foreach day [split $days "\n"] {
	    if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $day] eq {} } { continue }
	    lappend data [split $day {,}]
	}
	set data [lreverse $data]

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Open High Low Close Volume]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]
    }
    return $errorcode
}


proc ::ext::StockQuote::QuoteMedia.get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar $metadataVar metadata
    upvar $dataVar data

    lassign [split $start_date {-}] from_y from_m from_d ;# c a b
    lassign [split $end_date {-}] to_y to_m to_d         ;# f d e
    incr to_d -1

    set url "http://app.quotemedia.com/quotetools/getHistoryDownload.csv?&webmasterId=501&startDay=${from_d}&startMonth=${from_m}&startYear=${from_y}&endDay=${to_d}&endMonth=${to_m}&endYear=${to_y}&isRanged=false&symbol=${symbol}"

    ns_log notice url=$url

    set errorcode [::http::fetch days $url]
    if { $errorcode == 0 } {

	set data [list]
	set skipLines 1
	foreach day [split $days "\n"] {
	    if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $day] eq {} } { continue }
	    lappend data [split $day {,}]
	}
	set data [lreverse $data]

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Open High Low Close Volume]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]
    }
    return $errorcode
}


proc ::ext::StockQuote::OANDA.get_historical_prices {metadataVar dataVar exchange symbol start_date end_date} {
    upvar $metadataVar metadata
    upvar $dataVar data

    lassign [split $start_date {-}] start_year start_month start_day
    lassign [split $end_date {-}] end_year end_month end_day

    # ISO 4217 - http://en.wikipedia.org/wiki/ISO_currency_code
    #lassign [split $symbol {/}] base_currency counter_currency
    set base_currency [string range $symbol 0 2]
    set counter_currency [string range $symbol 3 5]

    set margin_fixed 0
    set redirected 1
    set output_format CSV ;# ASCII or CSV or HTML
    set date1 ${start_month}/${start_day}/[string range ${start_year} end-1 end]
    set date ${end_month}/${end_day}/[string range ${end_year} end-1 end]
    set url "http://www.oanda.com/currency/historical-rates?date_fmt=us&date=${date}&date1=${date1}&exch=${base_currency}&expr=${counter_currency}&margin_fixed=${margin_fixed}&format=${output_format}&redirected=${redirected}"

    set errorcode [::http::fetch html $url]

    if { $errorcode == 0 } {

	::xo::html::extract days html {//td[@valign='top']/pre} "" "returnstring"

	#ns_log notice "start_date=$start_date\n\nurl=$url \n\ndays=[split $days \n]"

	set data [list]
	#set skipLines 1
	foreach day [split $days "\n"] {
	    #if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $day] eq {} } { continue }
	    set day [split $day {,}]
	    lset day 0 [clock format [clock scan [lindex $day 0] -format "%m/%d/%Y"] -format "%Y-%m-%d"]
	    lappend data $day
	}
	#set data [lreverse $data]

	set StartDate [lindex [lindex ${data} 0] 0]
	set EndDate [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list Date Rate]
	dict set metadata range [list StartDate ${StartDate} EndDate ${EndDate}]
    }
    return $errorcode
}




########


# here CSE is the data provider
proc ::ext::StockQuote::CSE.get_daily_prices {metadataVar dataVar exchange {date ""}} {
    upvar ${metadataVar} metadata
    upvar ${dataVar} data

    if { $date eq {} } {
	set date [::xo::dt::today]
    }


    set urldate [clock format [clock scan $date] -format "%d%m%Y"]
    set url "http://www.cse.com.cy/en/marketdata/Data/Prices${urldate}_en.txt"

    ns_log notice "url=$url"

    set errorcode [curl::transfer -url $url \
		       -bodyvar text \
		       -infohttpcode httpcode \
		       -infocontenttype contenttype]

    if { $errorcode == 0 && $httpcode == 200} {

	set encoding cp1253
	set lines [split [encoding convertfrom $encoding $text] "\n"]
	set firstline [lindex $lines 0]

	set pattern {[a-zA-Z ]+\(([0-9]+)\)}
	set spec [regexp -inline -all -- $pattern $firstline]
	# add a field size of 20 for the date
	set field_sizes [::xo::fun::map {x y} "Date 20 $spec" { set _ $y }]

	set skipLines 1
	foreach line $lines {
	    if { [incr skipLines -1] >= 0 } { continue }
	    if { [string trim $line] eq {} } { continue }

	    set quote [list]
	    set startIndex 0
	    set endIndex -1
	    foreach field_size $field_sizes {
		incr endIndex $field_size
		lappend quote [string trim [string range $line $startIndex $endIndex]]
		set startIndex [expr {1 + $endIndex}]
	    }

	    lset quote 0 [clock format [clock scan [lindex $quote 0] -format "%Y%m%d"] -format "%Y-%m-%d"]
	    lappend data [string trim $quote]
	}

	set metadata [dict create]
	dict set metadata header [list Date Symbol Stock_Name Open High Low Close Previous_Close Change Percent_Change Volume Value Trades Mid]

    }

    return $errorcode
}

proc ::ext::StockQuote::Xak.get_intraday_prices {metadataVar dataVar exchange symbol date} {
    upvar $metadataVar metadata
    upvar $dataVar data

    lassign [split $date {-}] YYYY MM DD

    set i 1
    set fetch_p 1
    set chunks [list]
    while { $fetch_p } {

	set url "http://www.xak.com/main/QuotesTransactionsWin.asp?s=${symbol}&cp=${i}&d=${MM}/${DD}/${YYYY}"

	set errorcode [::http::fetch html $url]
	
	::xo::html::extract htmltable html {//table[@cellspacing=2 and @cellpadding=0 and @width='90%']}
	::xo::html::table_to_multilist transactions_chunk htmltable

	lappend chunks $transactions_chunk 

	if { ![info exists hrefs] } {
	    ::xo::html::extract hrefs html {//table[@cellspacing=2 and @cellpadding=0 and @width='100%']/tr/td/a/@href} "" "values"
	}

	if { $i >= [llength $hrefs] } {
	    set fetch_p 0
	}
	ns_log notice "intraday data ${i}: [llength $transactions_chunk]"
	incr i
    }

    if { $errorcode == 0 } {

	set data [list]
	foreach chunk $chunks {
	    set skipLines 1
	    foreach transaction $chunk {
		if { [incr skipLines -1] >= 0 } { continue }
		if { [string trim $transaction] eq {} } { continue }
		lappend data $transaction
	    }	
	}
	set data [lreverse $data]

	set StartDateTime [lindex [lindex ${data} 0] 0]
	set EndDateTime [lindex [lindex ${data} end] 0]

	set metadata [dict create]
	dict set metadata header [list DateTime Symbol Price Quantity]
	dict set metadata range [list StartDateTime ${StartDateTime} EndDateTime ${EndDateTime}]
    }
    return $errorcode
}
