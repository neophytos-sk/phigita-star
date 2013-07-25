
package provide ta-lib 0.1

set dir [file dirname [info script]]
source [file join $dir module-ta-utils.tcl]

#set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir critcl-ext/tcl/module-critcl-ext.tcl]



::xo::lib::require critcl
::xo::lib::require critcl-ext

::critcl::reset
::critcl::config outdir /web/local-data/critcl/
::critcl::cache /web/local-data/critcl/cache/
::critcl::config force [::xo::kit::debug_mode_p]
::critcl::config keepsrc 1

::critcl::clibraries -L/opt/naviserver/lib -lta_lib -lm

::critcl::config I /opt/naviserver/include


critcl::ccode {
    #include "ta-lib/ta_libc.h"
    #include <math.h>
}



# Relative Strength Index
#
# The following algorithm is base on the original 
# work from Wilder's and shall represent the
# original idea behind the classic RSI.
#
# Metastock is starting the calculation one price
# bar earlier. To make this possible, they assume
# that the very first bar will be identical to the
# previous one (no gain or loss).
#

define_cproc TA_RSI {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}




# ==Rate of Change==
#
# The interpretation of the rate of change varies widely depending
# which software and/or books you are refering to.
#
# The following is the table of Rate-Of-Change implemented in TA-LIB:
#       MOM     = (price - prevPrice)         [Momentum]
#       ROC     = ((price/prevPrice)-1)*100   [Rate of change]
#       ROCP    = (price-prevPrice)/prevPrice [Rate of change Percentage]
#       ROCR    = (price/prevPrice)           [Rate of change ratio]
#       ROCR100 = (price/prevPrice)*100       [Rate of change ratio 100 Scale]
*
# Here are the equivalent function in other software:
#       TA-Lib  |   Tradestation   |    Metastock         
#       =================================================
#       MOM     |   Momentum       |    ROC (Point)
#       ROC     |   ROC            |    ROC (Percent)
#       ROCP    |   PercentChange  |    -     
#       ROCR    |   -              |    -
#       ROCR100 |   -              |    MO
#
# The MOM function is the only one who is not normalized, and thus
# should be avoided for comparing different time serie of prices.
# 
# ROC and ROCP are centered at zero and can have positive and negative
# value. Here are some equivalence:
#    ROC = ROCP/100 
#        = ((price-prevPrice)/prevPrice)/100
#        = ((price/prevPrice)-1)*100
#
# ROCR and ROCR100 are ratio respectively centered at 1 and 100 and are
# always positive values.
#


define_cproc TA_MOM {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}

define_cproc TA_ROC {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}

define_cproc TA_ROCP {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}

define_cproc TA_ROCR {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}

define_cproc TA_ROCR100 {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}



# Standard Deviation


define_cproc TA_STDDEV {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    double  optInNbDev
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx "2"]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod "5"]
    set optInNbDev [::util::coalesce $optInNbDev "1.0"]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}




# Moving Averages

define_cproc TA_MA {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int     optInMAType
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInMAType $MATypeArray([::util::coalesce $optInMAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx "2"]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod "30"]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]

}


# Bollinger Bands

define_cproc TA_BBANDS {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    double  optInNbDevUp
    double  optInNbDevDown
    int     optInMAType
    int*    outBegIdx
    int*    outNBElement
    double* outRealUpperBand
    double* outRealMiddleBand
    double* outRealLowerBand
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInMAType $MATypeArray([::util::coalesce $optInMAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 2]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod "30"]
    set optInNbDevUp [::util::coalesce $optInNbDevUp "2.0"]
    set optInNbDevDown [::util::coalesce $optInNbDevDown "2.0"]

    set outBegIdx 0
    set outNBElement 0
    set outRealUpperBand [lrepeat $size 0.0]
    set outRealMiddleBand [lrepeat $size 0.0]
    set outRealLowerBand [lrepeat $size 0.0]

}



# Moving Average Convergence Divergence: MACD, MACDFIX, MACDEXT

define_cproc TA_MACD {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInFastPeriod
    int     optInSlowPeriod
    int     optInSignalPeriod
    int*    outBegIdx
    int*    outNBElement
    double* outMACD
    double* outMACDSignal
    double* outMACDHist
} {

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastPeriod [::util::coalesce $optInFastPeriod "12"]
    set optInSlowPeriod [::util::coalesce $optInSlowPeriod "26"]
    set optInSignalPeriod [::util::coalesce $optInSignalPeriod "9"]


    set outBegIdx 0
    set outNBElement 0
    set outMACD [lrepeat $size 0.0]
    set outMACDSignal [lrepeat $size 0.0]
    set outMACDHist [lrepeat $size 0.0]

}

define_cproc TA_MACDFIX {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInSignalPeriod
    int*    outBegIdx
    int*    outNBElement
    double* outMACD
    double* outMACDSignal
    double* outMACDHist
} {

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInSignalPeriod [::util::coalesce $optInSignalPeriod "9"]


    set outBegIdx 0
    set outNBElement 0
    set outMACD [lrepeat $size 0.0]
    set outMACDSignal [lrepeat $size 0.0]
    set outMACDHist [lrepeat $size 0.0]

}


