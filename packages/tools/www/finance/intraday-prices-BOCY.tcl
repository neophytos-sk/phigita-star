::xo::lib::require stockquote

::ext::StockQuote::get_intraday_prices_if metadata data CSE CSE 2010-02-01


set data [::xo::fun::filter $data row { 
    [lindex $row 1] eq {BOCY}
}]

# stock intraday quotes seem to be delayed (last month's only)
::ext::StockQuote::get_intraday_prices metadata data CSE BOCY 2010-03-23

doc_return 200 text/plain "$metadata \n [join $data \n]"