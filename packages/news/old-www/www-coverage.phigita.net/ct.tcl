ad_page_contract {
    @author Neophytos Demetriou
} {
    {s:trim,notnull}
}

try {
    set connObject [DB_Connection new -pool newsdb]
    set url [$connObject getvalue "select url from xo.xo__sw__agg__url where url_sha1=[ns_dbquotevalue $s] limit 1"]

    ns_return 200 text/html [subst -nobackslashes -nocommands {
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="refresh" content="1;url=${url}">
	<title>news.phigita.net</title>
	<link rel="alternate" type="application/rss+xml" title="phigita.net News in Greek" href="http://news.phigita.net/?output=rss" />
	<script>
	<!--
var agt = navigator.userAgent.toLowerCase();
var is_ie = (agt.indexOf("msie") != -1);
var is_ie5 = (agt.indexOf("msie 5") != -1);
function CreateXmlHttpReq(handler) {
  var xmlhttp = null;
  if (is_ie) {
    var control = (is_ie5) ? "Microsoft.XMLHTTP" : "Msxml2.XMLHTTP";
    try {
      xmlhttp = new ActiveXObject(control);
      xmlhttp.onreadystatechange = handler;
    } catch (ex) {
	// do nothing
    }
  } else {
    xmlhttp = new XMLHttpRequest();
    xmlhttp.onload = handler;
    xmlhttp.onerror = handler;
  }
  return xmlhttp;
}
function XmlHttpGET(xmlhttp, url) {
  try {
    xmlhttp.open("GET", url, true);	
    xmlhttp.send(null);

  } catch (ex) {
    // do nothing
  }
}
function ctHandler() {
    setTimeout('top.location.href=\"${url}\"',1);
    return;
}
function ct() {
    try {
	var url = "ct-update?s=${s}&url=" + encodeURIComponent("${url}");
	myxmlhttp = CreateXmlHttpReq(ctHandler);
	XmlHttpGET(myxmlhttp, url);
    } catch (ex) {
	// do nothing
    }
}
	-->
	</script>
	</head>
        <body onload="ct();">
	Thank you for using <a title="News in Greek" href="http://news.phigita.net/">http://news.phigita.net/</a>. Redirecting...
	</body>
	</html>
    }]


set comment {
    if { [ad_conn user_id] } {
    $connObject do [subst {
	update xo.xo__sw__agg__url set
	    ctn_clickthroughs=cnt_clickthroughs+1
	   ,last_clickthrough=current_timestamp
	where
	url=[ns_dbquotevalue ${url}]
    }]
    }
}

} catch {*} {
    ns_log notice "IP=[ad_conn peeraddr] URL=$url Error: $trymsg"
} finally {
    $connObject destroy
} trymsg