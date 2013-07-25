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


set optInTimePeriod 14
ta_RSI inReal $optInTimePeriod outBegIdx outNBElement outReal
set lastIdx [expr { $outNBElement - 1 }]

#append result "RSI($optInTimePeriod) \n\noutBegIdx=$outBegIdx \n outNBElement=$outNBElement \n outReal=$outReal \n RSI($optInTimePeriod) = lrange outReal 0 $lastIdx = [lrange $outReal 0 $lastIdx]"


set outRealWithRSI [linterleave_with_offset $inReal [lrange $outReal 0 $lastIdx] $outBegIdx]


set result [::xo::fun::map {x y} $outRealWithRSI { 
    set _ "$x $y"
    if { $y ne {} } { 
	if { $y > 70 } { 
	    set _ "$x ****************** RSI($optInTimePeriod,1d)_OVERBOUGHT_70($y)" 
	} elseif { $y < 30 } { 
	    set _ "$x ****************** RSI($optInTimePeriod,1d)_OVERSOLD_30($y)" 
	}
    }
    set _
}]

doc_return 200 text/plain "DONE - MAKE SURE THAT THE VALUES WE GET ARE CORRECT \n\n[join $result \n]"