define_cproc TA_MACDEXT {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInFastPeriod
    int     optInFastMAType
    int     optInSlowPeriod
    int     optInSlowMAType
    int     optInSignalPeriod
    int     optInSignalMAType
    int*    outBegIdx
    int*    outNBElement
    double* outMACD
    double* outMACDSignal
    double* outMACDHist
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInFastMAType $MATypeArray([::util::coalesce $optInFastMAType "SMA"])
    set optInSlowMAType $MATypeArray([::util::coalesce $optInSlowMAType "SMA"])
    set optInSignalMAType $MATypeArray([::util::coalesce $optInSignalMAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastPeriod [::util::coalesce $optInFastPeriod "12"]
    set optInSlowPeriod [::util::coalesce $optInSlowPeriod "26"]
    set optInSignalPeriod [::util::coalesce $optInSignalPeriod "9"]


    set outBegIdx 0
    set outNBElement 0
    set outMACD [lrepeat $size 0.0]
    set outMACDSignal [lrepeat $size 0.0]
    set outMACDHist [lrepeat $size 0.0]

}


# SAR
# Implementation of the SAR has been a little bit open to interpretation
# since Wilder (the original author) did not define a precise algorithm
# on how to bootstrap the algorithm. Take any existing software application
# and you will see slight variation on how the algorithm was adapted.
#
# What is the initial trade direction? Long or short?
# ===================================================
# The interpretation of what should be the initial SAR values is
# open to interpretation, particularly since the caller to the function
# does not specify the initial direction of the trade.
#
# In TA-Lib, the following logic is used:
#  - Calculate +DM and -DM between the first and
#    second bar. The highest directional indication will
#    indicate the assumed direction of the trade for the second
#    price bar. 
#  - In the case of a tie between +DM and -DM,
#    the direction is LONG by default.
#
# What is the initial "extreme point" and thus SAR?
# =================================================
# The following shows how different people took different approach:
#  - Metastock use the first price bar high/low depending of
#    the direction. No SAR is calculated for the first price
#    bar.
#  - Tradestation use the closing price of the second bar. No
#    SAR are calculated for the first price bar.
#  - Wilder (the original author) use the SIP from the
#    previous trade (cannot be implement here since the
#    direction and length of the previous trade is unknonw).
#  - The Magazine TASC seems to follow Wilder approach which
#    is not practical here.
#
# TA-Lib "consume" the first price bar and use its high/low as the
# initial SAR of the second price bar. I found that approach to be
# the closest to Wilders idea of having the first entry day use
# the previous extreme point, except that here the extreme point is
# derived solely from the first price bar. I found the same approach
# to be used by Metastock.

define_cproc TA_SAR {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double  optInAcceleration
    double  optInMaximum
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInAcceleration [::util::coalesce $optInAcceleration 0.02]
    set optInMaximum [::util::coalesce $optInMaximum 0.2]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


# TA_SAREXT - Parabolic SAR - Extended
# 
# Input  = High, Low
# Output = double
# 
# Optional Parameters
# -------------------
# optInStartValue:(From TA_REAL_MIN to TA_REAL_MAX)
#    Start value and direction. 0 for Auto, >0 for Long, <0 for Short
# 
# optInOffsetOnReverse:(From 0 to TA_REAL_MAX)
#    Percent offset added/removed to initial stop on short/long reversal
# 
# optInAccelerationInitLong:(From 0 to TA_REAL_MAX)
#    Acceleration Factor initial value for the Long direction
# 
# optInAccelerationLong:(From 0 to TA_REAL_MAX)
#    Acceleration Factor for the Long direction
# 
# optInAccelerationMaxLong:(From 0 to TA_REAL_MAX)
#    Acceleration Factor maximum value for the Long direction
# 
# optInAccelerationInitShort:(From 0 to TA_REAL_MAX)
#    Acceleration Factor initial value for the Short direction
# 
# optInAccelerationShort:(From 0 to TA_REAL_MAX)
#    Acceleration Factor for the Short direction
# 
# optInAccelerationMaxShort:(From 0 to TA_REAL_MAX)
#    Acceleration Factor maximum value for the Short direction
# 
define_cproc TA_SAREXT {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double  optInStartValue
    double  optInOffsetOnReverse
    double  optInAccelerationInitLong
    double  optInAccelerationLong
    double  optInAccelerationMaxLong
    double  optInAccelerationInitShort
    double  optInAccelerationShort
    double  optInAccelerationMaxShort
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]

    foreach varName {
	optInStartValue 
	optInOffsetOnReverse 
	optInAccelerationInitLong 
	optInAccelerationLong 
	optInAccelerationMaxLong 
	optInAccelerationInitShort 
	optInAccelerationShort 
	optInAccelerationMaxShort
    } defaultValue {
	0.0
	0.0
	0.02
	0.02
	0.2
	0.02
	0.02
	0.2
    } {
	set $varName [::util::coalesce [set $varName] 0.0]
    }

    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}







# On Balance Volume 

# On-balance volume (OBV) is a technical analysis indicator intended to relate price and volume in the stock market. OBV is based on a cumulative total volume. 
#
# Total volume for each day is assigned a positive or negative value depending on prices being higher or lower that day. A higher close results in the volume for that day to get a positive value, while a lower close results in negative value. So when prices are going up, OBV should be going up too, and when prices make a new rally high, OBV should too. If OBV fails to go past its previous rally high then this is a negative divergence, suggesting a weak move.The technique, originally called "Cumulative volume" by Woods and Vignolia, was later named in 1946, "on-balance volume" by Joseph Granville and popularized the technique in his 1963 book Granville's New Key to Stock Market Profits. It can be applied to stocks individually based upon their daily up or down close, or the market as a whole using breadth of market data, i.e. the advance/decline ratio. OBV is generally used to confirm price moves. The idea is that volume is higher on days where the price move is in the dominant direction, for example in a strong uptrend more volume on up days than down days.




define_cproc TA_OBV {
    int     startIdx
    int     endIdx
    double* inReal
    double* inVolume
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]

    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}




# Money Flow Index


define_cproc TA_MFI {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double* inClose
    double* inVolume
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}



# ADOSC
#     The fastEMA variable is not neceseraly the
#     fastest EMA.
#     In the same way, slowEMA is not neceseraly the
#     slowest EMA.
#
#     The ADOSC is always the (fastEMA - slowEMA) regardless
#     of the period specified. In other word:
# 
#     ADOSC(3,10) = EMA(3,AD) - EMA(10,AD)
#
#        while
#
#     ADOSC(10,3) = EMA(10,AD)- EMA(3,AD)
#
#     In the first case the EMA(3) is truly a faster EMA,
#     while in the second case, the EMA(10) is still call
#     fastEMA in the algorithm, even if it is in fact slower.
#
#     This gives more flexibility to the user if they want to
#     experiment with unusual parameter settings.

define_cproc TA_ADOSC {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double* inClose
    double* inVolume
    int     optInFastPeriod
    int     optInSlowPeriod
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastPeriod [::util::coalesce $optInFastPeriod 3]
    set optInSlowPeriod [::util::coalesce $optInSlowPeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}





# CANDLESTICK PATTERNS
#   Percentage of penetration of a candle within another candle


foreach name {
    CDLEVENINGDOJISTAR  CDLEVENINGSTAR CDLMORNINGDOJISTAR CDLMORNINGSTAR 
    CDLDARKCLOUDCOVER CDLMATHOLD CDLABANDONEDBABY
} penetration {
    0.3 0.3 0.3 0.3
    0.5 0.5 0.3
} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inOpen
	double* inHigh
	double* inLow
	double* inClose
	double  optInPenetration
	int*    outBegIdx
	int*    outNBElement
	int*    outInteger
    } [format {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInPenetration [::util::coalesce $optInPenetration "%s"]

	set outBegIdx 0
	set outNBElement 0
	set outInteger [lrepeat $size 0]
    } $penetration]

}


