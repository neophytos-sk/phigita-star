#set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir critcl-ext/tcl/module-critcl-ext.tcl]
#source [file join $libdir ta-lib-ext/tcl/module-ta-lib.tcl]
#source [file join $libdir ta-lib-ext/tcl/module-ta-utils.tcl]

::xo::lib::require critcl-ext
::xo::lib::require ta-lib
::xo::lib::require stockquote

#source [file dirname [ad_conn file]]/module-critcl-utils.tcl

if {0} {
    source [file dirname [ad_conn file]]/module-gsl-lib.tcl
    source [file dirname [ad_conn file]]/module-statistics.tcl
}


# TODO: Fixed-Point Arithmetic, Fixed-Point Types in GCC (_Fract, _Accum in g++)
# default tcl_precision is 0 which seems to be the same as 17 (which is the maximum)
# streak = an unbroken series of events

# With intraday data we could have additional setups as follows:
# * close vs. start of first hour
# * close vs. start of last hour
# * end of first hour vs. open
# * end of first hour vs. previous high
# * end of first hour vs. previous low
# * end of first hour vs. previous close
# * start of last hour vs. open
# * start of last hour vs. end of first hour
# * start of last hour vs. previous high
# * start of last hour vs. previous low
# * start of last hour vs. previous close
# * intraday range = high vs. low
# * close vs. midpoint intraday range

