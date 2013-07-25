::xo::lib::require stockquote


# OLD: set error [get_historical_prices_if table IBM 2007-03-17 2010-03-31 datasource]

set error [::ext::StockQuote::get_historical_prices metadata data CSE BOCY 2007-03-17 2010-03-31]

doc_return 200 text/plain "error=$error metadata=[list $metadata]\n\nDATA\n\n[join $data \n]"


########## OLD OLD
return



set exchange CSE
set symbol BOCY
set start_date 2007-01-15
set end_date 2010-03-31
set error [get_historical_prices_if metadata table $exchange $symbol $start_date $end_date]

doc_return 200 text/plain "metadata=$metadata \n table=$table"