foreach name {
    CDL2CROWS          CDLBELTHOLD          CDLENGULFING         CDLHIGHWAVE         CDLLADDERBOTTOM     CDLPIERCING          CDLTAKURI
    CDL3BLACKCROWS     CDLBREAKAWAY                              CDLHIKKAKE          CDLLONGLEGGEDDOJI   CDLRICKSHAWMAN       CDLTASUKIGAP
    CDL3INSIDE         CDLCLOSINGMARUBOZU                        CDLHIKKAKEMOD       CDLLONGLINE         CDLRISEFALL3METHODS  CDLTHRUSTING
    CDL3LINESTRIKE     CDLCONCEALBABYSWALL  CDLGAPSIDESIDEWHITE  CDLHOMINGPIGEON     CDLMARUBOZU         CDLSEPARATINGLINES   CDLTRISTAR
    CDL3OUTSIDE        CDLCOUNTERATTACK     CDLGRAVESTONEDOJI    CDLIDENTICAL3CROWS  CDLMATCHINGLOW      CDLSHOOTINGSTAR      CDLUNIQUE3RIVER
    CDL3STARSINSOUTH                        CDLHAMMER            CDLINNECK                               CDLSHORTLINE         CDLUPSIDEGAP2CROWS
    CDL3WHITESOLDIERS  CDLDOJI              CDLHANGINGMAN        CDLINVERTEDHAMMER                       CDLSPINNINGTOP       CDLXSIDEGAP3METHODS
    CDLDOJISTAR          CDLHARAMI            CDLKICKINGBYLENGTH                      CDLSTALLEDPATTERN
    CDLADVANCEBLOCK    CDLDRAGONFLYDOJI     CDLHARAMICROSS       CDLKICKING          CDLONNECK           CDLSTICKSANDWICH
} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inOpen
	double* inHigh
	double* inLow
	double* inClose
	int*    outBegIdx
	int*    outNBElement
	int*    outInteger
    } {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	
	set outBegIdx 0
	set outNBElement 0
	set outInteger [lrepeat $size 0]
    }

}




# SIN, SINH, ..., 
# HT_TRENDLINE, HT_DCPERIOD, HT_DCPHASE

foreach name {ACOS ASIN ATAN CEIL COS COSH EXP FLOOR LN LOG10 SIN SINH SQRT TAN TANH HT_TRENDLINE HT_DCPERIOD HT_DCPHASE} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } {
	set size [llength $inReal]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    }

}


# MAX, MIN, MIDPOINT

foreach name {CMO LINEARREG_ANGLE LINEARREG LINEARREG_INTERCEPT LINEARREG_SLOPE  MAX MIDPOINT MIN TRIX TSF SMA EMA WMA DEMA TEMA TRIMA KAMA SUM} defaultTimePeriod {14 14 14 14 14 30 14 30 30 14 30 30 30 30 30 30 30 30} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal
	int     optInTimePeriod
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } [format {
	set size [llength $inReal]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInTimePeriod [::util::coalesce $optInTimePeriod %s]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    } $defaultTimePeriod]

}


foreach name {MAXINDEX MININDEX} defaultTimePeriod {30 30} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal
	int     optInTimePeriod
	int*    outBegIdx
	int*    outNBElement
	int*    outInteger
    } [format {
	set size [llength $inReal]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInTimePeriod [::util::coalesce $optInTimePeriod %s]
	
	set outBegIdx 0
	set outNBElement 0
	set outInteger [lrepeat $size 0]
    } $defaultTimePeriod]

}


# MINMAXINDEX
foreach name {MINMAXINDEX} defaultTimePeriod {30} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal
	int     optInTimePeriod
	int*    outBegIdx
	int*    outNBElement
	int*    outMinIdx
	int*    outMaxIdx
    } [format {
	set size [llength $inReal]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInTimePeriod [::util::coalesce $optInTimePeriod %s]
	
	set outBegIdx 0
	set outNBElement 0
	set outMinIdx [lrepeat $size 0]
	set outMaxIdx [lrepeat $size 0]
    } $defaultTimePeriod]

}


