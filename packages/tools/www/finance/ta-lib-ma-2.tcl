set libdir [acs_root_dir]/packages/tools/lib/
source [file join $libdir critcl/tcl/module-critcl-ext.tcl]
source [file join $libdir ta-lib-ext/tcl/module-ta-lib.tcl]

source [file dirname [ad_conn file]]/module-ystockquote.tcl


proc linterleave_with_offset {x y offset} {
    set new_y [concat [lrepeat $offset ""] $y]
    return [linterleave $x $new_y]
}




set error [get_historical_prices_if table IBM 2007-03-17 2010-03-31 datasource]
set data [lrange $table 1 end-1] ;# FIX: last line issue in module-ystockquote
set inReal [lreverse [::xo::fun::map x $data { lindex $x 4 }]]


# Investopedia:
#   Moving averages are used to emphasize the direction of a trend and to smooth out price and
#   volume fluctuations, or "noise", that can confuse interpretation.Typically, upward momentum
#   is confirmed when a short-term average (e.g. 15-day) crosses above a longer-term average
#   (e.g. 50-day). Downward momentum is confirmed when a short-term average crosses below a 
#   long-term average.


set output ""
set MATypes [list 0 "SMA" 1 "EMA" 2 "WMA" 3 "DEMA" 4 "TEMA" 5 "TRIMA" 6 "KAMA" 7 "MAMA" 8 "T3"]
set optInTimePeriod1 15 ;# 10
set optInTimePeriod2 50 ;# 25

set maxchange_RIGHT 0.0
set maxchange_WRONG 0.0
set minchange_RIGHT 9999999999.0
set minchange_WRONG 9999999999.0
foreach {optInMAType ma_type} $MATypes  {

    ta_MA inReal $optInTimePeriod1 $optInMAType outBegIdx1 outNBElement1 outReal1
    ta_MA inReal $optInTimePeriod2 $optInMAType outBegIdx2 outNBElement2 outReal2
    set lastIdx1 [expr { $outNBElement1 - 1 }]
    set lastIdx2 [expr { $outNBElement2 - 1 }]
    set outReal1 [lrange $outReal1 0 $lastIdx1]
    set outReal2 [lrange $outReal2 0 $lastIdx2]

    set outRealWithMA1 [linterleave_with_offset $inReal $outReal1 $outBegIdx1]
    set outRealWithMA2 [linterleave_with_offset $inReal $outReal2 $outBegIdx2]

    # check crossovers
    set lookback_ma1 ""
    set lookback_ma2 ""
    set crossovers ""
    set nbRIGHT 0
    set nbWRONG 0
    set change_RIGHT 0.0
    set change_WRONG 0.0
    set result [::xo::fun::map {p1 ma1} $outRealWithMA1 {p2 ma2} $outRealWithMA2 { 
	# p1 and p2 must be equal, i.e. it's the stock price
	set p $p1

	set _ "$p $ma1 $ma2"
	if { $ma1 ne {} && $ma2 ne {} && $lookback_ma1 ne {} && $lookback_ma2 ne {} } { 
	    if { $lookback_ma1 < $lookback_ma2 && $ma1 > $ma2 } { 
		set change [expr { (double($ma1) - double($ma2)) + (double($lookback_ma2) - double($lookback_ma1)) }]
		set _ "$p $ma1 $ma2 ****************** UPWARD_CROSSOVER_MA($ma_type,$optInTimePeriod1,$optInTimePeriod2,Change($change),Data_Range(1d),Cross_Lookback(1))" 
		lappend crossovers [list $p UPWARD]
	    } elseif { $lookback_ma1 > $lookback_ma2 && $ma1 < $ma2 } { 
		set change [expr { (double($ma2) - double($ma1)) + (double($lookback_ma1) - double($lookback_ma2)) }]
		set _ "$p $ma1 $ma2 ****************** DOWNWARD_CROSSOVER_MA($ma_type,$optInTimePeriod1,$optInTimePeriod2,Change($change),Data_Range(1d),Cross_Lookback(1))" 
		lappend crossovers [list $p DOWNWARD]
	    } else {
		if { $crossovers ne {} } {
		    ### Trivial way of checking predictability.
		    ### Even so, we would get better results if we had checked Low and High instead of close of next day/days.
		    lassign [lindex $crossovers end] crossover_price crossover_direction
		    set price_change [expr { $p - $crossover_price }]
		    if { ($price_change > 0 && $crossover_direction eq {UPWARD}) || ($price_change < 0 && $crossover_direction eq {DOWNWARD}) } {
			set message RIGHT
			incr numRIGHT
			set change_RIGHT [expr { max($change_RIGHT, abs(double($price_change))) }]
		    } else {
			set message WRONG
			incr numWRONG
			set change_WRONG [expr { max($change_WRONG, abs(double($price_change))) }]
		    }
		    set _ "$p $ma1 $ma2 (predictability of last crossover was $message price_change=$price_change)"
		}
	    }
	}
	set lookback_ma1 $ma1
	set lookback_ma2 $ma2
	# HERE we can keep a window/frame of values, e.g. last N days
	set _
    }]

    if { ${crossovers} ne {} } {
	set maxchange_RIGHT [expr { max(double($maxchange_RIGHT), double($change_RIGHT)) }]
	set maxchange_WRONG [expr { max(double($maxchange_WRONG), double($change_WRONG)) }]
	set minchange_RIGHT [expr { min(double($minchange_RIGHT), double($change_RIGHT)) }]
	set minchange_WRONG [expr { min(double($minchange_WRONG), double($change_WRONG)) }]
    }

    append output "\n\n$ma_type\n\nHow many RIGHT? = $numRIGHT (change=$change_RIGHT)\nHow many WRONG? = $numWRONG (change=$change_WRONG)\n\n\n[join $result \n]\n\n"

}



doc_return 200 text/plain "DONE - MAKE SURE THAT THE VALUES WE GET ARE CORRECT \n\n minchange_RIGHT($minchange_RIGHT) \n maxchange_RIGHT($maxchange_RIGHT) \n minchange_WRONG($minchange_WRONG) \n maxchange_WRONG($maxchange_WRONG)  \n\n$output"