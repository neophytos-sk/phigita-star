ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
    {return_url:trim .}
}

#source [acs_root_dir]/packages/core-platform/tcl/ttext/bte-procs.tcl

set o [::uri::Request new -url ${url}]


${o} volatile
${o} perform

set tt [::ttext::Worker new -volatile -init]
set tt1 [::ttext::Worker new -volatile -init]

set response_text [${tt} bte [${o} dom_obj]]

dom parse -keepEmpties -simple [regsub -all -- {\/\/[^\n]\n} [string tolower [encoding convertfrom utf-8 [$o set response_body]]] {}] doc
set root [${doc} documentElement]
$tt1 set maxf -100000000
$tt1 evaluateNode $root
set main_text [$tt1 getBody [$tt1 set maxNode]]

set o [::sw::agg::Url new -mixin ::db::Object -pool newsdb -set url $url -set last_crawl_content $main_text -volatile]
$o do self-update "url=[ns_dbquotevalue ${url}]"

[$o getConn] do "update xo.xo__news_in_greek set ts_vector=to_tsvector('[default_text_search_config]',(select coalesce(title,'') || coalesce(last_crawl_content,'') from xo.xo__sw__agg__url where url=[ns_dbquotevalue ${url}])) where url=[ns_dbquotevalue ${url}]"

ad_returnredirect $return_url