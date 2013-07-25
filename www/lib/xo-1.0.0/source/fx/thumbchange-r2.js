YAHOO.namespace("youporn.thumbchange");

YAHOO.youporn.thumbchange = function () {
	
	var yue = YAHOO.util.Event;
	var yud = YAHOO.util.Dom;
	
	function Changer(el) {
		this.el       = el;
		this.origsrc  = el.src;
		this.running  = false;
		this.runnable = true;
		this.images   = new Array();
		this.num_ss   = this.el.getAttribute('num');
		
		var result = el.src.match(/screenshot\/(\d+)_large\.jpg$/);
		if (result) {
			this.video_id = result[1];
			this.prepend_url = el.src.substr(0, el.src.search(/screenshot\/(\d+)_large\.jpg$/));
		} else {
			this.runnable = false;
		}
	}
	
	Changer.prototype.start = function () {
		yud.addClass(this.el, 'highlight-on');
		if (this.runnable) {
			this.running = true;
			this.preload();
			this.animate(1);
		}
	}
	
	Changer.prototype.stop = function () {
		yud.removeClass(this.el, 'highlight-on');
		if (this.runnable) {
			this.el.src = this.origsrc;
			this.running = false;
		}
	}
	
	Changer.prototype.preload = function () {
		for (var i=1; i<=this.num_ss; i++) {
			this.images[i] = new Image();
		}
		
		this.load(1);
		for (var i=2; i<=this.num_ss; i++) {
			setTimeout((function(obj, j) { 
				return function() { obj.load(j); }
			})(this, i), i*100);
		}
	}
	
	Changer.prototype.load = function (num) {
		if (this.running) {
			this.images[num].src = this.prepend_url + 'screenshot_multiple/' + this.video_id + '/' + this.video_id + '_multiple_' +  num + '.jpg';
		}
	}
	
	Changer.prototype.animate = function (num) {
		if (this.running) {
			if (this.images[num].complete) {
				this.el.src = this.images[num].src;
				
				var next = (num == this.num_ss) ? 1 : num + 1;
				setTimeout((function(obj, i) { 
					return function() { obj.animate(i); }
				})(this, next), 625);			
			} else {
				setTimeout((function(obj, i) { 
					return function() { obj.animate(i); }
				})(this, num), 25);			
			}
		}
	}
	
	return {
		register: function (n) {
			for (var i=1; i<=n; i++) {
				yue.onContentReady('thumb' + i, this.hookEvents, this);
			}			
		},

		hookEvents: function () {
			el = this;
			if (el.getAttribute('num') == 0) {
				var tt = new YAHOO.widget.Tooltip("tt_" + el.id, { context:el, text: "No preview available" });
			} else {
				var changer = new Changer(el);
				yue.addListener(el, 'mouseover', changer.start, changer, true);
				yue.addListener(el, 'mouseout', changer.stop, changer, true);
			}			
		}
	};
}();
