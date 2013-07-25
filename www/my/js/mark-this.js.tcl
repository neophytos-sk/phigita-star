set js {

    var lsComplete = false;

    (function() {
	window.onerror = function() {if (!lsComplete) {d=document;it=window.open('http://www.phigita.net/my/linklog/url-add?title='+escape(d.title)+'&url='+escape(d.location.href)+'&r='+escape(d.referrer)+'&snippet='+escape(document.selection?(document.selection.type!='None'?document.selection.createRange().text:''):''),'_blank','width=475,height=575,left=75,top=20,resizable=yes');it.focus();lsComplete=true;}};
	var d = window.document;
	var c = d.selection;
	var f = window.open('','_blank','width=475,height=575,left=75,top=20,resizable=yes');
	var fd = f.document;
	fd.write('<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/></head><body>'+
		 '<form name=\'mf\' action=\'http://www.phigita.net/my/linklog/url-add\' method=\'post\'>'+
		 '<textarea style=\'visibility:hidden\' name=\'s\'></textarea>'+
		 '<br/><br/><br/><br/><center><b>Please wait. Sending page to phigita.net...</b></center><br/>'+
		 '<textarea style=\'visibility:hidden\' cols=\'0\' rows=\'0\' name=\'title\'></textarea>'+
		 '<input type=\'hidden\' name=\'url\' value=\'\'>'+
		 '<input type=\'hidden\' name=\'r\' value=\'\'>'+
		 '<textarea style=\'visibility:hidden\' cols=\'0\' rows=\'0\' name=\'snippet\'></textarea>'+
		 '<input type=\'hidden\' name=\'p\' value=\'0\'>'+
		 '<input type=\'hidden\' name=\'fromComplete\' value=\'1\'>'+
		 '</form></body></html>');
//	fd.mf.s.value = d.documentElement.outerHTML;
	fd.mf.title.value = d.title;
	fd.mf.url.value = d.location.href;
	fd.mf.r.value = d.referrer;
	fd.mf.snippet.value = c?(c.type!='None'?c.createRange().text:''):'';
	fd.mf.submit();
	f.focus();
	lsComplete = true;
    })();
}

doc_return 200 text/javascript ${js}