set js {
    var v_url=escape(window.opener.location.href);
    var v_title=escape(window.opener.document.title);
    var v_referrer=escape(window.opener.document.referrer);
    var v_txt;
    if (window.getSelection) { 
	v_txt=window.opener.getSelection(); 
    } else if (document.getSelection) { 
	v_txt = window.opener.getSelection(); 
    } else if (document.selection) { 
	v_txt = window.opener.document.selection.createRange().text; 
    }
    v_txt =escape(v_txt.toString().replace(new RegExp('([\\f\\n\\r\\t\\v ])+', 'g'),' ').substring(0,511));
    

    var v_Lt=window.opener.document.getElementsByTagName('link');
    var v_feed='';
    for (var i=0; i< v_Lt.length; i++) {
	if ((v_Lt[i].getAttribute('rel') == 'alternate') && ((v_Lt[i].getAttribute('type') == 'application/rss+xml')||(v_Lt[i].getAttribute('type') == 'application/atom+xml'))) {
	    v_feed = v_Lt[i].getAttribute('href');
	    break;
	}
    }
}

if {[ad_conn user_id]} {
    append js {
	top.location.href="http://www.phigita.net/my/linklog/url-add?" +
	    "&url=" + v_url +
	    "&title=" + v_title +
	    "&snippet=" + v_txt +
	    "&feed=" + v_feed +
	    "&referrer=" + v_referrer;
    }
} else {
    append js {
	top.location.href="http://www.phigita.net/accounts/?return_url="+
	    escape("http://www.phigita.net/my/linklog/url-add?" + 
		   "&url=" + v_url + 
		   "&title=" + v_title + 
		   "&snippet=" + v_txt +
		   "&feed=" + v_feed +
		   "&referrer=" + v_referrer);

    }
}

doc_return 200 text/javascript ${js}