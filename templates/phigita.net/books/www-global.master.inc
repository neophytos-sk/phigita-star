set search_query ""
if { [info exists arg(search_query)] } {
    set search_query $arg(search_query)
}

js {
    function searchTheWeb(){
	var sf = document.getElementById('sf');
	sf.setAttribute('action','http://www.phigita.net/search/');
	sf.submit();
	return false;
    }
    window['searchTheWeb']=searchTheWeb;
}


master -src "/templates/phigita.net/site-master.inc" {

    slave

    div -x-master-renderTo "search-form" {
	form -id "sf" -action "http://books.phigita.net/" {
	    css {
		#q_proxy {height:16px;line-height:14px;}
	    }
	    div -class "input-append" {

		# master should have param 'q' in its contract 
		# or have it defined one way or another
		input \
		    -id q_proxy \
		    -name "q" \
		    -type "text" \
		    -style "width:350px;" \
		    -class "input-medium" \
		    -autocomplete "off" \
		    -value "$search_query"

		button -type "submit" -class "btn btn-mini" { t "Search Books" }
		button -type "submit" -class "btn btn-mini" -onclick "return searchTheWeb();" { t "Search the Web" }
	    }
	    div -id suggest_results
	}
    }

}

