
proc get_ta_table {resultTableVar spec} {
    upvar $resultTableVar inReal

    if { [dict exists $spec tcl] } {
    	set inReal(tcl_precision) [dict get $spec tcl precision]
    }

    set exchange [dict get $spec data exchange]
    set symbol [dict get $spec data symbol]
    set start_date [dict get $spec data start_date]
    set end_date [dict get $spec data end_date]
    if { [dict exists $spec data range] } {
	lassign [dict get $spec data range] first last
    } else {
	set first "0"
	set last "end"
    }


    # get price data
    set error [::ext::StockQuote::get_historical_prices_if metadata table $exchange $symbol $start_date $end_date datasource]
    #set table [lreverse [lrange $table 0 end-1]] ;# remove header and the last line which is empty


    #set first 1
    #set inTable [lrange $table $first $last] ;# FIX: last line issue in module-ystockquote
    set inTable $table
    set size [llength $inTable]

    # we need to transpose inTable, in the future make sure that get_prices returns it as expected here
    transpose_matrix inTable TransposedTable


    #doc_return 200 text/plain $TransposedTable
    #return


    #set inHeader [list inDate inOpen inHigh inLow inClose inVolume inAdjClose]
    set header [dict get $metadata header]
    set inHeader [::xo::fun::map x $header { set _ in${x} }]
    foreach columnName $inHeader columnData $TransposedTable {
	set inReal(${columnName},data) $columnData
	set inReal(${columnName},offset) 0
	set inReal(${columnName},numElems) $size
	# not sure if endIdx is needed here
	set inReal(${columnName},endIdx) [expr { $size - 1 }]

    }
    set inReal(HEADER) $inHeader

    #doc_return 200 text/plain [array get inReal]
    #return

    ### foreach stage in $stages
    set formulas [dict get $spec formula]
    foreach {ta_func configDict outColumnNames} $formulas {

	if { [dict exists $configDict disabled] } {
	    if { [dict get $configDict disabled] } {
		continue
	    }
	}

	# default input specification
	set input {{inRealVar inClose} {inOpenVar inOpen} {inHighVar inHigh} {inLowVar inLow} {inCloseVar inClose} {inVolumeVar inVolume}}
	if { [dict exists $configDict input] } {
	    set input [dict get $configDict input]
	}

	set maxOffset 0
	set inputVarList [list]
	foreach element $input {
	    set len [llength $element]
	    if { 1 == $len } {
		set varName ${element}Var
		set columnName $element
	    } elseif { 2 == $len } {
		lassign $element varName columnName
	    }
	    lappend inputVarList ${varName}
	    lappend inputVarList inReal(${columnName},data)
	    if { $maxOffset < $inReal(${columnName},offset) } {
		set maxOffset $inReal(${columnName},offset)
	    }
	    #lappend startIdxList $inReal(${columnName},startIdx)
	    #lappend endIdxList $inReal(${columnName},endIdx)
	}

	# [list inRealVar "inReal($columnName,data)"]

	set outBegIdx 0
	set outNBElement 0
	set procName "TA_$ta_func"
	#set argsDict  [concat  [list inRealVar "inReal($columnName,data)"] {outBegIdxVar outBegIdx} {outNBElementVar outNBElement} ${configDict} [list configDict ${configDict}]]
	set argsDict  [concat $inputVarList {outBegIdxVar outBegIdx} {outNBElementVar outNBElement} $configDict]


	#ns_log notice "inputVarList=$inputVarList \n argsDict=$argsDict"

	set otherVarList [::xo::fun::map x $outColumnNames { set _ inReal(${x},data) }]
	set missingRefVars [args_from_dict callArgs $procName $argsDict $otherVarList]

	if { $missingRefVars ne {} } {
	    ns_log notice "get_ta_table: missingRefVars=$missingRefVars procName=$procName"
	}


	# link missing reference variables to our output columns/variables
	#foreach varName $missingRefVars outColumnName $outColumnNames {
	#    upvar 0 $varName inReal($outColumnName)
	#}

	### this is to know where we are in the processing of the spec: ns_log notice "outColumnNames=$outColumnNames"

	#ns_log notice "$procName $callArgs"

	${procName} {*}${callArgs}

	##ns_log notice "outNBElement=$outNBElement outBegIdx=$outBegIdx"

	foreach outColumnName $outColumnNames {
	    lappend inReal(HEADER) $outColumnName
	    set inReal(${outColumnName},offset) [expr { $maxOffset + $outBegIdx }]
	    set inReal(${outColumnName},numElems) $outNBElement
	    # make sure the endIdx is correct, also not sure if it is actually needed
	    set inReal(${outColumnName},endIdx) [expr { $outNBElement - $outBegIdx - 1 }]
	}


	#TA_$ta_func inHeader inTable ${ta_func_config} outTable
	#foreach outColumnName $outColumnNames {
	#    # if outColumn value does not exist, raise an error
	#    set inTable($outColumnName) [set $outColumnName]
	#}

    }

    #set resultTable [linterleave $inHeader $inTable]
    #transpose_matrix inTable resultTable

    return

}


