var sfpointer;
var sfside;

//Set values for the bookmark addition page
var sf_url=location.href;
var sf_description=document.title; 
var logo = 'http://www.phigita.net/graphics/logo.png';
var bookmarklet_height = 35;
var bookmarklet_width = 173;
//Turn debugging on or off.
var sfdebug = 0;
var mapcount = 0;

// X offset from mouse position
var offX = 15;

// Y offset from mouse position
var offY = 15;


(function(){
    function _b_dsc(obj) { var names = ""; for (var name in obj) names += name + " \n"; return names; } ; function _b_dmp(obj) { var names = ""; for (var name in obj) { try { names += name + ":" + ( (obj[name] == null) ? "nil" : obj[name].toString() ) + " \n"; } catch (e) { names += name + ":ER \n"; } } return names; } ;
    var _reMark = (typeof(_reMark) == 'undefined') ? {} : _reMark;
    _reMark.vh = "javascript:void(null);";


    var _long_url = document.location.href;
    if (_long_url.indexOf("#") == -1 && document.location.hash ) {
	_long_url = _long_url + document.location.hash;
    }
    
    // _reMark.url = document.URL
    _reMark.url = _long_url;
    _reMark.share_title = document.title;


    _reMark.setAttribute = function(e, k, v) {
	if (k == "class") {
	    e.setAttribute("className", v); // set both "class" and "className"
	}
	return e.setAttribute(k, v);
    };
    _reMark.createElement = function(e, attrs) {
	var el = document.createElement(e);
	for (var k in attrs) {
	    if (k == "text") {
		el.appendChild(document.createTextNode(attrs[k]));
	    } else {
		_reMark.setAttribute(el, k, attrs[k]);
	    }
	}
	return el;
    };
    _reMark.remove = function(e) {
	e.parentNode.removeChild(e);
    };

/*
_reMark.listen = function(elem, evnt, func) {
if (elem.addEventListener) // W3C DOM
elem.addEventListener(evnt,func,false);
else if (elem.attachEvent) { // IE DOM
var r = elem.attachEvent("on"+evnt, func);
return r;
}
};
*/

    _reMark.loadScript = function(_src) {
	var e = document.createElement('script');
	e.setAttribute('language','javascript');
	e.setAttribute('type', 'text/javascript');
	e.setAttribute('src',_src); document.body.appendChild(e);
    };
    _reMark.loadCss = function(u) {
	var e = document.createElement('link');
	e.setAttribute('type', 'text/css');
	e.setAttribute('href', u);
	e.setAttribute('rel', 'stylesheet');
	e.setAttribute('media', 'screen');
	try {
	    document.getElementsByTagName('head')[0].appendChild(e);
	} catch(z) {
	    document.body.appendChild(e);
	}
    };
    _reMark.close = function() {
	var overlay = document.getElementById('_b_overlay');
	if (overlay != undefined) {
	    _reMark.remove(overlay);
	}
	if (_reMark.timeout_handle != undefined) {
	    clearTimeout(_reMark.timeout_handle);
	}
    };
    
    _reMark.keyup = function(e) {
	if (e.keyCode && e.keyCode==27) {
	    _reMark.close();
	}
    }
    _reMark.getSelection = function() {
	var selection;
	if (window.getSelection) {
	    selection = window.getSelection();
	} else if (document.getSelection) {
	    selection = document.getSelection();
	} else if (document.selection) {
	    selection = document.selection.createRange().text;
	}
	if (!selection) {
	    selection = '';
	}
	return selection;
    };
    _reMark.drawOverlay = function() {
	_reMark.url = (typeof _reMark.url == 'undefined') ? document.URL : _reMark.url; // allow this to be parameterized
	_reMark.close();
	var overlay = _reMark.createElement('div');
	overlay.id = '_b_overlay';
	var content = _reMark.createElement('div', {"id": "_b_content"});
	// var header = _reMark.createElement('div', {"id":"_b_header"});
	// content.appendChild(header);
	var closeBtn = _reMark.createElement('a', {"text": "x", "id": "_b_close", "href":_reMark.vh, "title": "Close sidebar"});
	xo.Event.on(closeBtn, 'click', _reMark.close);
	xo.Event.on(document, 'keyup', _reMark.keyup);
	content.appendChild(closeBtn);
	var selection = _reMark.getSelection();
	var pars = [
	    ["u", _reMark.url],
	    ["t", _reMark.share_title]
	];
	if (selection != '') {
	    pars.push(["s", selection]); // only do this if there's a selection or we're using the bookmarklet on a landing page
	}
	for (var i=0; i < pars.length; i++) {
	    pars[i] = pars[i][0]+"="+encodeURIComponent(pars[i][1]);
	};
	/*
	  IE appears to be case sensitive to iframes. use caution. Known issues: frameBorder, allowTransparency
	*/
	var src = "https://my.phigita.net/bookmarks/sidebar?" + pars.join("&");
	//var src = "http://localhost:8090/my/bookmarks/sidebar?" + pars.join("&");
	var iframe = _reMark.createElement('iframe', {"id": "_b_iframe", "name": "_b_iframe", "src": src, "allowTransparency": "true", "frameBorder" : 0 });
	//iframe.style.display="none"
	content.appendChild(iframe);
	overlay.appendChild(content);
	// animate it?
	document.body.appendChild(overlay);
    };
    _reMark.attach = function(imageUrl) {
	var iframeEl = document.createElement('iframe');
	iframeEl.id = '_reMark_'+(new Date()).getTime();
	iframeEl.src = "https://my.phigita.net/bookmarks/sidebar-attach?t=image&u="+encodeURIComponent(imageUrl);
	iframeEl.width = 0;
	iframeEl.height = 0;
	setTimeout("_reMark.remove(document.getElementById('"+iframeEl.id+"'));",5000);
	document.body.appendChild(iframeEl);
    };
    
    _reMark.collectData = function() {

	// TODO: strip bookmarklet script element(s) from the end of the body tag
	var outerHTML = (document.head?document.head.outerHTML:'')+(document.body?document.body.outerHTML:'');


	// og stands for opengraph
	var data = {
	    'long_url': _reMark.url,
	    'share_title': _reMark.share_title,
	    'referrer': document.referrer,
	    'outerHTML': outerHTML,
	    'feeds':[],
	    'og':{}
	};

	var feeds = document.getElementsByTagName('link');
	for(var i=0;i<feeds.length;i++) {
	    var type = feeds[i].getAttribute('type');
	    if (type=='application/rss+xml' || type=='application/atom+xml') {
		var href = feeds[i].getAttribute('href');
		// data['feeds'].push({'type':type,'href':href});
		data['feeds'].push(href);
	    }
	}


	var metaEls = document.getElementsByTagName('meta');
	for(var i=0;i<metaEls.length;i++) {
	    if (metaEls[i].hasAttribute('property')) {
		var property = metaEls[i].getAttribute('property');
		var property_parts = property.split(':');
		if (property_parts.length && property_parts[0] == 'og') {
		    var content = metaEls[i].getAttribute('content');
		    data['og'][property_parts[1]] = content;
		}
	    }
	}

	// TODO: DESTROY ALL LISTENERS WHEN RELOADING/LEAVING PAGE
	var iframeEl = document.getElementById('_b_iframe');

	var message=xo.encode({'callback':'refreshData','args':data});
	iframeEl.contentWindow.postMessage(message,'*');
    };

    _reMark.stopEvent = function(ev) {

        ev = ev.browserEvent || ev;
        if (ev.stopPropagation) {
            ev.stopPropagation();
        } else {
            ev.cancelBubble = true;
        }

        if(ev.preventDefault) {
            ev.preventDefault();
        } else {
            ev.returnValue = false;
        }
    };

_reMark.stopCapture = function() {
    try {
	document.onmousemove=document._old_onmousemove;
	_reMark.remove(sfpointer);
	sfpointer=null;
	_reMark.remove(sfside);
	sfside=null;

	//Enable links.
	var linkEl;
	for (var a=0; a < document.links.length; a++) {	
	    linkEl=document.links[a];
	    linkEl.onmousedown=linkEl._old_onmousedown;
	    linkEl.onclick=linkEl._old_onclick;
	} 

	//Enable forms.
        var formEl;
	for (var f=0; f < document.forms.length; f++ ) {
	    formEl=document.forms[f];
            formEl.onsubmit=formEl._old_onsubmit;
	}

	var imgEl;
	for (var i=0; i < document.images.length; i++) {
	  imgEl=document.images[i];
          imgEl.onmouseover = imgEl._old_onmouseover;
	  imgEl.onmouseout = imgEl._old_onmouseout;
          imgEl.onmousedown = imgEl._old_onmousedown;
          imgEl.onclick = imgEl._old_onclick;
        }
        document.body.style.cursor='default';
    } catch(ex) {
	// xo.log(ex);
    }
};

//_reMark.loadCss('http://www.phigita.net/bookmarklet/sidebar.css');
_reMark.drawOverlay();


    
//Failsafe function: if an exception occurs, try to run this.
function failsafe(err) {
    //xo.log('Failsafe running');
    var loc = "https://my.phigita.net/bookmarks/url-add?url=" +encodeURIComponent(sf_url)+ "&description=" +encodeURIComponent(sf_description);
    if (err != null) {
	loc += "&exception=" + err;
    }
    //document.location = loc;
}



//Get the area of the visible window.
function getArea() {
    var frameWidth, frameHeight = 0;
    
    if (self.innerWidth) {
	frameWidth = self.innerWidth;
	frameHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientWidth) {
	frameWidth = document.documentElement.clientWidth;
	frameHeight = document.documentElement.clientHeight;
    } else if (document.body) {
	frameWidth = document.body.clientWidth;
	frameHeight = document.body.clientHeight;
    }
    
    // xo.log("Screen dimensions: " + frameWidth + " by " + frameHeight);

    //Add in 1 there so we don't have stupid divide by 0 errors in odd cases.
    return 1 + frameWidth * frameHeight;
}

function mouseX(evt) {
    if (!evt) evt = window.event; 
    if (evt.pageX) 
	return evt.pageX; 
    else if (evt.clientX)
	return evt.clientX + (document.documentElement.scrollLeft ?  document.documentElement.scrollLeft : document.body.scrollLeft); 
    else 
	return 0;
}

function mouseY(evt) {
    if (!evt)
	evt = window.event; 
    if (evt.pageY) 
	return evt.pageY; 
    else if (evt.clientY)
	return evt.clientY + (document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop); 
    else 
	return 0;
}



_reMark.capture = function() {
    try {

	//If there are frames, just forget it.
	/*
	  if (window.frames.length > 1) {
	  xo.log("Frames detected.");
	  failsafe();
	  }
	*/

	//Switch cursor to crosshair and change mouse behaviour
	document.body.style.cursor='crosshair';
	document._old_onmousemove = document.onmousemove;
	document.onmousemove = follow;

	//See if there's any plugins on the page.
	var parea = 0;
	var embedsCounted = false;
	if (document.embeds) {
	    for (var p=0; p < document.embeds.length; p++ ) {
		//Get the height and width attributes.
		var x = document.embeds[p].width;
		var y = document.embeds[p].height;
		//xo.log("Plugin size: " + x + " by " + y);
		parea += (x * y);
		embedsCounted = true;
	    }
	}

	//Seems to work in MSIE.
	var objects = document.getElementsByTagName("object");
	if (!embedsCounted && objects != null) {
	    for (var z=0; z < objects.length; z++ ) {
		var x = objects[z].width;
		var y = objects[z].height;
		//xo.log("Object size: " + x + " by " + y);
		parea += (x * y);
	    }
	}

	//This is the ratio of plugin content to the browser size.
	var pratio = parea / getArea();

	//xo.log("Total plugin area: " + parea);
	//xo.log("Total screen size: " + getArea());
	//xo.log("Ratio: " + pratio);

	//If more than 40% of the screen is plugin content, we assume that there's no good 
	//thumbnail for the user to choose.  This is an arbitrary amount.
	if (pratio > 0.4) {
	    //xo.log("Too much plugin content...");
	    //failsafe();
	}

	//Disable the links.
	var linkEl;
	for (var a=0; a < document.links.length; a++) {	
	    linkEl=document.links[a];
	    linkEl._old_onmousedown=linkEl.onmousedown;
	    linkEl._old_onclick=linkEl.onclick;
	    linkEl.onmousedown=function (e) { _reMark.stopEvent(e); return false; }; 
	    linkEl.onclick=function (e) { _reMark.stopEvent(e); return false; }; 
	} 

	//Disable forms.
        var formEl;
	for (var f=0; f < document.forms.length; f++ ) {
	    formEl=document.forms[f];
            formEl._old_onsubmit=formEl.onsubmit;
	    formEl.onsubmit=function (e) { 
		alert("phigita: Cannot use that image - please choose another"); 
		return false;
	    };
	}



	//Special mouse-following message.
	sfpointer = document.createElement('div');
	sfpointer.id = 'sfpointer';
	sfpointer.style.visibility='visible';
	sfpointer.style.width='150px';
	sfpointer.style.height='50px';
	sfpointer.style.background="#FF6565";
	sfpointer.style.padding="0px";
	sfpointer.style.position='absolute';
	sfpointer.style.border='solid 1px black';
	sfpointer.style.font="bold 12px Arial, sans-serif";
	sfpointer.style.left='100px';
	sfpointer.style.top='100px';
	sfpointer.style.zIndex=99;
	sfpointer.innerHTML='Click on the picture you want to capture';

	document.body.appendChild(sfpointer);
	    
	//Change default handlers for images
	var imgEl;
	for (var i=0; i < document.images.length; i++) { 
	    imgEl=document.images[i];
	    //Click handler.
	    imgEl._old_onmousedown=imgEl.onmousedown;
	    imgEl.onmousedown = function (e) {  
		//xo.log('onmousedown event trapped');

		_reMark.attach(this.src);

		//document.location='http://localhost:8090/bookmarklet/index.html?url='+encodeURIComponent(sf_url)+'&description='+encodeURIComponent(sf_description)+'&thumbnailUrl='+encodeURIComponent(this.src); 
								
	    }

	    //When the mouse is over....
	    imgEl._old_onmouseover=imgEl.onmouseever;
	    imgEl.onmouseover = function (e) {

		// this.style.cursor = "default";
		//change the border to +1
		// as long as it isn't our logo
		if (this.src!=logo) {	
		    this.style.border = 'solid 2px red';}
	    }
	    imgEl._old_onmouseout=imgEl.onmouseout;
	    imgEl.onmouseout = function (e) {
		this.style.border = '0px';
	    }
	    imgEl._old_onclick=imgEl.onclick;
	    imgEl.onclick = undefined;
	}
	    
	//Special y-axis mouse-following menu
	sfside = document.createElement('div');
	xo.log(sfside);
	sfside.id = 'sfside';
	sfside.style.visibility='visible';
	sfside.style.width= bookmarklet_width + 'px';
	sfside.style.height= bookmarklet_height + 'px';
	sfside.style.background='#FFFFFF';
	sfside.style.padding='0px';
	sfside.style.position='absolute';
	sfside.style.border='solid 1px black';
	sfside.style.font='bold 12px Arial, sans-serif';
	sfside.style.left='0px';
	sfside.style.top='137px';
	sfside.style.zIndex=890;
	    
	sfside.innerHTML='<a href="javascript:failsafe()"><img border="0" src="' + logo + '"></a>';

	var sfLoc = document.createElement('div');
	sfLoc.id = '_reMark_Location';
	sfLoc.style.display = 'none';
	sfLoc.innerHTML = location.href;

	document.body.appendChild(sfside);
	document.body.appendChild(sfLoc);

	//	document.getElementById('_reMarkThumbnailUrl').innerHTML = recurseTree(document.body);
	recurseTree(document.body);

	//xo.log('Remote script processed');

    } catch (e) {
	//xo.log("Exception caught: " + e);
	failsafe("caught-exception");
    }
}


function recurseTree(element) {
    if ((element.nodeName.toUpperCase() == 'TD') | (element.nodeName.toUpperCase() == 'H1')  && element.style['backgroundImage']) {
	    
	element.onmouseover = function (e) {
	    this.style.border = 'solid 2px red';
	}
	    
	element.onmouseout = function (e) {
	    this.style.border = '0px';
	}
	    
	element.onmousedown = function (e) {
	    // regexp to look for the url css parameter
	    var re_url = /url\((.*)\)/g;
	    // loading the background image location
	    var bg_url = element.style['backgroundImage'];
	    // extract the location of the image
	    var image_url = bg_url.replace(re_url,'$1');
	    //xo.log(image_url);
		
	    // create regexp test to look for absolute path
	    var re_test_fqdn = /http/g;
		
	    // test to see if the absolute path was used
	    if (!image_url.match(re_test_fqdn)) {
		// relative pathing used
		// extract the server name from the sf_url variable
		var re_servername = /(^http:\/\/[a-zA-Z0-9_\-\.]+\/).*/g;
		    
		// extract the server name
		var fqdn = sf_url.replace(re_servername, '$1');
		//xo.log(fqdn);
		    
		// image location set to the server name and the image path
		image_url = fqdn + image_url;
		//xo.log(image_url);
	    }
	    // add the item to the user feed
		
		
		
	    alert('no!');
	    //document.location='http://localhost:8090/bookmarklet/index.html2?url='+encodeURIComponent(sf_url)+'&description='+encodeURIComponent(sf_description)+'&thumbnailUrl='+encodeURIComponent(image_url);
		
		
	}

    }


	
    if (element.nodeName.toUpperCase() == 'MAP') {
	for (var me=0; me < element.getElementsByTagName('AREA').length;me++) {
	    element.getElementsByTagName('AREA')[me].coords='0,0,0,0';
	}
    }
	
    if (element.childNodes) {
	for (var j=0; j < element.childNodes.length; j++) {
	    recurseTree(element.childNodes[j]);
	}
    } else {
	//xo.log(element);
    }

}


function follow(evt) {
    var xpos = (parseInt(mouseX(evt))+offX);
    var ypos = (parseInt(mouseY(evt))+offY);
	

    if (sfpointer != null) {
	sfpointer.style.left = xpos + 'px';  
	sfpointer.style.top  = ypos + 'px';
    }

    if (sfside != null) {
	if (xpos > (bookmarklet_width + 20)) {
	    sfside.style.top = ypos + 'px';
	} 
    }
	
}



window['_reMark']=_reMark;


_reMark.receiveMessage = function(event) {
    if (event.origin !== 'https://my.phigita.net') {
	return;
    }
    eval(event.data);
}


window['_reMark']=_reMark;

try {
  xo.Event.on(window,"message",_reMark.receiveMessage);
} catch(ex) {
  xo.log('caught error while trying to add event listener on window object');
  window.addEventListener("message",_reMark.receiveMessage); 
};
_reMark['capture']=_reMark.capture;
_reMark['close']=_reMark.close;
_reMark['stopCapture']=_reMark.stopCapture;
_reMark['collectData']=_reMark.collectData;

})();

