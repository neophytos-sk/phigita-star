guard { return [info exists @{selectedtab:varname}] }

val -id context_username { return [ad_conn context_username] }

val -id navigation_tabs {

    #set base "http://www.phigita.net/~@{context_username}" 
    set base "/~@{context_username}" 

    set extratab_blog_post ""
    set extratab_echo_post ""
    set extratab_wiki_post ""
    if { [info exists @{param.id:varname}] } {
	if { @{selectedtab} eq {blog-post}  } {
	    set extratab_blog_post [list [list blog-post "${base}/blog/@{param.id}" "&#9788;"]]
	} elseif { @{selectedtab} eq {echo-post}  } {
	    set extratab_echo_post [list [list echo-post "${base}/echo/@{param.id}" "&#9788;"]]
	} elseif { @{selectedtab} eq {wiki-post}  } {
	    set extratab_wiki_post [list [list wiki-post "${base}/wiki/@{param.id}" "&#9788;"]]
	} else {
	    error "unknown selectedtab in www-shared.tabs.inc"
	}
    }

    return [subst -nocommands -nobackslashes {
	{home "${base}/" "home"}
	{blog "${base}/blog/" "blog"}
	${extratab_blog_post}
	{echo "${base}/echo/" "echo"}
	${extratab_echo_post}
	{media "${base}/media/" "media"}
	{linklog ${base}/linklog/ "reMark"}
	{vox-pop ${base}/vox-pop/ "vox pop"}
	{wiki ${base}/wiki/ "wiki"}
	${extratab_wiki_post}
    }]

}

# -----------------------------------------------------------------

css {
    .tabs_head {
	background:#eee;
	border-bottom:2px solid #ccc;
	font-family:sans-serif;
	margin-bottom:1em;
	padding:3px;
    }
    .tabs {margin-top:10px;font-size:12px;}
    .tabs a {
	-moz-border-radius:0.7em 0.7em 0 0;
	-webkit-border-radius:0.7em 0.7em 0 0;
	border-radius:0.7em 0.7em 0 0;
	border-top:2px solid #ccc;
	border-left:2px solid #ccc;
	border-right:2px solid #ccc;
	line-height:2em;padding:3px;
	white-space:nowrap;
    }
    .tabs a {
	text-decoration:none;
	padding-bottom:0.7em;
	border-bottom:none;
	margin:1px;
	color:#77c;
    }
    .tabs .selectedtab {
	font-weight:bold;
	background:#fff;
	padding-bottom:0.9em;
	color:#000;
    }
}

div -class tabs_head {
    div -class tabs {
	tpl -for "navigation_tabs" {
	    tpl -if "@{val.selectedtab} eq @{_.0}" {
		a -class "selectedtab" -href @{_.1} { t @{_.2:noquote} }
	    }
	    tpl -else "" {
		a -href @{_.1} { t @{_.2} }
	    }
	}
    }
}
