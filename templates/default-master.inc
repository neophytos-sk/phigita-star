set search_query ""
if { [info exists arg(search_query)] } {
    set search_query $arg(search_query)
}


master -src "/templates/phigita.net/site-master.inc" {

    slave 

        div -x-master-renderTo "search-form" {

            form -action "http://www.phigita.net/search/" {

                div -class "input-append" {

                    input \
                        -id q_proxy \
                        -name "q" \
                        -value "${search_query}" \
                        -type "text" \
                        -style "width:350px" \
                        -autocomplete "off"

                    button -type "submit" -class "btn btn-mini" { t "Search" }

                }

            }

            css {
#suggest_results {position:absolute; z-index:999;background:#fcfcfc;border:1px solid #000;margin:0;padding:2px 5px;width:350px;display:none;}
#suggest_results div {text-align:left;}
#suggest_close {cursor:pointer;}
#q_proxy {height:14px;line-height:14px;}
                .selected {background:#6E95C2;color:white;cursor:pointer;}
                .has_results {background:#dde5F5 !important;}
                .suggest_title {overflow:hidden;height:16px;font-size:12px;color:#000;margin-top:4px;}
                .suggest_url {overflow:hidden;height:16px;font-size:10px;color:#999;}
                .selected .suggest_title {color:#fff;}
                .selected .suggest_url {color:#fff;}
            }

            js -deps {
                kernel/lib/base.js
                    kernel/lib/event.js
                    kernel/lib/DomHelper.js
                    kernel/lib/SearchBox2.js
            } -names {
                selected has_results suggest_url suggest_title
            } -tags {
                defer
            } {
                xo.onDocumentReady(function() {
                        SearchBox.init({'applyTo':'q_proxy','displayTo':'suggest_results'});
                        });
            }

            tpl -if @{val.registered_p} {
                div -id "suggest_results" {
                    div -id "suggest_close" -class "pull-right badge" { t "x" }
                }
            }
        }

}