proc print_ta_table {inRealVar {format "plain"}} {
    upvar $inRealVar inReal

    set result ""
    set original_precision $::tcl_precision
    if { [info exists inReal(tcl_precision)] } {
	set ::tcl_precision $inReal(tcl_precision)
	append result "precision=$inReal(tcl_precision)\n"
    }



    if { $format eq {html} } {
	append result "<table border=1>"
    } else {
	append result ""
    }

    set header [lsort [array names inReal *,data]]
    set header $inReal(HEADER)
    foreach name $header {
	lassign [split $name {,}] columnName __dummy__

	if { ![info exists inReal(${columnName},data)] } {
	    # report missing data and continue
	    ns_log notice "inReal(${columnName},data) is missing, most likely something wrong during the computation"
	    continue
	}

	append result "\n\n"
	set extra ""
	set offset $inReal(${columnName},offset)
	if { $offset > 0 } {
	    set extra [lrepeat $offset {}]
	}
	if { $format eq {html} } {
	    append result "<tr><td>$columnName</td><td>[join [concat $extra $inReal(${columnName},data)] {</td><td>}]</td></tr>"
	} else {
	    append result "$columnName [concat $extra $inReal(${columnName},data)]"
	}
    }

    if { $format eq {html} } {
	append result "</table>"
    }
    set ::tcl_precision $original_precision
    return $result
}



#################################





proc push_frame {timeFrameVar inHeaderVar lookback} {
    upvar $timeFrameVar frame
    upvar $inHeaderVar inHeader

    foreach varname $inHeader {
	upvar $varname current_value

	set prev_lookback $lookback
	set this_lookback $lookback
	while { [incr this_lookback] < 0 } {
	    if { [info exists frame($varname,$this_lookback)] } {
		set frame($varname,$prev_lookback) $frame($varname,$this_lookback)
	    }
	    incr prev_lookback
	}
	set frame($varname,-1) $current_value
    }

}