#	exchange NYSE symbol IBM start_date 1962-02-02 end_date ""
set spec {
    tcl {
	precision 10
    }
    data {
	exchange NYSE symbol IBM start_date 2007-01-15 end_date 2010-04-23
	range "end-100 end"
	frequency "daily (5 days)"
	comment "note that the data at the moment includes the header and an empty line at the end - TODO - FIX"
    }

    formula {

	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inClose}" optInTimePeriod "1" }         {close_vs_previous_close }
	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inOpen }" optInTimePeriod "1" }         {close_vs_previous_open  }
	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inHigh }" optInTimePeriod "1" }         {close_vs_previous_high  }
	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inLow  }" optInTimePeriod "1" }         {close_vs_previous_low   }

	CUSTOM_SUB {input "{inReal0Var inOpen } {inReal1Var inClose}" optInTimePeriod "1" }         {open_vs_previous_close  }
	CUSTOM_SUB {input "{inReal0Var inOpen } {inReal1Var inOpen }" optInTimePeriod "1" }         {open_vs_previous_open   }
	CUSTOM_SUB {input "{inReal0Var inOpen } {inReal1Var inHigh }" optInTimePeriod "1" }         {open_vs_previous_high   }
	CUSTOM_SUB {input "{inReal0Var inOpen } {inReal1Var inLow  }" optInTimePeriod "1" }         {open_vs_previous_low    }

	CUSTOM_SUB {input "{inReal0Var inHigh } {inReal1Var inClose}" optInTimePeriod "1" }         {high_vs_previous_close  }
	CUSTOM_SUB {input "{inReal0Var inHigh } {inReal1Var inOpen }" optInTimePeriod "1" }         {high_vs_previous_open   }
	CUSTOM_SUB {input "{inReal0Var inHigh } {inReal1Var inHigh }" optInTimePeriod "1" }         {high_vs_previous_high   }
	CUSTOM_SUB {input "{inReal0Var inHigh } {inReal1Var inLow  }" optInTimePeriod "1" }         {high_vs_previous_low    }

	CUSTOM_SUB {input "{inReal0Var inLow  } {inReal1Var inClose}" optInTimePeriod "1" }         {low_vs_previous_close   }
	CUSTOM_SUB {input "{inReal0Var inLow  } {inReal1Var inOpen }" optInTimePeriod "1" }         {low_vs_previous_open    }
	CUSTOM_SUB {input "{inReal0Var inLow  } {inReal1Var inHigh }" optInTimePeriod "1" }         {low_vs_previous_high    }
	CUSTOM_SUB {input "{inReal0Var inLow  } {inReal1Var inLow  }" optInTimePeriod "1" }         {low_vs_previous_low     }

	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inOpen }" optInTimePeriod "0" }         {intraday_close_vs_open  }
	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inHigh }" optInTimePeriod "0" }         {intraday_close_vs_high  }
	CUSTOM_SUB {input "{inReal0Var inClose} {inReal1Var inLow  }" optInTimePeriod "0" }         {intraday_close_vs_low   }

	CUSTOM_STREAK {input "{inRealVar close_vs_previous_close}"}                           {count_streak_CC_1d sum_streak_CC_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_open }"}                           {count_streak_CO_1d sum_streak_CO_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_high }"}                           {count_streak_CH_1d sum_streak_CH_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_low  }"}                           {count_streak_CL_1d sum_streak_CL_1d}

	CUSTOM_STREAK {input "{inRealVar open_vs_previous_close}"}                            {count_streak_OC_1d sum_streak_OC_1d}
	CUSTOM_STREAK {input "{inRealVar open_vs_previous_open }"}                            {count_streak_OO_1d sum_streak_OO_1d}
	CUSTOM_STREAK {input "{inRealVar open_vs_previous_high }"}                            {count_streak_OH_1d sum_streak_OH_1d}
	CUSTOM_STREAK {input "{inRealVar open_vs_previous_low  }"}                            {count_streak_OL_1d sum_streak_OL_1d}

	CUSTOM_STREAK {input "{inRealVar close_vs_previous_close}"}                           {count_streak_HC_1d sum_streak_HC_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_open }"}                           {count_streak_HO_1d sum_streak_HO_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_high }"}                           {count_streak_HH_1d sum_streak_HH_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_low  }"}                           {count_streak_HL_1d sum_streak_HL_1d}

	CUSTOM_STREAK {input "{inRealVar close_vs_previous_close}"}                           {count_streak_LC_1d sum_streak_LC_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_open }"}                           {count_streak_LO_1d sum_streak_LO_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_high }"}                           {count_streak_LH_1d sum_streak_LH_1d}
	CUSTOM_STREAK {input "{inRealVar close_vs_previous_low  }"}                           {count_streak_LL_1d sum_streak_LL_1d}

	ROCP          {input "{inRealVar inClose}" optInTimePeriod "1"}                       {daily_return_rocp1}
    	CUSTOM_GMA    {input "{inRealVar daily_return_rocp1}" optInTimePeriod "90" optInAdjustPercent "1"} {gma90}
	STDDEV        {input "{inRealVar daily_return_rocp1}" optInTimePeriod "90"}           {stddev90}

	CUSTOM_DD     {input "{inRealVar inClose}" optInTimePeriod "90"}                      {drawdown_CC_90d}
	CUSTOM_DD_LH  {input "{inLowVar inLow} {inHighVar inHigh}" optInTimePeriod "5"}       {drawdown_LH_5d}
	MAX           {input "{inRealVar drawdown_LH_5d}" optInTimePeriod "5"}                {MDD_LH_5d}

	DIV           {input "{inReal0Var gma90} {inReal1Var stddev90}"}                      {Rolling_Quarterly_Return_vs_Volatility}
    }

    model {
	mymodel1 {
	    comment "train/test/validate all combinations of parameters/input"
	    problem {
		bias "0"
		label {
		    input "sum_streak_CC_1d"
		    scale ""
		    prediction_interval "2 3 5 7"
		}
		features {
		    RSI {
			input "{inRealVar inClose}" 
			optInTimePeriod "2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97"
		    }
		    GMA {...}
		}
	    }
	    parameter {
		solver_type "L2R_LR L2R_L2LOSS_SVC_DUAL L2R_L2LOSS_SVC L2R_L1LOSS_SVC_DUAL MCSVM_CS L1R_L2LOSS_SVC L1R_LR"
		eps ""
		C ""
		weights "weight_label1 list_of_weights"
	    }
	}
    }
}

get_ta_table table $spec