# MINMAX


define_cproc TA_MINMAX {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outMin
    double* outMax
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 30]

    set outBegIdx 0
    set outNBElement 0
    set outMin [lrepeat $size 0.0]
    set outMax [lrepeat $size 0.0]
}




# VAR

define_cproc TA_VAR {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    double  optInNbDev
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
    set optInNbDev [::util::coalesce $optInNbDev 5]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


### CORREL - Pearson's Correlation Coefficient (r)

### BETA
#   The Beta 'algorithm' is a measure of a stocks volatility vs from index. The stock prices
#   are given in inReal0 and the index prices are give in inReal1. The size of these vectors
#   should be equal. The algorithm is to calculate the change between prices in both vectors
#   and then 'plot' these changes are points in the Euclidean plane. The x value of the point
#   is market return and the y value is the security return. The beta value is the slope of a
#   linear regression through these points. A beta of 1 is simple the line y=x, so the stock
#   varies percisely with the market. A beta of less than one means the stock varies less than
#   the market and a beta of more than one means the stock varies more than market. A related
#   value is the Alpha value (see TA_ALPHA) which is the Y-intercept of the same linear regression.


foreach name {CORREL BETA} defaultTimePeriod {30 5} {
    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal0
	double* inReal1
	int     optInTimePeriod
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } [format {
	set size [llength $inReal0]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInTimePeriod [::util::coalesce $optInTimePeriod %s]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    } $defaultTimePeriod]
}



# BOP, AVGPRICE
foreach name {BOP AVGPRICE} {
    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inOpen
	double* inHigh
	double* inLow
	double* inClose
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    }
}

# TRANGE, WCLPRICE, TYPPRICE
foreach name {TRANGE WCLPRICE TYPPRICE} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inHigh
	double* inLow
	double* inClose
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } {
	set size [llength $inHigh]
	
	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    }
}

# AD
define_cproc TA_AD {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double* inClose
    double* inVolume
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inClose]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}

# ATR, CCI, WILLR, NATR, ADX, ADXR, PLUS_DI, MINUS_DI, DX
foreach name {ATR CCI WILLR NATR ADX ADXR PLUS_DI MINUS_DI DX} defaultTimePeriod {14 14 14 14 14 14 14 14 14} {
    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inHigh
	double* inLow
	double* inClose
	int     optInTimePeriod
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } [format {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInTimePeriod [::util::coalesce $optInTimePeriod %s]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    } $defaultTimePeriod]
}

# ULTOSC
define_cproc TA_ULTOSC {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double* inClose
    int     optInTimePeriod1
    int     optInTimePeriod2
    int     optInTimePeriod3
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inClose]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod1 [::util::coalesce $optInTimePeriod1 7]
    set optInTimePeriod2 [::util::coalesce $optInTimePeriod2 14]
    set optInTimePeriod3 [::util::coalesce $optInTimePeriod3 28]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


# MIDPRICE MINUS_DM PLUS_DM AROONOSC

foreach name {MIDPRICE MINUS_DM PLUS_DM AROONOSC} defaultTimePeriod {14 14 14 14} {
    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inHigh
	double* inLow
	int     optInTimePeriod
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } [format {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	set optInTimePeriod [::util::coalesce $optInTimePeriod %s]

	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    } $defaultTimePeriod]
}

# MEDPRICE
define_cproc TA_MEDPRICE {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inClose]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


# DIV, SUB, MULT, ADD
foreach name {DIV SUB MULT ADD} {
    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal0
	double* inReal1
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } {
	set size [llength $inReal0]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    }
}


# HT_TRENDMODE

foreach name {HT_TRENDMODE} {

    define_cproc TA_${name} {
	int     startIdx
	int     endIdx
	double* inReal
	int*    outBegIdx
	int*    outNBElement
	int*    outInteger
    } {
	set size [llength $inReal]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
	
	set outBegIdx 0
	set outNBElement 0
	set outInteger [lrepeat $size 0]
    }

}


# AROON
define_cproc TA_AROON {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    int     optInTimePeriod
    int*    outBegIdx
    int*    outNBElement
    double* outAroonDown
    double* outAroonUp
} {
    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 3]
    
    set outBegIdx 0
    set outNBElement 0
    set outAroonDown [lrepeat $size 0.0]
    set outAroonUp [lrepeat $size 0.0]
}



# STOCH
define_cproc TA_STOCH {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double* inClose
    int     optInFastK_Period
    int     optInSlowK_Period
    int     optInSlowK_MAType
    int     optInSlowD_Period
    int     optInSlowD_MAType
    int*    outBegIdx
    int*    outNBElement
    double* outSlowK
    double* outSlowD
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInSlowK_MAType $MATypeArray([::util::coalesce $optInSlowK_MAType "SMA"])
    set optInSlowD_MAType $MATypeArray([::util::coalesce $optInSlowD_MAType "SMA"])

    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastK_Period [::util::coalesce $optInFastK_Period 5]
    set optInSlowK_Period [::util::coalesce $optInSlowK_Period 3]
    set optInSlowD_Period [::util::coalesce $optInSlowD_Period 3]


    set outBegIdx 0
    set outNBElement 0
    set outSlowK [lrepeat $size 0.0]
    set outSlowD [lrepeat $size 0.0]
}


