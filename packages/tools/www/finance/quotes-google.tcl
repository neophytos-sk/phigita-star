::xo::lib::require stockquote

set error [::ext::StockQuote::Google.get_historical_prices metadata data NYSE IBM 2007-03-17 2010-03-31]

doc_return 200 text/plain "error=$error metadata=[list $metadata]\n\nDATA\n\n[join $data \n]"