doc_return 200 text/plain "[print_ta_table table plain]"
#doc_return 200 text/html [print_ta_table table html]
return
#doc_return 200 text/plain [join [array get table] \n]



#	FOREACH col0 {"close" "open" "high" "low"} {
#	    FOREACH col1 {"close" "open" "high" "low"} {
#               SET varName ${col0}_vs_previous_${col1}_1d
#               EMIT CUSTOM_SUB    [LIST INPUT [LIST inReal0Var $col0 inReal1Var $col1]] $varName
#               EMIT CUSTOM_STREAK [LIST INPUT [LIST inRealVar $varName]] [list count_streak_$varName sum_streak_$varName]
#	    }
#	}
#
# Or, for instance:
#
#      FOR ANY COMBINATION OF: col0 {close open high low} col1 {close open high low} period {1}
#      CALCULATE: CUSTOM_SUB {input "{inReal0Var %s} {inReal1Var %s}" optInTimePeriod "%s" } {%s}
#

##############################################
### OLD BUT KEEP (INTERESTING-IMPORTANT STUFF)
##############################################

# define dependencies between derived functions and then do a topological sort to figure out the stages
# we want to be able to ask queries of the form, which is indicator is best (ranking) if I want to
# BUY a stock X and SELL after 3 days. What if I buy the stock on a Monday, the last day of the month,
# the first day of the month, the day before/after a holiday, and so on (seasonality). it should not be
# to hard to compute these for a given indicator. The BIG question is where exactly association rules and
# learning/adaptive algorithms come into play.
#
# Association Rules Scenarios:
# * associate different indicators/signals
# * associate different stock movements

# IBM, GOOG, MSFT, AAPL, YHOO, AMZN