### DEPRECATE ALL OF THESE except the utils towards the end of this file
#proc TA_CUSTOM {inTableVar configDict outTableVar} 
proc TA_CUSTOM {args} {
    return
    upvar $inTableVar inTable
    upvar $outTableVar outTable

    set inputHeader [dict get $configDict input] ;# usually, multiple columns for TA_CUSTOM
    set list_of_columns [list]
    foreach columnName $inputHeader {
	lappend list_of_columns $inTable(${columnName},data)
    }

    set expr_func [dict get $configDict expr_func]
    set expr_args [dict get $configDict expr_args]
    if { [dict exists $configDict lookback] } {
	set lookback [dict get $configDict lookback]
    } else {
	set lookback 0
    }

    set maxStartIdx 0
    set minNumElems inf
    foreach varname $inputHeader {
	if { $inTable($varname,startIdx) > $maxStartIdx } {
	    set maxStartIdx $inTable($varname,startIdx)
	}
	if { $inTable($varname,numElems) < $minNumElems } {
	    set minNumElems $inTable($varname,numElems)
	}
    }
    ns_log notice "maxStartIdx=$maxStartIdx minNumElems=$minNumElems"
    set currentIndex -1
    set values ""
    foreach {*}[linterleave $inputHeader $list_of_columns] {

	incr currentIndex
	if {  $currentIndex < $maxStartIdx || $currentIndex > $minNumElems } {
	    #ns_log notice "skipping $currentIndex"
	    continue
	}

	set compute_p 1
	# make sure all dependencies are met
	foreach varname $inputHeader {
	    if { [set $varname] eq {} } {
		set compute_p 0
		break
	    }
	}
	if { $compute_p } {
	    # Consider passing $inHeader
	    lappend values [expr_$expr_func __LB_FRAME inputHeader $lookback {*}${expr_args}]
	} else {
	    lappend values ""
	}
	if { 0 != $lookback } {
	    push_frame __LB_FRAME inputHeader $lookback
	}

    }
    set outTable [list $values]
    return
    ###return [list $outBegIdx $outNBElement]
}

### iterator expressions

proc expr_expr {timeFrameVar inputHeaderVar lookback args} {
    upvar $timeFrameVar frame
    upvar $inputHeaderVar inputHeader

    foreach varname $inputHeader {
	upvar $varname $varname
	if { $lookback < 0 } {
	    if { ![info exists frame($varname,$lookback)] } {
		return
	    }
	    if { $frame($varname,$lookback) eq {} } {
		return
	    }
	}
    }

    set what [subst -nocommands -nobackslashes $args]
    #ns_log notice what=$what
    return [expr {*}$what]
}


proc crossover_expr {timeFrameVar v1_expr v2_expr {lookback "-1"}} {
    upvar $timeFrameVar frame

    set v1 [uplevel expr $v1_expr]
    set v2 [uplevel expr $v2_expr]

    if { $v1 > $v2 } {
	set current_value 1
    } elseif { $v1 < $v2 } {
	set current_value -1
    } else {
	set current_value 0
    }

    set result ""
    if { [info exists frame($lookback)] } {
	set past_value $frame($lookback)
	set result [expr { (-1 == $past_value) && (1 == $current_value) }]
    }

    set prev_lookback $lookback
    while { [incr lookback] < 0 } {
	if { [info exists frame($lookback)] } {
	    set frame($prev_lookback) $frame($lookback)
	}
	incr prev_lookback
    }
    set frame(-1) $current_value

    return $result

}

proc binary_expr {timeFrameVar condition {lookback "-1"}} {
    upvar $timeFrameVar frame

    set result ""
    set current_value [uplevel expr $condition]

    if { [info exists frame($lookback)] } {
	set past_value $frame($lookback)
	set result [expr { $current_value && !$past_value }]
    }

    set prev_lookback $lookback
    while { [incr lookback] < 0 } {
	if { [info exists frame($lookback)] } {
	    set frame($prev_lookback) $frame($lookback)
	}
	incr prev_lookback
    }
    set frame(-1) $current_value

    return $result
}



######## tcl utils

proc transpose_matrix {inMatrixVar outMatrixVar} {
    upvar $inMatrixVar inMatrix
    upvar $outMatrixVar outMatrix
    set cols [iota [llength [lindex $inMatrix 0]]]
    foreach row $inMatrix {
        foreach element $row col $cols {
            lappend ${col} $element
        }
    }
    set outMatrix [list]
    foreach col $cols {
	lappend outMatrix [set $col]
    }
    return
}





