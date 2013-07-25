tmpl::blank {
    h3 { t "NEW STUFF" }
    ul {
	li { a -href kelly { t "Kelly Criterion Calculator" } }
	li { a -href rank-by-wilson-score { t "Sort ratings by lower bound of Wilson score confidence interval " } }
	li { a -href quotes-get-historical-prices { t "Stock Quotes (historical prices from yahoo, symbol=IBM)" } }
	li { a -href quotes-google { t "Stock Quotes (historical prices from google, exchange=NYSE symbol=IBM)" } }
	li { a -href quotes-stockwatch { t "Stock Quotes (historical prices from stockwatch, symbol=BOCY)" } }
	li { a -href ta-lib-rocp { t "TA (after easter revision): ROCP" } }
	li { a -href gsl-polyfit { t "gsl_multifit_linear (gsl)" } }
	li { a -style "font-weight:bold;" -href ta-lib-multiple-func-2 { t "Technical Analysis (LATEST): Multiple TA Functions 2" } }
	li { a -href daily-prices-CSE { t "Daily Prices: CSE" } }
	li { a -href intraday-prices-BOCY { t "Intraday Prices: BOCY" } }
	li { a -href quantlib/test-1 { t "QuantLib: Test 1" } }
    }
    h3 { t "DATA" }
    ul {
	li { t "OANDA"
	    form -action fx-oanda-rate {
		input -type text -name symbol -value EURUSD -size 6 -maxlength 6
		input -type text -name start_date -value 2009-09-21 -size 10 -maxlength 10
		input -type text -name start_date -value 2010-09-27 -size 10 -maxlength 10
		input -type submit -value "Submit"
	    }
	}
    }
    h3 { t "OLD STUFF" }
    ul {
	li { a -href ta-lib-multiple-func { t "Technical Analysis: Multiple TA Funcs 1" } }
	li { a -href ta-lib-rsi { t "OLD - Technical Analysis: RSI" } }
	li { a -href ta-lib-ma { t "OLD - Technical Analysis (Moving Average): SMA,EMA,..." } }
	li { a -href ta-lib-bbands { t "OLD - Technical Analysis (Bollinger Bands): BB" } }
	li { a -href ta-lib-rsi-2 { t "TA & Historical Prices & Overbought/Oversold: RSI" } }
	li { a -href ta-lib-ma-2 { t "TA & Historical Prices & Crossovers: MA" } }
    }
}