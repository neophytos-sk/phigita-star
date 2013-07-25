::xo::lib::require stockquote

ad_page_contract {
    @author Neophytos Demetriou
} {
    symbol:trim,notnull
    {start_date:trim,notnull 2009-09-21}
    {end_date:trim,notnull 2010-09-27}
}



set error [::ext::StockQuote::get_historical_prices_if metadata data FX ${symbol} ${start_date} ${end_date}]

doc_return 200 text/plain "$metadata\n\n[join $data \n]"