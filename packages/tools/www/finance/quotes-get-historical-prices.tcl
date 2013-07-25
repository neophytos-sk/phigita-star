::xo::lib::require stockquote


#source [file dirname [ad_conn file]]/module-ystockquote.tcl


# OLD: set error [get_historical_prices_if table IBM 2007-03-17 2010-03-31 datasource]

set error [::ext::StockQuote::get_historical_prices_if metadata data NYSE IBM 2007-03-17 2010-03-31]

doc_return 200 text/plain "error=$error metadata=[list $metadata]\n\nDATA\n\n[join $data \n]"

#set data [lrange $table 1 end]
#set close [::xo::fun::map x $data { lindex $x 4 }]
#set new_data [linterleave $data $close]

#doc_return 200 text/plain "error=$error datasource=$datasource [join $new_data \n] table=$table"