


/*

Copyright 2005 - 2008, StyleFeeder, Inc..

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

//www.gnu.org/licenses/gpl.txt

TODO - 
+ add in more logging so that we can see what sites are failing.

Portions of this code are:

// Simple follow the mouse script
// copyright Stephen Chapman, 30th September 2005
// you may copy this script provided that you retain the copyright notice

*/

//Set values for the bookmark addition page
var sf_url=location.href;
var sf_description=document.title; 
var logo = '//www.stylefeeder.com/images/bookmarklet-logo-1.gif';
var bookmarklet_height = 115;
var bookmarklet_width = 200;
//Turn debugging on or off.
var sfdebug = 0;
var mapcount = 0;

// X offset from mouse position
var offX = 15;

// Y offset from mouse position
var offY = 15;


//Failsafe function: if an exception occurs, try to run this.
function failsafe(err) {
		sflog('Failsafe running');
		var loc = "//www.stylefeeder.com/bookmarklet/index.html?url=" +encodeURIComponent(sf_url)+ "&description=" +encodeURIComponent(sf_description);
		if (err != null) {
			loc += "&exception=" + err;
		}
		document.location = loc;
}

//Debugging function.
function sflog(m) {
	if (sfdebug == 1) {
		alert(m);
	}
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

	sflog("Screen dimensions: " + frameWidth + " by " + frameHeight);

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

//---------------------------------------------------------------------
// End function definitions.

try {

	//If there are frames, just forget it.
	/*
	if (window.frames.length > 1) {
		sflog("Frames detected.");
		failsafe();
	}
	*/

	//Switch cursor to crosshair and change mouse behaviour
	document.body.style.cursor='crosshair';
	document.onmousemove = follow;

	//See if there's any plugins on the page.
	var parea = 0;
	var embedsCounted = false;
	if (document.embeds) {
		for (var p=0; p < document.embeds.length; p++ ) {
			//Get the height and width attributes.
			var x = document.embeds[p].width;
			var y = document.embeds[p].height;
			sflog("Plugin size: " + x + " by " + y);
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
			sflog("Object size: " + x + " by " + y);
			parea += (x * y);
		}
	}

	//This is the ratio of plugin content to the browser size.
	var pratio = parea / getArea();

	sflog("Total plugin area: " + parea);
	sflog("Total screen size: " + getArea());
	sflog("Ratio: " + pratio);

	//If more than 40% of the screen is plugin content, we assume that there's no good 
	//thumbnail for the user to choose.  This is an arbitrary amount.
	if (pratio > 0.4) {
		sflog("Too much plugin content...");
		failsafe();
	}

	//Disable the links.
	for (var a=0; a < document.links.length; a++) {	
		document.links[a].onclick=function (e) { return false; }; 
	} 

	//Disable forms.
	for (var f=0; f < document.forms.length; f++ ) {
		document.forms[f].onsubmit=function (e) { 
			alert("StyleFeeder: Cannot use that image - please choose another"); 
			return false;
		};
	}



	//Special mouse-following message.
	var sfpointer = document.createElement('div');
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
	sfpointer.innerHTML='Click on the picture you want to post';

	document.body.appendChild(sfpointer);
	
	//Change default handlers for images
	for (var i=0; i < document.images.length; i++) { 

		//Click handler.
		document.images[i].onclick = function (e) {  
			sflog('onclick event trapped');
					
					
					
						document.location='//www.stylefeeder.com/bookmarklet/index.html?url='+encodeURIComponent(sf_url)+'&description='+encodeURIComponent(sf_description)+'&thumbnailUrl='+encodeURIComponent(this.src); 
						document.getElementById('sfpointer').style.display='none';
						document.getElementById('sfside').style.display='none';
						document.body.style.cursor='pointer';
					
					 
		}

		//When the mouse is over....
		document.images[i].onmouseover = function (e) {
			//change the border to +1
			// as long as it isn't our logo
			if (this.src!=logo) {	
			this.style.border = 'solid 2px red';}
		}
		document.images[i].onmouseout = function (e) {
			this.style.border = '0px';
		}
	}
	
	//Special y-axis mouse-following menu
	var sfside = document.createElement('div');
	sflog(sfside);
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
	sfLoc.id = 'styleFeederLocation';
	sfLoc.style.display = 'none';
	sfLoc.innerHTML = location.href;

	document.body.appendChild(sfside);
	document.body.appendChild(sfLoc);

//	document.getElementById('styleFeederThumbnailUrl').innerHTML = recurseTree(document.body);
	recurseTree(document.body);

	sflog('Remote script processed');

} catch (e) {
	sflog("Exception caught: " + e);
	failsafe("caught-exception");
}



function recurseTree(element) {
	if ((element.nodeName.toUpperCase() == 'TD') | (element.nodeName.toUpperCase() == 'H1')  && element.style['backgroundImage']) {
		
				element.onmouseover = function (e) {
					this.style.border = 'solid 2px red';
				}
				
				element.onmouseout = function (e) {
					this.style.border = '0px';
				}
				
				element.onclick = function (e) {
					// regexp to look for the url css parameter
					var re_url = /url\((.*)\)/g;
					// loading the background image location
					var bg_url = element.style['backgroundImage'];
					// extract the location of the image
					var image_url = bg_url.replace(re_url,'$1');
					sflog(image_url);
					
					// create regexp test to look for absolute path
					var re_test_fqdn = /http/g;
					
					// test to see if the absolute path was used
					if (!image_url.match(re_test_fqdn)) {
						// relative pathing used
						// extract the server name from the sf_url variable
						var re_servername = /(^http:\/\/[a-zA-Z0-9_\-\.]+\/).*/g;
						
						// extract the server name
						var fqdn = sf_url.replace(re_servername, '$1');
						sflog(fqdn);
						
						// image location set to the server name and the image path
						image_url = fqdn + image_url;
						sflog(image_url);
					}
					// add the item to the user feed
					
					
					
						alert('no!');
						document.location='//www.stylefeeder.com/bookmarklet/index.html2?url='+encodeURIComponent(sf_url)+'&description='+encodeURIComponent(sf_description)+'&thumbnailUrl='+encodeURIComponent(image_url);
					
					 
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
		sflog(element);
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


void(null);