YAHOO.widget.Carousel = function() {
	this.oItems = [];
	this.degreesPerFrame = 1.5;
	// for the unit circle at 0, this is the distance traveled per frame
	this.sin = Math.sin(this.degreesPerFrame*Math.PI/180);
	this.cos = Math.cos(this.degreesPerFrame*Math.PI/180);
	this.segment = 0;
	this.distance = 0;
//	this.anim = new YAHOO.util.Anim();
};
YAHOO.widget.Carousel.prototype.updateSinCos = function() {
	this.sin = Math.sin(this.degreesPerFrame*Math.PI/180);
	this.cos = Math.cos(this.degreesPerFrame*Math.PI/180);
};
YAHOO.widget.Carousel.prototype.rotateItems = function() {
	for(var i = 0, len = this.oItems.length; i < len; i++) {
		var oItem = this.oItems[i];
		// for larger values of z pull the x value in
		var x1 = oItem.x*this.cos-oItem.z*this.sin;
		// for larger values of x increase z (perspective)
		oItem.z = oItem.z*this.cos+oItem.x*this.sin;
		// set x here - avoids the value of x continually getting smaller
		oItem.x = x1;
		var r = 600/(600+oItem.z);

		var zIndex = Math.round(1000-oItem.z);
		oItem.li.style.zIndex = zIndex;

		// make things transparent based on their zindex
		var opacity = (oItem.li.style.zIndex-900)/190;

		var imgWidth = 172;
		var imgHeight = 254;

		oItem.li.style.width = (imgWidth * opacity) + 'px';
		oItem.li.style.height = (imgHeight * opacity) + 'px';

		// do some movement
		oItem.li.style.left = Math.round(256+(2*oItem.x*r)-(imgWidth*0.5*opacity))+"px";
		oItem.li.style.top = Math.round(-50-(2*oItem.y*r))+"px";

		// YUI Opacity Magicallyooo
		YAHOO.util.Dom.setStyle(oItem.li,'opacity',opacity);
	}
};
YAHOO.widget.Carousel.prototype.rotateSegment = function(degreesPerFrame, segments) {
	if(typeof(degreesPerFrame) != 'undefined') {
		this.degreesPerFrame = degreesPerFrame;
		this.updateSinCos();
	}
	if(typeof(segments) == 'undefined') {
		segments = 1;
	} else if(segments == 0) {
		return;
	}
	
	// rotate one notch
	this.rotateItems();
	
	// the distance moved
	this.distance += this.degreesPerFrame*Math.PI/180;
	var totalDistance = segments*this.segment;
	if(Math.abs(this.distance) >= totalDistance) {
		// item positions updated here
		this.updatePositions(segments);
		this.distance = 0;
	} else {
		var self = this;
		var callback = function() { self.rotateSegment(self.degreesPerFrame,segments); };
		setTimeout(callback, 16);
	}
	
};
YAHOO.widget.Carousel.prototype.updatePositions = function(seg) {
	if(typeof(seg) == 'undefined') {
		seg = 1;
	}
	for(var i = 0, len = this.oItems.length; i < len; i++) {
		var oItem = this.oItems[i];
		if(this.degreesPerFrame > 0) {
			oItem.itemNum += seg % len;
		} else {
			oItem.itemNum -= seg % len;
		}
		if(oItem.itemNum >= len) {
			oItem.itemNum = 0;
		} else if(oItem.itemNum < 0) { 
			oItem.itemNum = len - 1;
		}
	};
};

YAHOO.widget.Carousel.prototype.prev = function(e) {
    YAHOO.util.Event.stopEvent(e);
	this.rotateSegment(-1.5);
};
YAHOO.widget.Carousel.prototype.next = function(e) {
	YAHOO.util.Event.stopEvent(e);
	this.rotateSegment(1.5);
};
YAHOO.widget.Carousel.prototype.init = function(oDomList) {
    var maxDegrees = 2 * Math.PI;
	var oDomItems = oDomList.getElementsByTagName('LI');
	this.segment = maxDegrees/oDomItems.length;
//	var scr = document.getElementById('screen');
	
	// position the elements initially
	for(var i = 0; i < oDomItems.length; i++) {
		var degreePart = i * this.segment;
		var x = 90 * Math.cos(degreePart - 0.7*Math.PI);
		var z = 90 * Math.sin(degreePart - 0.7*Math.PI);
		this.oItems[this.oItems.length] = new YAHOO.widget.Carousel.Item(oDomItems[i],x,-70,z,i);
		var self = this;
		YAHOO.util.Event.on(oDomItems[i],'click',this.bringToFront,[this.oItems[i],this]);
	}
	this.wireDefaultEvents();
	this.rotateSegment();
};
YAHOO.widget.Carousel.prototype.bringToFront = function(e,aElems) {
	var oItem = aElems[0];
	var oCarousel = aElems[1];
	var numSegments = 0;
	if(oCarousel.degreesPerFrame > 0) {
		numSegments = oCarousel.oItems.length - oItem.itemNum - 1;
	} else {
		numSegments = oItem.itemNum - 1;
	}
	oCarousel.rotateSegment(oCarousel.degreesPerFrame,numSegments);
};
YAHOO.widget.Carousel.prototype.wireDefaultEvents = function() {
	var prev = document.getElementById('yui-carousel-prev');
	var next = document.getElementById('yui-carousel-next');
	YAHOO.util.Event.addListener(prev, "click", this.prev, this, true);
	YAHOO.util.Event.addListener(next, "click", this.next, this, true);
};

// represents an item in the carousel 
YAHOO.widget.Carousel.Item = function(li, x, y, z, itemNum) {
	this.li = li;
	this.w0 = 0; //120;
	this.h0 = 0;
	
	this.itemNum = itemNum;
	
	this.x = x;
	this.y = y;
	this.z = z;
};
