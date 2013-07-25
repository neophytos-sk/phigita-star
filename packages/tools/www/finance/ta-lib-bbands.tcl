set libdir [acs_root_dir]/packages/tools/lib/
source [file join $libdir critcl/tcl/module-critcl-ext.tcl]
#source [file dirname [ad_conn file]]/module-critcl-utils.tcl
source [file dirname [ad_conn file]]/module-ta-lib.tcl
#source [file dirname [ad_conn file]]/module-ystockquote.tcl



set inReal {
    128.20
    140.00
    135.70
    143.70
    119.22
    117.70
    142.80
    125.70
    141.68
    131.95
    122.85
    128.60
    140.95
    138.60
    113.11
    112.00
    149.05
    135.50
    138.25
    141.55
    137.95
    137.85
    114.75
    149.80
    119.65
    134.10
    137.50
    128.75
    139.00
    137.75
    114.70
    151.60
    123.50
    135.80
    134.50
    129.00
    137.90
    115.00
    124.30
    137.10
    133.70
    121.75
    126.40
    142.45
    136.80
    112.80
    126.10
    135.45
    137.98
    120.50
    140.85
    138.85
    134.70
    114.80
    113.82
    150.60
    123.20
    136.05
    139.22
    124.80
    142.00
    139.35
    114.95
    114.70
    149.30
    138.25
    134.34
    139.50
    129.65
    126.95
    139.90
    139.85
    113.20
    119.00
    148.00
    138.85
    140.30
    127.90
    140.00
    141.65
    135.60
    122.05
    147.00
    127.45
    135.15
    140.40
    127.00
    142.40
    137.30
    119.95
    148.20
    122.40
    134.00
    134.20
    128.80
    143.05
    135.35
    115.98
    118.80
    145.75
    135.57
    138.36
    127.50
    131.40
    135.95
    112.71
    118.90
    134.60
    133.55
    126.90
    131.50
    141.60
    135.25
    113.65
    113.80
    134.90
    139.90
    125.65
    142.40
    141.20
    135.50
    114.90
    119.13
    147.90
    115.50
    139.50
    141.34
    122.65
    142.70
    140.00
    117.10
    117.80
    148.50
    136.70
    137.50
    142.72
    122.50
    131.05
    142.15
    141.00
    120.25
    119.32
    148.55
    136.65
    142.93
    133.98
    142.15
    142.30
    133.50
    147.20
    139.00
    142.39
    133.40
    141.45
    134.85
    115.25
    146.70
    117.80
    137.70
    136.40
    125.45
    133.40
    134.80
    120.00
    118.50
    137.56
    137.80
    123.35
    132.80
    142.15
    132.60
    118.55
    117.20
    138.25
    142.67
    124.80
    143.80
    134.55
    119.05
    117.60
    116.00
    138.95
    142.01
    125.10
    125.05
    140.25
    134.50
    113.64
    113.00
    148.00
    134.20
    130.30
    124.70
    143.45
    122.15
    117.20
    116.40
    137.10
    134.55
    140.47
    143.70
    122.10
    122.75
    125.30
    142.40
    139.30
    143.30
    112.50
    147.60
    136.00
    133.25
    124.10
    139.20
    143.10
    112.60
    147.65
    127.40
    137.45
    140.05
    125.85
    124.45
    142.50
    116.25
    127.45
    135.80
    139.85
    124.10
    127.85
    141.05
    138.80
    114.45
    121.25
    137.31
    134.50
    125.70
    139.90
    139.25
    137.00
    112.34
    113.10
    148.15
    120.00
    134.60
    136.80
    122.85
    141.78
    138.25
    114.82
    114.35
    148.40
    137.95
    132.99
    138.35
}

set MATypes [list 0 "SMA" 1 "EMA" 2 "WMA" 3 "DEMA" 4 "TEMA" 5 "TRIMA" 6 "KAMA" 7 "MAMA" 8 "T3"]
set optInTimePeriod 20 ;# From 2 to 100000
set optInNbDevUp "2"    ;# deviation multiplier for upper band
set optInNbDevDown "2"  ;# deviation multiplier for lower band
foreach {optInMAType indicator} $MATypes  {
    ta_BBANDS inReal $optInTimePeriod $optInNbDevUp $optInNbDevDown $optInMAType outBegIdx outNBElement outRealUpperBand outRealMiddleBand outRealLowerBand
    set lastIdx [expr { $outNBElement - 1 }]
    append result "\n\nBB(${indicator},$optInTimePeriod,$optInNbDevUp,$optInNbDevDown) -  MAKE SURE THAT THE VALUES WE GET ARE CORRECT \n\noutBegIdx=$outBegIdx \n outNBElement=$outNBElement \n outRealUpperBand=$outRealUpperBand \n upperBB($indicator,$optInTimePeriod) = lrange outRealUpperBand 0 $lastIdx = [lrange $outRealUpperBand 0 $lastIdx] \n middleBB($indicator,$optInTimePeriod) = lrange outRealMiddleBand 0 $lastIdx = [lrange $outRealMiddleBand 0 $lastIdx] \n lowerBB($indicator,$optInTimePeriod) = lrange outRealLowerBand 0 $lastIdx = [lrange $outRealLowerBand 0 $lastIdx]"
}


set inReal {
    103.13
    109.00
    103.06
    102.75
    108.00
    107.56
    105.25
    107.69
    108.63
    107.00
    109.00
    110.00
    112.75
    113.50
    114.25
    115.25
    121.50
    126.88
    122.50
    119.00
    122.50
    118.00
    122.00
    121.19
    123.63
    122.75
    123.13
    122.13
    119.00
    112.69
    110.63
}





set ma_type SMA
set optInMAType 0 ;# stands for SMA, i.e. Simple Moving Average
set optInTimePeriod 20
set optInNbDevUp "2"    ;# deviation multiplier for upper band
set optInNbDevDown "2"  ;# deviation multiplier for lower band
ta_BBANDS inReal $optInTimePeriod $optInNbDevUp $optInNbDevDown $optInMAType outBegIdx outNBElement outRealUpperBand outRealMiddleBand outRealLowerBand
set lastIdx [expr { $outNBElement - 1 }]

append result "\n\nBB(${ma_type},$optInTimePeriod,$optInNbDevUp,$optInNbDevDown) -  SEEMS TO BE CORRECT/OK/CHECKED \n\noutBegIdx=$outBegIdx \n outNBElement=$outNBElement \n outRealUpperBand=$outRealUpperBand \n upperBB($ma_type,$optInTimePeriod) = lrange outRealUpperBand 0 $lastIdx = [lrange $outRealUpperBand 0 $lastIdx] \n middleBB($ma_type,$optInTimePeriod) = lrange outRealMiddleBand 0 $lastIdx = [lrange $outRealMiddleBand 0 $lastIdx] \n lowerBB($ma_type,$optInTimePeriod) = lrange outRealLowerBand 0 $lastIdx = [lrange $outRealLowerBand 0 $lastIdx]"


append result "\n\nCHECKED FOR CORRECTNESS AGAINST: http://stockcharts.com/school/doku.php?id=chart_school:technical_ma_types:bollinger_bands"


doc_return 200 text/plain "DONE\n\n$result"