define_cproc TA_STOCHF {
    int     startIdx
    int     endIdx
    double* inHigh
    double* inLow
    double* inClose
    int     optInFastK_Period
    int     optInFastD_Period
    int     optInFastD_MAType
    int*    outBegIdx
    int*    outNBElement
    double* outFastK
    double* outFastD
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInFastD_MAType $MATypeArray([::util::coalesce $optInFastD_MAType "SMA"])

    set size [llength $inHigh]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastK_Period [::util::coalesce $optInFastK_Period 5]
    set optInFastD_Period [::util::coalesce $optInFastD_Period 3]


    set outBegIdx 0
    set outNBElement 0
    set outFastK [lrepeat $size 0.0]
    set outFastD [lrepeat $size 0.0]
}


# STOCHRSI
define_cproc TA_STOCHRSI {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int     optInFastK_Period
    int     optInFastD_Period
    int     optInFastD_MAType
    int*    outBegIdx
    int*    outNBElement
    double* outFastK
    double* outFastD
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInFastD_MAType $MATypeArray([::util::coalesce $optInFastD_MAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
    set optInFastK_Period [::util::coalesce $optInFastK_Period 5]
    set optInFastD_Period [::util::coalesce $optInFastD_Period 3]


    set outBegIdx 0
    set outNBElement 0
    set outFastK [lrepeat $size 0.0]
    set outFastD [lrepeat $size 0.0]
}



# APO
define_cproc TA_APO {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInFastPeriod
    int     optInSlowPeriod
    int     optInMAType
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInMAType $MATypeArray([::util::coalesce $optInMAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastPeriod [::util::coalesce $optInFastPeriod "12"]
    set optInSlowPeriod [::util::coalesce $optInSlowPeriod "26"]


    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]

}



# Moving Average Variable Period
define_cproc TA_MAVP {
    int     startIdx
    int     endIdx
    double* inReal
    double* inPeriods
    int     optInMinPeriod
    int     optInMaxPeriod
    int     optInMAType
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInMAType $MATypeArray([::util::coalesce $optInMAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInMinPeriod [::util::coalesce $optInMinPeriod 2]
    set optInMaxPeriod [::util::coalesce $optInMaxPeriod 30]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


# HT_PHASOR
define_cproc TA_HT_PHASOR {
    int     startIdx
    int     endIdx
    double* inReal
    int*    outBegIdx
    int*    outNBElement
    double* outInPhase
    double* outQuadrature
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    
    set outBegIdx 0
    set outNBElement 0
    set outInPhase [lrepeat $size 0.0]
    set outQuadrature [lrepeat $size 0.0]
}



# HT_SINE
define_cproc TA_HT_SINE {
    int     startIdx
    int     endIdx
    double* inReal
    int*    outBegIdx
    int*    outNBElement
    double* outSine
    double* outLeadSine
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    
    set outBegIdx 0
    set outNBElement 0
    set outSine [lrepeat $size 0.0]
    set outLeadSine [lrepeat $size 0.0]
}



# PPO
define_cproc TA_PPO {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInFastPeriod
    int     optInSlowPeriod
    int     optInMAType
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    array set MATypeArray [list "SMA" 0 "EMA" 1 "WMA" 2 "DEMA" 3 "TEMA" 4 "TRIMA" 5 "KAMA" 6 "MAMA" 7 "T3" 8]
    set optInMAType $MATypeArray([::util::coalesce $optInMAType "SMA"])

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastPeriod [::util::coalesce $optInFastPeriod 3]
    set optInSlowPeriod [::util::coalesce $optInSlowPeriod 10]
    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


# T3
define_cproc TA_T3 {
    int     startIdx
    int     endIdx
    double* inReal
    int     optInTimePeriod
    int     optInVFactor
    int*    outBegIdx
    int*    outNBElement
    double* outReal
} {
    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInTimePeriod [::util::coalesce $optInTimePeriod 5]
    set optInVFactor [::util::coalesce $optInVFactor 0.7]

    
    set outBegIdx 0
    set outNBElement 0
    set outReal [lrepeat $size 0.0]
}


# MAMA
define_cproc TA_MAMA {
    int     startIdx
    int     endIdx
    double* inReal
    double  optInFastLimit
    double  optInSlowLimit
    int*    outBegIdx
    int*    outNBElement
    double* outMAMA
    double* outFAMA
} {

    set size [llength $inReal]

    set startIdx [::util::coalesce $startIdx 0]
    set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]
    set optInFastLimit [::util::coalesce $optInFastPeriod 0.5]
    set optInSlowLimit [::util::coalesce $optInSlowPeriod 0.05]
    
    set outBegIdx 0
    set outNBElement 0
    set outMAMA [lrepeat $size 0.0]
    set outFAMA [lrepeat $size 0.0]
}



if {0} {

    # NVI
    define_cproc TA_NVI {
	int     startIdx
	int     endIdx
	double* inClose
	double* inVolume
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]

	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    }

    # PVI
    define_cproc TA_PVI {
	int     startIdx
	int     endIdx
	double* inClose
	int*    inVolume
	int*    outBegIdx
	int*    outNBElement
	double* outReal
    } {
	set size [llength $inClose]

	set startIdx [::util::coalesce $startIdx 0]
	set endIdx [::util::coalesce $endIdx [expr {$size - 1}]]

	
	set outBegIdx 0
	set outNBElement 0
	set outReal [lrepeat $size 0.0]
    }
}

set numTAFuncFound 0
set TA_FUNC_NOT_FOUND [list]
foreach name {
    CDL2CROWS            CDLEVENINGDOJISTAR   CDLLONGLINE          CDLTRISTAR           HT_TRENDLINE         MIDPOINT     ROCR100   TRANGE
    CDL3BLACKCROWS       CDLEVENINGSTAR       CDLMARUBOZU          CDLUNIQUE3RIVER      HT_TRENDMODE         MIDPRICE     ROCR      TRIMA
    ACOS      CDL3INSIDE           CDLGAPSIDESIDEWHITE  CDLMATCHINGLOW       CDLUPSIDEGAP2CROWS   KAMA                 MIN          RSI       TRIX
    AD        CDL3LINESTRIKE       CDLGRAVESTONEDOJI    CDLMATHOLD           CDLXSIDEGAP3METHODS  LINEARREG_ANGLE      MININDEX     SAR       TSF
    ADD       CDL3OUTSIDE          CDLHAMMER            CDLMORNINGDOJISTAR   CEIL                 LINEARREG            MINMAX       SAREXT    TYPPRICE
    ADOSC     CDL3STARSINSOUTH     CDLHANGINGMAN        CDLMORNINGSTAR       CMO                  LINEARREG_INTERCEPT  MINMAXINDEX  SIN       ULTOSC
    ADX       CDL3WHITESOLDIERS    CDLHARAMI            CDLONNECK            CORREL               LINEARREG_SLOPE      MINUS_DI     SINH      
    ADXR      CDLABANDONEDBABY     CDLHARAMICROSS       CDLPIERCING          COS                  LN                   MINUS_DM     SMA       
    APO       CDLADVANCEBLOCK      CDLHIGHWAVE          CDLRICKSHAWMAN       COSH                 LOG10                MOM          SQRT      VAR
    AROON     CDLBELTHOLD          CDLHIKKAKE           CDLRISEFALL3METHODS  DEMA                 MA                   MULT         STDDEV    WCLPRICE
    AROONOSC  CDLBREAKAWAY         CDLHIKKAKEMOD        CDLSEPARATINGLINES   DIV                  MACD                 NATR         STOCH     WILLR
    ASIN      CDLCLOSINGMARUBOZU   CDLHOMINGPIGEON      CDLSHOOTINGSTAR      DX                   MACDEXT              NVI          STOCHF    WMA
    ATAN      CDLCONCEALBABYSWALL  CDLIDENTICAL3CROWS   CDLSHORTLINE         EMA                  MACDFIX              OBV          STOCHRSI
    ATR       CDLCOUNTERATTACK     CDLINNECK            CDLSPINNINGTOP       EXP                  MAMA                 PLUS_DI      SUB
    AVGPRICE  CDLDARKCLOUDCOVER    CDLINVERTEDHAMMER    CDLSTALLEDPATTERN    FLOOR                MAVP                 PLUS_DM      SUM
    BBANDS    CDLDOJI              CDLKICKINGBYLENGTH   CDLSTICKSANDWICH     HT_DCPERIOD          MAX                  PPO          T3
    BETA      CDLDOJISTAR          CDLKICKING           CDLTAKURI            HT_DCPHASE           MAXINDEX             PVI          TAN
    BOP       CDLDRAGONFLYDOJI     CDLLADDERBOTTOM      CDLTASUKIGAP         HT_PHASOR            MEDPRICE             ROC          TANH
    CCI       CDLENGULFING         CDLLONGLEGGEDDOJI    CDLTHRUSTING         HT_SINE              MFI                  ROCP         TEMA

    ACCBANDS
    

} {

    if { [info procs TA_$name] eq {} } {
	lappend TA_FUNC_NOT_FOUND $name
    } else {
	incr numTAFuncFound
    }

}


ns_log notice "numTAFuncFound=$numTAFuncFound TA_FUNC_NOT_FOUND=$TA_FUNC_NOT_FOUND"

set spec {


    SUB {
	tags {}
	args {
	    int     startIdx
	    int     endIdx
	    double* inReal0
	    double* inReal1
	    int     optInTimePeriod
	    int*    outBegIdx
	    int*    outNBElement
	    double* outReal
	}
	tcl_init {
	    
	    set size [llength $inReal0]


	    set startIdx [::util::coalesce $startIdx 0]
	    set endIdx [::util::coalesce $endIdx [expr { $size - 1}]]
	    set optInTimePeriod [::util::coalesce $optInTimePeriod 1]
	    set outReal [lrepeat $size 0.0]

	}
	c_init {
	    int inIdx, trailingIdx, outIdx;


	    /* Identify the minimum number of price bar needed
	     * to calculate at least one output.
	     */
	    int lookbackTotal;
	    lookbackTotal = optInTimePeriod;
	}
	code {
	    outIdx      = 0;
	    inIdx       = startIdx;
	    trailingIdx = startIdx - optInTimePeriod;
	
	    while( inIdx <= endIdx ) 
	    {
		outReal[outIdx++] = inReal0[inIdx++] - inReal1[trailingIdx++];
	    }

	    /* Set output limits. */
	    VALUE_HANDLE_DEREF(outNBElement) = outIdx;
	    VALUE_HANDLE_DEREF(outBegIdx)    = startIdx;

	}
    }


    STREAK {
	tags {}
	args {
	    int     startIdx
	    int     endIdx
	    double* inReal
	    int*    outBegIdx
	    int*    outNBElement
	    int*    outInteger
	    double* outReal
	}
	tcl_init {
	    
	    set size [llength $inReal]

	    set startIdx [::util::coalesce $startIdx 0]
	    set endIdx [::util::coalesce $endIdx [expr { $size - 1}]]
	    set outInteger [lrepeat $size 0]
	    set outReal [lrepeat $size 0.0]

	}
	c_init {
	    int inIdx, trailingIdx, outIdx;
	    int sign;


	    /* Identify the minimum number of price bar needed
	     * to calculate at least one output.
	     */
	    int lookbackTotal=1;
	}
	code {
	    outIdx      = 1;
	    inIdx       = startIdx;
	    trailingIdx = startIdx - 1;

	    while( inIdx <= endIdx )
	    {

		/* The signbit() macro returns a non-zero value if and 
		 * only if the sign of its argument value is negative. 
		 */

		sign = signbit(inReal[trailingIdx]);

		if ( signbit(inReal[inIdx]) == signbit(inReal[trailingIdx]) ) 
		{
		    /* streak count */
		    outInteger[outIdx] = outInteger[outIdx-1] + (sign?-1:1);

		    /* streak sum */
		    outReal[outIdx] = outReal[outIdx-1] + (sign?-1:1)*inReal[inIdx];
		}
		outIdx++;
		inIdx++;
		trailingIdx++;
	    }

	    /* Set output limits. */
	    VALUE_HANDLE_DEREF(outNBElement) = outIdx;
	    VALUE_HANDLE_DEREF(outBegIdx)    = startIdx-1;

	}
    }


    GMA {
	hint {Geometric Moving Average}
	tags {Geometric Mean, AM-GM inequality}
	note {

	    ==Wikipedia==

	    The geometric mean, in mathematics, is a type of mean or average, which indicates
	    the central tendency or typical value of a set of numbers. The geometric mean is only
	    defined for a list of non-negative real numbers:

	    GMA = pow(x1*x2*...*xn,1/n) = exp(ln(x1)+ln(x2)+...+ln(xn)/n) where x1,x2,...,xn > 0

	    The inequality of arithmetic and geometric means, or more briefly the AM-GM inequality, 
	    states that the arithmetic mean of a list of non-negative real numbers is greater than
	    or equal to the geometric mean of the same list; and further, that the two means are
	    equal if and only if every number in the list is the same.

	    ==Investopedia==

	    The average of a set of products, the calculation of which is commonly used to determine
	    the performance results of an investment or portfolio. [...] The geometric mean must be
	    used when working with percentages (which are derived from values), whereas the 
	    standard arithmetic mean will work with the values themselves.
	    
	    The main benefit to using the geometric mean is that the actual amounts invested do not
	    need to be known; the calculation focuses entirely on the return figures themselves and
	    presents an "apples-to-apples" comparison when looking at two investment options.

	}
	args {
	    int     startIdx
	    int     endIdx
	    double* inReal
	    int     optInTimePeriod
	    int     optInAdjustPercent
	    int*    outBegIdx
	    int*    outNBElement
	    double* outReal
	}
	tcl_init {
	    
	    set size [llength $inReal]

	    set startIdx [::util::coalesce $startIdx 0]
	    set endIdx [::util::coalesce $endIdx [expr { $size - 1}]]
	    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
	    set outReal [lrepeat $size 0.0]

	}
	c_init {
	    double periodTotal, tempReal;
	    int inIdx, trailingIdx, outIdx;

	    /* Identify the minimum number of price bar needed
	     * to calculate at least one output.
	     */
	    int lookbackTotal;
	    lookbackTotal = (optInTimePeriod-1);

	}
	code {

	    /* Do the MA calculation using tight loops.
	     * Add-up the initial period, except for the last value. 
	     */
	    periodTotal = 0;
	    trailingIdx = startIdx-lookbackTotal;
	    
	    inIdx=trailingIdx;
	    if( optInTimePeriod > 1 )
	    {
		while( inIdx < startIdx )
		{
		    periodTotal += inReal[inIdx++];
		}
	    }

	    outIdx      = 0;
	    while( inIdx <= endIdx )
	    {
		/* pass optInAdjustPercent=1 when value is a percentage 
		 * and thus needs to be converted into a multiplier.
		 * e.g. 13% to 1.13 -5% to 0.95 
		 */
		periodTotal += log(optInAdjustPercent+inReal[inIdx++]);
		tempReal = periodTotal;
		periodTotal -= log(optInAdjustPercent+inReal[trailingIdx++]);
		outReal[outIdx++] = exp(tempReal / optInTimePeriod);
	    }

	    /* Set output limits. */
	    VALUE_HANDLE_DEREF(outNBElement) = outIdx;
	    VALUE_HANDLE_DEREF(outBegIdx)    = startIdx;

	}
    }

    DD {
	hint {Drawdown}
	tags {Drawdown}
	note {

	    ==Wikipedia==

	    The Drawdown is the measure of the decline from a historical peak in some variable 
	    (typically the cumulative profit or total open equity of a financial trading strategy).

	    The Maximum Drawdown (MDD) up to time T is the maximum of the Drawdown over the 
	    history of the variable.

	    ==Investopedia==

	    The peak-to-trough decline during a specific record period of an investment, 
	    fund or commodity. A drawdown is usually quoted as the percentage between the peak 
	    and the trough.

	}
	args {
	    int     startIdx
	    int     endIdx
	    double* inReal
	    int     optInTimePeriod
	    int*    outBegIdx
	    int*    outNBElement
	    double* outDD
	}
	tcl_init {
	    
	    set size [llength $inReal]

	    set startIdx [::util::coalesce $startIdx 0]
	    set endIdx [::util::coalesce $endIdx [expr { $size - 1}]]
	    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
	    set outDD [lrepeat $size 0.0]

	}
	c_init {

	    double highest, tempReal, maxDrawdown;
	    int i, inIdx, trailingIdx, outIdx, highestIdx, maxDrawdownIdx;

	    /* Identify the minimum number of price bar needed
	     * to calculate at least one output.
	     */
	    int lookbackTotal;
	    lookbackTotal = (optInTimePeriod-1);

	    /* Move up the start index if there is not
	     * enough initial data.
	     */
	    if( startIdx < lookbackTotal )
	    {
		startIdx = lookbackTotal;
	    }

	    /* Make sure there is still something to evaluate. */
	    if( startIdx > endIdx )
	    {
		VALUE_HANDLE_DEREF_TO_ZERO(outBegIdx);
		VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
		return ENUM_VALUE(RetCode,TA_SUCCESS,Success);
	    }
	    

	}
	code {


	    /* Proceed with the calculation for the requested range.
	    * Note that this algorithm allows the input and
	    * output to be the same buffer.
	    */
	    outIdx = 0;
	    inIdx       = startIdx;
	    trailingIdx = startIdx-lookbackTotal;
	    highestIdx  = -1;
	    highest     = 0.0;

	    while( inIdx <= endIdx )
	    {
		tempReal = inReal[inIdx];

		if( highestIdx < trailingIdx )
		{
		    highestIdx = trailingIdx;
		    highest = inReal[highestIdx];
		    i = highestIdx;
		    while( ++i<=inIdx )
		    {
			tempReal = inReal[i];
			if( tempReal > highest )
			{
			    highestIdx = i;
			    highest = tempReal;
			}
		    }
		}
		else if( tempReal >= highest )
		{
		    highestIdx = inIdx;
		    highest    = tempReal;
		}


		outDD[outIdx++] = (highest - inReal[inIdx]) / highest;
		trailingIdx++;
		inIdx++;  
	    }

	    /* Set output limits. */
	    VALUE_HANDLE_DEREF(outNBElement) = outIdx;
	    VALUE_HANDLE_DEREF(outBegIdx)    = startIdx;

	}
    }

    DD_LH {
	hint {Drawdown}
	tags {Drawdown}
	note {

	    ==Wikipedia==

	    The Drawdown is the measure of the decline from a historical peak in some variable 
	    (typically the cumulative profit or total open equity of a financial trading strategy).

	    The Maximum Drawdown (MDD) up to time T is the maximum of the Drawdown over the 
	    history of the variable.

	    ==Investopedia==

	    The peak-to-trough decline during a specific record period of an investment, 
	    fund or commodity. A drawdown is usually quoted as the percentage between the peak 
	    and the trough.

	}
	args {
	    int     startIdx
	    int     endIdx
	    double* inLow
	    double* inHigh
	    int     optInTimePeriod
	    int*    outBegIdx
	    int*    outNBElement
	    double* outDD
	}
	tcl_init {
	    
	    set size [llength $inLow]

	    set startIdx [::util::coalesce $startIdx 0]
	    set endIdx [::util::coalesce $endIdx [expr { $size - 1}]]
	    set optInTimePeriod [::util::coalesce $optInTimePeriod 14]
	    set outDD [lrepeat $size 0.0]

	}
	c_init {

	    double highest, tempReal, maxDrawdown;
	    int i, inIdx, trailingIdx, outIdx, highestIdx, maxDrawdownIdx;

	    /* Identify the minimum number of price bar needed
	     * to calculate at least one output.
	     */
	    int lookbackTotal;
	    lookbackTotal = (optInTimePeriod-1);

	    /* Move up the start index if there is not
	     * enough initial data.
	     */
	    if( startIdx < lookbackTotal )
	    {
		startIdx = lookbackTotal;
	    }

	    /* Make sure there is still something to evaluate. */
	    if( startIdx > endIdx )
	    {
		VALUE_HANDLE_DEREF_TO_ZERO(outBegIdx);
		VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
		return ENUM_VALUE(RetCode,TA_SUCCESS,Success);
	    }
	    

	}
	code {


	    /* Proceed with the calculation for the requested range.
	    * Note that this algorithm allows the input and
	    * output to be the same buffer.
	    */
	    outIdx = 0;
	    inIdx          = startIdx;
	    trailingIdx    = startIdx-lookbackTotal;
	    highestIdx     = -1;
	    highest        = 0.0;

	    while( inIdx <= endIdx )
	    {
		tempReal = inHigh[inIdx];

		if( highestIdx < trailingIdx )
		{
		    highestIdx = trailingIdx;
		    highest = inHigh[highestIdx];
		    i = highestIdx;
		    while( ++i<=inIdx )
		    {
			tempReal = inHigh[i];
			if( tempReal > highest )
			{
			    highestIdx = i;
			    highest = tempReal;
			}
		    }
		}
		else if( tempReal >= highest )
		{
		    highestIdx = inIdx;
		    highest    = tempReal;
		}

		outDD[outIdx++] = (highest - inLow[inIdx]) / highest;
		trailingIdx++;
		inIdx++;  
	    }

	    /* Set output limits. */
	    VALUE_HANDLE_DEREF(outNBElement) = outIdx;
	    VALUE_HANDLE_DEREF(outBegIdx)    = startIdx;

	}
    }


}

foreach {name config} $spec {


    set args ""
    set init ""
    set code ""
    dict with config {} ;# initializes the variables input,output,code


    # TODO: read the spec and template from a file

    define_cproc {*}[format {

	TA_CUSTOM_%s {
	    %s
	} {

	    # Initialization Code in TCL
	    %s

	} {

	    /* Initialization Code in C */
	    %s


	    /* Move up the start index if there is not enough initial data. */

	    if ( startIdx < lookbackTotal ) 
	    {
		startIdx = lookbackTotal;
	    }

	    
	    /* Make sure there is still something to evaluate. */

	    if( startIdx > endIdx )
	    {
		VALUE_HANDLE_DEREF_TO_ZERO(outBegIdx);
		VALUE_HANDLE_DEREF_TO_ZERO(outNBElement);
		return TCL_OK;
	    }


	    /* Calculate */    

	    %s
	    
	    return TCL_OK;
	}

    } ${name} ${args} ${tcl_init} ${c_init} ${code}]

}