#
# 2010-03-06 (i.e end-270 from 2010-03-31) is a significant day in the markets (bottom after crisis had started)
#
set spec {
    data {
	symbol IBM
	start_date 1962-02-02
	end_date 2010-03-31
	range "end-270 end"
	frequency "daily (5 days)"
	comment "note that the data at the moment includes the header and an empty line at the end - TODO - FIX"
    }

    stages {formula indicator aggregate}

    formula {

	CUSTOM_SUB {
	    input "{inReal0Var inClose} {inReal1Var inClose}"
	    optInTimePeriod "1"
	} {close_vs_previous_close}

	MOM       {optInTimePeriod "10"}                                                            {mom10}
	ROCP      {optInTimePeriod "1"}                                                             {rocp1}

	RSI       {optInTimePeriod "2"}                                                             {rsi2}
	RSI       {optInTimePeriod "14"}                                                            {rsi14}
	MA        {optInMAType "EMA" optInTimePeriod "5"}                                           {ema5}
	MA        {optInMAType "EMA" optInTimePeriod "10"}                                          {ema10}
	MA        {optInMAType "EMA" optInTimePeriod "20"}                                          {ema20}
	MA        {optInMAType "SMA" optInTimePeriod "10"}                                          {sma10}
	MA        {optInMAType "SMA" optInTimePeriod "15"}                                          {sma15}
	MA        {optInMAType "SMA" optInTimePeriod "50"}                                          {sma50}
	MA        {optInMAType "SMA" optInTimePeriod "200"}                                         {sma200}
	BBANDS    {optInMAType "SMA" optInTimePeriod "20" optInNbDevUp "2.0" optInNbDevDown "2.0"}  {upperBB middleBB lowerBB}
	STDDEV    {optInTimePeriod "50" optInNbDev "3.0"}                                           {stddev50_3}
	MACD      {optInFastPeriod "12" optInSlowPeriod "26" optInSignalPeriod "9"}                 {macd_12_26_9 macd_12_26_9_signal macd_12_26_9_hist}
	MIN       {optInTimePeriod "14"}                                                            {min14}
	MAX       {optInTimePeriod "14"}                                                            {max14}
	MININDEX  {optInTimePeriod "14"}                                                            {minindex14}
	MAXINDEX  {optInTimePeriod "14"}                                                            {maxindex14}
	TSF       {optInTimePeriod "30"}                                                            {tsf30}
	LINEARREG {optInTimePeriod "14"}                                                            {linearreg14}
	LINEARREG_SLOPE {optInTimePeriod "14" comment "make sure slope eqn is correct"}             {linearreg_slope14}

	CORREL {
	    input "{inReal0Var inClose} {inReal1Var tsf30}"
	    optInTimePeriod "30"
	} {correl_inClose_tsf30}
	
	MINMAX    {
	    input "{inRealVar inClose}"
	    optInTimePeriod "30"
	} {minmax30_min minmax30_max}

	
	VAR    {
	    input "{inRealVar inClose}"
	    optInTimePeriod "5"
	    optInNbDev "1.0"
	} {var5_1}

	MFI {
	    input "{inHighVar inHigh} {inLowVar inLow} {inCloseVar inClose} {inVolumeVar inVolume}"
	    optInTimePeriod "14" 
	} {mfi14}

	SAR {
	    input "{inHighVar inHigh} {inLowVar inLow}"
	    optInAcceleration "0.02" 
	    optInMaximum "0.2" 
	} {sar_0.02_0.2}

	OBV {
	    input "{inRealVar inClose} {inVolumeVar inVolume}"
	} {obv}


	CDLEVENINGDOJISTAR {
	    input "{inOpenVar inOpen} {inHighVar inHigh} {inLowVar inLow} {inCloseVar inClose}"
	    optInPenetration 0.3
	} {cdleveningdojistar}

	CDLHAMMER {
	    input "{inOpenVar inOpen} {inHighVar inHigh} {inLowVar inLow} {inCloseVar inClose}"
	} {cdlhammer}





	MA     {input "{inRealVar rocp1}" optInMAType "EMA" optInTimePeriod "1500"}                             {ema1500_of_rocp1}
	LOG10  {input "{inRealVar inClose}"}                                                                    {log10}
	LINEARREG {input "{inRealVar log10}" optInTimePeriod "14"}                                              {linearreg14_of_log10}

    }
    logic {

	UP(S,T1,T2) {
	    price(S,P1) @ T1
	    price(S,P2) @ T2
	    P1 < P2
	    T1 < T2
	}

	DOWN(S,T1,T2) {
	    price(S,P1) @ T1
	    price(S,P2) @ T2
	    P1 > P2
	}

	

    }
    TODO_STUFF {
	CUSTOM {input "rsi2" expr_func "expr" expr_args "$rsi2 > 70.0"}          {overbought70:rsi2}
	CUSTOM {input "rsi14" expr_func "expr" expr_args "$rsi14 > 70.0"}        {overbought70:rsi14}
	CUSTOM {input "rsi14" expr_func "expr" expr_args "$rsi14 < 30.0"}        {oversold30:rsi14}

	CUSTOM {
	    input "last_close upperBB middleBB lowerBB" 
	    expr_func "expr" 
	    expr_args " ($last_close - $lowerBB) / ($upperBB - $lowerBB) "
	} {percent_b:bb_20_2_2}

	CUSTOM {
	    input "upperBB middleBB lowerBB" 
	    expr_func "expr" 
	    expr_args "  ($upperBB - $lowerBB) / $middleBB "
	} {bandwidth:bb_20_2_2}

	CUSTOM {
	    input "ema5 ema10 ema20" 
	    expr_func "expr" 
	    expr_args " ($ema5 > $ema20) && ($ema10 > $ema20) "
	} {ema5_ema10_ABOVE_ema20}

	CUSTOM {
	    input "ema5 ema10 ema20" 
	    expr_func "expr" 
	    expr_args " ($ema5 < $ema20) && ($ema10 < $ema20) "
	} {ema5_ema10_BELOW_ema20}

	CUSTOM {
	    input "sma50 sma200 stddev50_3"
	    expr_func "expr"
	    expr_args "($sma50 - $sma200)/$stddev50_3"
	    comment {
		NOT QUITE SURE WHETHER THE AUTHOR TALKED ABOUT stddev50_3 or stddev200_3

		A confidence-based approach might look more like: as moving average X 
		climbs further above/below moving average Y, increase exposure to the 
		market from -100 to 100% (and all the steps in between) with 0% being
		X=Y and +/-100% being X=+/-3 standard deviations above/below Y.

		That's a little difficult to explain in text, but the difference is 
		two-fold: (a) you could jump into the strategy at any point and it
		would have an opinion on the market, and (b) the strategy isn't just 
		trading a condition (i.e. X crossing Y) but expressing a confidence
		in that prediction from -100 to 100% and all the steps in between.

		The confidence-based approach has two advantages.

		First, and most importantly, it increases sample size. In the 
		confidence-based strategy, because of the introduction of the concept 
		of confidence (and the fact that it's radically changing from 0 to 100%) 
		smaller units of time (such as days) can be treated as an observation.

		(*) Side note: well, not completely in a very long-term strategy like 
		50/200-day crossovers the confidence value isn't changing enough day-to-day, 
		so no, each day is not an observation – but perhaps each month is, and that's 
		a hell of an improvement.

		The second advantage is that it forces the trader to think of the 
		portfolio as a sliding scale rather than X number of fixed positions. Not only 
		are we using the binary condition to guide our trades (X crossing Y), 
		but the strength of that condition as well. That added layer can do a lot 
		to help a strategy focus exposure on those times when the market becomes 
		particularly predictable and reduce exposure when it is less so.

	    }
	} {example_confidence_approach_sma50_sma200}

	CUSTOM {
	    disabled true
	    input "roc1 ema1500_of_roc1" 
	    expr_func "expr" 
	    expr_args "$roc1 - $ema1500_of_roc1 "
	    comment {

		FIX: DOES NOT SEEM TO BE DOING WHAT IS EXPECTED

		What I mean by daily follow-through is if the market is up today, 
		how likely is it to be up tomorrow, and if it is down today, 
		how likely is it to be down tomorrow? But more importantly, how is
		the answer changing over time?

		Geek notes: (1) returns have been normalized by subtracting the 
		average return 	of all days in each observation period to remove 
		the influence of bull vs bear markets, (2) averages are geometric.
	    }
	} {example_daily_follow_through}


	CUSTOM {
	    disabled true
	    input "sma50 sma200" 
	    lookback "-30"
	    expr_func "expr" 
	    expr_args " ( $frame(sma50,-30) < $frame(sma200,-30) ) && ( $sma50 > $sma200 ) "
	    comment {
		The Golden Cross aka 50/200-day crossovers.
		SLOW - MUST FIGURE OUT A BETTER WAY TO COMPUTE THIS, YET KEEP THE EXPRESSIVITY OF THE FRAMEWORK. 
	    }
	} {sma50_CROSSOVER_LB30_sma200}


    }
    aggregate {
	score_1d:overbought70:rsi2 {overbought70:rsi2 last_close} count_agg {countArray1 lb_var1 -1 ${overbought70:rsi2} $last_close}
	score_1d:overbought70:rsi14 {overbought70:rsi14 last_close} count_agg {countArray2 lb_var2 -1 ${overbought70:rsi14} $last_close}
	score_5d:upward_crossover_1d:sma15_sma50 {upward_crossover_1d:sma15_sma50 last_close} count_agg {countArray3 lb_var3 -5 ${upward_crossover_1d:sma15_sma50} $last_close}
	score_1d:downward_crossover_1d:sma15_sma50 {downward_crossover_1d:sma15_sma50 last_close} count_agg {countArray4 lb_var4 -1 ${downward_crossover_1d:sma15_sma50} $last_close}
	score_1d:upward_crossover_1d:price_sma15 {upward_crossover_1d:price_sma15 last_close} count_agg {countArray5 lb_var5 -1 ${upward_crossover_1d:price_sma15} $last_close}
	score_15d:upward_crossover_1d:sma50_sma200 {upward_crossover_1d:sma50_sma200 last_close} count_agg {countArray6 lb_var6 -15 ${upward_crossover_1d:sma50_sma200} $last_close}
    }
    divergence {}
    machine_learning {}
    optimization {}
    ranking {}
    comments {


	evaluate indicators after a number of days, weeks, months, 
	i.e. was the indicator/signal RIGHT/WRONG and by how much?

	This is to be used for machine learning. We are trying to answer the question how much role does this indicator play
	in the price changes of a stock.

	Also, it is going to be used for ranking different indicators for each stock and investment horizon.

	Finally, it is going to be used to size our position (with kelly, perhaps)?

	We might as well use these results to evaluate the predictability of indicators such rsi14 
	on a particular stock. In other words, overbought70:rsi14 is a static indicator for all stocks. Our analysis
	might show that overbought73:rsi14 or overbought67:rsi14 is a "better" indicator for the IBM stock for trades 
	after a given interval (i.e. 1d,2d,3d,1w,2w, and so on).


	golden cross = upward crosso of sma50 over sma200

	crossover:ema5_ema10_ema20 is also known as 5-10-20 strategy (see marketsci blog): 
	"at today's close, if both the 5 and-day EMA are ABOVE the 20-day EMA, go long" and 
	"at today's close, if both the 5 and 10-day EMA are BELOW the 20-day EMA go to cash, i.e. close the position".

	percent_b, bandwidth, ema5_ema10_ABOVE_ema20, and so on are not signals, they are intermediate computations to be used by formulas to indicate signals, confirmation, and so on.
    }
}



############################################################### get_ta_table was here



## temporary place, move inside the spec
#set obs $table(inClose,numElems)
package require math::linearalgebra
namespace import ::math::linearalgebra::*

set new_forecast ""
set estimate ""
lappend estimate "DATA | Estimate (out_y) | Standard Deviation (out_y_err)" 
foreach column {inClose rsi14 mom10 log10 rocp1 ema20 mfi14} {
    set numElems $table($column,numElems)
    set dy [lrange $table($column,data) 0 $numElems]
    set obs $numElems
    set degree 4

    set dx [iota $obs]
    T_gsl_multifit_linear $obs $degree dx dy coeff cov


    set new_x_data [concat 1 [lreverse [lrange $dx [expr { $numElems - $degree + 1}] $numElems]]]
    ns_log notice "coeff=$coeff \n new_x_data=$new_x_data"
    ns_log notice [llength $new_x_data]=?=[llength $coeff]
    lappend new_forecast [list $column [matmul [transpose $coeff] $new_x_data]]

    T_gsl_multifit_linear_est $degree new_x_data coeff cov out_y out_y_err
    lappend estimate "$column | $out_y    | $out_y_err"
}
##


set numElems $table(mfi14,numElems)
set degree 7
set obs $numElems
set dx [iota $numElems]
set dy [linterleave \
	    [lrange $table(inClose,data) 0 $numElems] \
	    [lrange $table(log10,data) 0 $numElems] \
	    [lrange $table(ema20,data) 0 $numElems] \
	    [lrange $table(rocp1,data) 0 $numElems] \
	    [lrange $table(mfi14,data) 0 $numElems] \
	    [lrange $table(macd_12_26_9_signal,data) 0 $numElems]] ;#fit_data
T_gsl_multifit_linear $obs $degree dx dy coeff cov
    
set predict_x_data [list \
			[lindex $table(inClose,data) $numElems] \
			[lindex $table(log10,data) $numElems] \
			[lindex $table(ema20,data) $numElems] \
			[lindex $table(rocp1,data) $numElems] \
			[lindex $table(mfi14,data) $numElems] \
			[lindex $table(macd_12_26_9_signal,data) $numElems]]
T_gsl_multifit_linear_est $degree predict_x_data coeff cov out_y out_y_err
lappend estimate "out_y=$out_y"

