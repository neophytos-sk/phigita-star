

    $ = function(id) {
	return document.getElementById(id);
    }

var BM = {};

// Not quite sure but encodeURIComponent not needed here.
// Ensure that asyncRequest/XmlHttpRequest already takes care of that.
BM.serialize = function(obj) {
    var str = [];
    for(var p in obj) {
	if (xo.isArray(obj[p])) {
	    for(var i=0;i<obj[p].length;i++) {
		str.push(p + "=" + obj[p][i]);
	    }
	} else {
	    str.push(p + "=" + obj[p]);
	}
    }

    return str.join("&");
}


BM.reqFailure = function(o) {
    if (window['console']) 
	console.log("asyncRequest failure: " + o.tId + ": " + o.statusText);
}
BM.reqSuccess = function(o) {

    var data = xo.decode(o.responseText);

    var status = data['status'];
    var sMsg = data['message'];

    if (status=='ok') {
	display(sMsg);
	var btnEl = $('sb');
	btnEl.disabled=false;
	//window.setTimeout("CloseSidebar()",1000);
	var frm = document.forms[0];
	frm['edit_p'].value=1;
	btnEl.innerHTML = "Edit";
	window.setTimeout("HideMessage()",2000);
    } else {
	display(o.responseText);
	window.setTimeout("HideMessage()",2000);
    }
}

    HandleCapture = function(el) {
	if (!el.capture_p) { 
	    parent.postMessage('_reMark.capture()','*');
	    el.capture_p = 1;
	    el.innerHTML='Stop Capture';
	} else {
	    parent.postMessage('_reMark.stopCapture()','*');
	    el.capture_p = 0;
	    el.innerHTML='Capture Images';
	}
	return false;
    }

    var attachments=new Array();
    AttachMedia = function(mediaType,mediaUrl,imgOk,imgSha1,imgWidth,imgHeight) {
	attachments.push({"type":mediaType,"url":mediaUrl,"hash":imgSha1,"width":imgWidth,"height":imgHeight});
	var divEl = $('attachments');
	var imgEl = document.createElement('img');
	imgEl.src = '//static.phigita.net/video-img/'+imgSha1;
	imgEl.width = imgWidth;
	imgEl.height= imgHeight;
	var imgDivEl = document.createElement('div');
	imgDivEl.setAttribute('class','attachone');
	divEl.appendChild(imgDivEl);
	imgDivEl.appendChild(imgEl);
    }

    function CloseSidebar() {
	parent.postMessage('_reMark.close()','*');
	return false;
    };


    function display (msg) {
        var errMsgDiv = $("errMsgDiv");
	errMsgDiv.innerHTML=msg;
	errMsgDiv.style.display='inline';
    }

    function HideMessage () {
        var errMsgDiv = $("errMsgDiv");
	errMsgDiv.style.display='none';
	errMsgDiv.innerHTML="";
	
    }

    function getValue(formObj) {
	var value;
	if (formObj.options) { // select
	    if (formObj.selectedIndex > -1)
	    value = formObj.options[formObj.selectedIndex].value
	} else {
	    if (formObj.length) { // radio
		for (var b = 0; b < formObj.length; b++)
		if (formObj[b].checked)
		value = formObj[b].value
	    } else if (formObj.checked) { // checkbox
		value = formObj.value;
	    }
	}
	return value;
    }
    
    function nvl (v1,v2) {
	return (v1==null || v1==undefined)?v2:v1;
    }