proc count_agg {countArrayVar lookbackVar period signal_expr value_expr} {
    upvar $countArrayVar countArray
    upvar $lookbackVar lb

    if { ![array exists countArray] } {
	ns_log notice "countArrayVar=$countArrayVar lookbackVar=$lookbackVar"
	array set countArray [list UP 0 DOWN 0 EQUAL 0 MAX_UP_CHANGE 0 MIN_UP_CHANGE inf MAX_DOWN_CHANGE 0 MIN_DOWN_CHANGE inf TOTAL 0 CI_LOWER_BOUND 0.0]
    }

    set signal [uplevel subst $signal_expr]
    set value [uplevel subst $value_expr]
    set lb_value ""
    if { [info exists lb(signal,$period)] && [info exists lb(value,$period)] } {
	if { $lb(signal,$period) } {
	    # if we had a signal $period time ago, i.e. if we lookback $period and the signal=1 then count it in
	    set lb_value $lb(value,$period)
	    if { $lb_value ne {} && $value ne {} } {
		### set change [expr { abs(double($value) - double($lb_value))/double($lb_value) }]
		set change [expr { abs(double($value) - double($lb_value)) }]
		if { $lb_value < $value } {
		    incr countArray(UP)
		    set countArray(MAX_UP_CHANGE) [expr { max($countArray(MAX_UP_CHANGE), $change) }]
		    set countArray(MIN_UP_CHANGE) [expr { min($countArray(MIN_UP_CHANGE), $change) }]
		} elseif { $lb_value > $value } {
		    incr countArray(DOWN)
		    set countArray(MAX_DOWN_CHANGE) [expr { max($countArray(MAX_DOWN_CHANGE), $change) }]
		    set countArray(MIN_DOWN_CHANGE) [expr { min($countArray(MIN_DOWN_CHANGE), $change) }]
		} else {
		    incr countArray(EQUAL)
		}
		incr countArray(TOTAL)
		set countArray(CI_LOWER_BOUND) [ci_lower_bound $countArray(UP) $countArray(TOTAL) 0.10] ;# 99.95% chance that lower bound is correct
	    }
	}
    }

    set prev_period $period
    while { [incr period] < 0 } {
	if { [info exists lb(signal,$period)] && [info exists lb(value,$period)] } {
	    set lb(signal,$prev_period) $lb(signal,$period)
	    set lb(value,$prev_period) $lb(value,$period)
	}
	# set prev_period $period
	incr prev_period
    }
    set lb(signal,-1) $signal
    set lb(value,-1) $value

    return [array get countArray]

}








############



set OLD_indicator {
	overbought70:rsi2   {rsi2} expr { $rsi2 > 70.0 }
	overbought70:rsi14   {rsi14} expr { $rsi14 > 70.0 }
	oversold30:rsi14     {rsi14} expr { $rsi14 < 30.0 }

	upward_crossover_1d:sma15_sma50 {sma15 sma50} crossover_expr {lookback1 -1 $sma15 $sma50}
	upward_crossover_1d:sma50_sma200 {sma50 sma200} crossover_expr {lookback2 -1 $sma50 $sma200}
	downward_crossover_1d:sma15_sma50 {sma15 sma50} crossover_expr {lookback3 -1 $sma50 $sma15}
	upward_crossover_1d:price_sma15 {last_close sma15} crossover_expr {lookback4 -1 $last_close $sma15}

	percent_b:bb_20_2_2  {last_close upperBB middleBB lowerBB} expr { ($last_close - $lowerBB) / ($upperBB - $lowerBB) }
	bandwidth:bb_20_2_2  {upperBB middleBB lowerBB} expr { ($upperBB - $lowerBB) / $middleBB }
	ema5_ema10_ABOVE_ema20 {ema5 ema10 ema20} expr { ($ema5 > $ema20) && ($ema10 > $ema20) }
	ema5_ema10_BELOW_ema20 {ema5 ema10 ema20} expr { ($ema5 < $ema20) && ($ema10 < $ema20) }

    }


# Investopedia:
#   Moving averages are used to emphasize the direction of a trend and to smooth out price and
#   volume fluctuations, or "noise", that can confuse interpretation.Typically, upward momentum
#   is confirmed when a short-term average (e.g. 15-day) crosses above a longer-term average
#   (e.g. 50-day). Downward momentum is confirmed when a short-term average crosses below a 
#   long-term average.
