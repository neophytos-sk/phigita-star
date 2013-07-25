Ext.Comet = function(config) {
	this.events = {
		receive:true
	}
	Ext.apply(this, config);
}
Ext.extend(Ext.Comet, Ext.util.Observable, {

	_intervalId : null,
	request : null,
	interval : 200,
	lastTextPosition: 0,
	autoReconnect : true,
	reconnectIntervalOnFailure : 5000,
	url : null,

	start : function() {
		this.request = Ext.Ajax.request({
			url:this.url,
			callback:this.requestCallback,
			scope:this
		});
		this._intervalId = setInterval(this.watch.createDelegate(this),
			this.interval);
	},

	requestCallback : function(o, success, r) {
		console.log("End :", o, success, r);
		this.watch();
		this.stop();
		if (this.autoReconnect) {
			if (success) {
				this.start();
			} else {
				this.start.defer(this.reconnectIntervalOnFailure, this);
			}
		}
	},

	watch : function() {
		var text = this.request.conn.responseText;
		if (text.length == this.lastTextPosition) { return; }
		var last = text.substring(this.lastTextPosition);
		this.lastTextPosition = text.length;
		var lasts = last.split("\\n");
		var nbInfos = lasts.length;
		for (i = 0; i < nbInfos; i++) {
			if (lasts[i] === "") { continue; }
			o = "";
			try {
				o = eval("("+lasts[i]+")");
				if (!o) { o = lasts[i]; }
			} catch(ex) {
				o = lasts[i];
			}
			this.fireEvent("receive", o);
		}
	},

	stop : function() {
		clearInterval(this._intervalId);
		this.request.conn.abort();
	}


});