BM.saveURL = function() {

    if (!BM.__pageData) return;
    var pageData = BM.__pageData;

    // xo.log(pageData);

    $('sb').disabled=true;

    var frm = document.forms[0];
    var v_edit_p = nvl(frm['edit_p'].value,'0');
    // var v_feed = escape(frm['feed'].value);
    var v_url        = encodeURIComponent(frm['url'].value);
    var v_title      = encodeURIComponent(frm['title'].value);
    var v_description= encodeURIComponent(frm['description'].value);
    var v_shared_p  = getValue(frm['shared_p']);
    var v_favorite_p = nvl(getValue(frm['favorite_p']),'f');
    var v_sticky_p = nvl(getValue(frm['sticky_p']),'f');
    var v_subscribe_p = nvl(getValue(frm['subscribe_p']),'f');
    var v_cache_p = nvl(getValue(frm['cache_p']),'f');
    var v_adult_p = nvl(getValue(frm['adult_p']),'f');
    var v_snippet = '';
    var v_interesting_p = 'f';
    var v_unread_p = 'f';
    var v_label        = encodeURIComponent(frm['label'].value);

    if (v_title==null || v_title.replace(/^\s*|\s*$/g,"")=='') {
	$("sb").disabled=false;
	display("You must specify something for title.");
	window.setTimeout("HideMessage()",5000);
	return
    }
    if (document.forms[0].description.value.length>512) {
	$("sb").disabled=false;
	display("Note is too long (max. 512 chars).");
	window.setTimeout("HideMessage()",5000);
	return
    }


    var url = "one-create";
    var data = {
	"url":v_url,
	"title":v_title,
	"description":v_description,
	"shared_p": v_shared_p,
	"favorite_p": v_favorite_p,
	"sticky_p": v_sticky_p,
        "subscribe_p": v_subscribe_p,
        "cache_p": v_cache_p,
        "adult_p": v_adult_p,
	"edit_p": v_edit_p,
	"snippet": v_snippet,
	"interesting_p": v_interesting_p,
	"unread_p": v_unread_p,
	"label": v_label,
        "referrer": pageData['referrer'],
	"feed": pageData['feeds']
    };

    if (pageData["outerHTML"] && pageData["outerHTML"].length < 100000) {
	data["outerHTML"] = pageData["outerHTML"];
    }

    var postData = BM.serialize(data); // converts js object to query data
    for(var i=0;i<attachments.length;i++) 
    {
	var mediaType=attachments[i].type;
	var mediaUrl =attachments[i].url;
	var imgSha1  =attachments[i].hash;
	var imgWidth =attachments[i].width;
	var imgHeight=attachments[i].height;
	postData += "&attach="+encodeURIComponent(mediaType)+'+'+encodeURIComponent(mediaUrl)+'+'+encodeURIComponent(imgSha1)+'+'+encodeURIComponent(imgWidth)+'+'+encodeURIComponent(imgHeight);
    }


/*
    for(var i=0;i<pageData['feeds'].length;i++) {
	postData += "&feed=" + pageData['feeds'][i];
    }
*/

    //(document.forms[0].label)
    //      var labelmap=$("labelmap").getElementsByTagName("input");
    //      if (labelmap.length) {
    //          var i=0;
    //          while (labelmap[i]) {
    //	    url += "&label="+labelmap[i].value;
    //	    i++;
    //         }
    //      }
    
    // myxmlhttp = CreateXmlHttpReq(CreateBookmarkXmlHttpHandler);
    // XmlHttpPOST(myxmlhttp, url,data);

    // xo.log(postData);
    var postUrl = "one-create";
    xo.Ajax.asyncRequest(postUrl,{"success":BM.reqSuccess,"failure":BM.reqFailure},postData);
    
}



BM.init = function(config) {
    document.forms[0].title.focus();
    parent.postMessage('_reMark.collectData()','*');
}

BM.refreshData = function(data) {
    // xo.log('processData / sidebar-url-add');
    // xo.log(data);

    BM.__pageData = data;

}

function receiveMessage(event) {

    // IMPORTANT: Make sure we restrict calls
    // to refreshData. Cannot restrict calls 
    // by event.origin as the bookmarked page
    // could be on any domain.

    var data = xo.decode(event.data);

    if (data['callback']=='refreshData') {
	BM.refreshData(data['args']);
    }
}

BM.handleKeyUp = function(e) {
    if (e.keyCode && e.keyCode==27) {
	CloseSidebar();
    }
}

xo.Event.on(window,"message",receiveMessage);
xo.Event.on(document,'keyup', BM.handleKeyUp)





window['display']=display;
window['HideMessage']=HideMessage;
window['CloseSidebar']=CloseSidebar;
window['AM']=AttachMedia;
window['HandleCapture']=HandleCapture;

xo.exportSymbol('BM',BM);
xo.exportProperty(BM,'init',BM.init);
xo.exportProperty(BM,'saveURL',BM.saveURL);


