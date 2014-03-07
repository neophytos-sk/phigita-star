var Server = Server || {};
Server.baseURL = "";
Server.load_resource = function(query){
    var script = DH.createDom({"tag":"script","type":"text/javascript"}, document.getElementsByTagName("head")[0]); 
    script.src = Server.baseURL + query;
};



var SearchBox = {
    __maxTime: 0
    ,__lastValue: ""
    ,__resultEl: {}
    ,__hidden: 0
    ,__menuIndex: -1
    ,__length: 0
    ,__config:{}
    ,__NR: 0
    ,TITLE_FIELD: 0
    ,URL_FIELD: 1
};


SearchBox.blur_handler = function(e,target,options) {
    SearchBox.hide_menu();
}

SearchBox.init = function(config) {

    config['applyTo']=$(config["applyTo"]);
    config['displayTo']=$(config["displayTo"]);


    SearchBox.__config = config;

    var el = config['applyTo'];
    SearchBox.__divEl = config["displayTo"] || DH.createDom({"tag":"div"},document.body);
    SearchBox.hide_menu();
    xo.Event.on(el, "keydown", SearchBox.keydown);
    xo.Event.on(el, "keypress", SearchBox.keydown);
    xo.Event.on(el, "keyup", SearchBox.keyup);
    xo.Event.on('suggest_close', "click", SearchBox.hide_menu);
    xo.Event.on(document.body, "click", SearchBox.hide_menu);
};

SearchBox.hide_bar = function() {
    var el = SearchBox.__resultEl[SearchBox.__menuIndex];
    if (el) {
	DH.removeClass(el,xo.getCssName('selected'));
    }
};

SearchBox.show_bar = function() {
    DH.addClass(SearchBox.__resultEl[SearchBox.__menuIndex],xo.getCssName('selected'));
};

SearchBox.reset_bar = function() {
    if (SearchBox.__hidden) {
	SearchBox.__menuIndex = -1;
    } else {
	SearchBox.__menuIndex = 0;
    }
};

SearchBox.hide_menu = function() {
    SearchBox.hide_bar();
    SearchBox.__divEl.style.display = 'none';
    if (SearchBox.__NR) {
	DH.addClass($(SearchBox.__config['applyTo']),xo.getCssName('has_results'));
    }
    SearchBox.reset_bar();
    SearchBox.__hidden=1;
};

SearchBox.show_menu = function() {
    if (SearchBox.__hidden) {
	//SearchBox.reset_bar();
	// DH.removeClass($(SearchBox.__config['applyTo']),xo.getCssName('has_results'));
	SearchBox.__hidden=0;
    }
    SearchBox.__divEl.style.display = 'block';
};


SearchBox.keydown = function(e,target,options) {

    if (e.keyCode == xo.Event.ENTER) {
	if (SearchBox.__NR && !SearchBox.__hidden) {
	    xo.Event.stopEvent(e);
	    var url = SearchBox.__resultEl[SearchBox.__menuIndex].url;
	    top.location.href=url;
	    return;
	}
    }
};

SearchBox.keyup = function(e,target,options) {

    if (e.keyCode == xo.Event.DOWN && SearchBox.__NR) {
	SearchBox.show_menu();
	SearchBox.hide_bar();
	SearchBox.__menuIndex = SearchBox.__menuIndex==-1?0:(SearchBox.__menuIndex + 1) % SearchBox.__length;
	SearchBox.show_bar();
    } else if (e.keyCode == xo.Event.UP && SearchBox.__NR) {
	SearchBox.show_menu();
	DH.removeClass(SearchBox.__resultEl[SearchBox.__menuIndex],xo.getCssName('selected'));
	SearchBox.__menuIndex = SearchBox.__menuIndex<=0?SearchBox.__length-1:(SearchBox.__menuIndex - 1) % SearchBox.__length;
	DH.addClass(SearchBox.__resultEl[SearchBox.__menuIndex],xo.getCssName('selected'));
    } else if (e.keyCode == xo.Event.ENTER) {
	if (SearchBox.__NR && !SearchBox.__hidden) {
	    xo.Event.stopEvent(e);
	    url = SearchBox.__resultEl[SearchBox.__menuIndex].url;
	    top.location.href=url;
	    return;
	}
    } else if (e.keyCode == xo.Event.ESC) {
	if (SearchBox.__hidden) {
	    target.value='';
	    SearchBox.clear();
	} else {
	    SearchBox.hide_menu();
	}
	return;
    }

    if (SearchBox.__lastValue == target.value) return;
    SearchBox.__lastValue = target.value;
    if (target.value.length) {
	Server.load_resource("http://api.phigita.net/livesearch?callback=SearchBox.show&q="+target.value+"&t="+(new Date()).getTime());
    } else {
	SearchBox.hide_menu();
	SearchBox.clear();
    }

};



SearchBox.clear = function(){
    for(var i in SearchBox.__resultEl) {
	SearchBox.__resultEl[i].style.display = 'none';
    }
    DH.removeClass($(SearchBox.__config['applyTo']),xo.getCssName('has_results'));
    SearchBox.__NR = 0;
};

SearchBox.handle_click = function(e,target,options) {
    if (SearchBox.__NR && !SearchBox.__hidden) {
	url = SearchBox.__resultEl[SearchBox.__menuIndex].url;
	top.location.href=url;
    }
};

SearchBox.handle_mouseover = function(e,target,options) {
    SearchBox.hide_bar();
    SearchBox.__menuIndex=target.index;
    SearchBox.show_bar();
};

SearchBox.show = function(t,results){
    SearchBox.hide_bar();
    if (SearchBox.__maxTime > t) return;
    SearchBox.__maxTime = t;
    var nr=results.length;
    SearchBox.__NR = nr;
    if (nr) {
	DH.addClass($(SearchBox.__config['applyTo']),xo.getCssName('has_results'));
    } else {
	DH.removeClass($(SearchBox.__config['applyTo']),xo.getCssName('has_results'));
    }
    for(var i=0;i<nr;i++) {
	var url = results[i][SearchBox.URL_FIELD];
	var title = results[i][SearchBox.TITLE_FIELD];
	if (!SearchBox.__resultEl[i]) {
	    SearchBox.__resultEl[i] = DH.createDom({"tag":"div","cn":[{"tag":"div","cls":xo.getCssName("suggest_title"),"html":title},{"tag":"div","cls":xo.getCssName("suggest_url"),"html":url}]},SearchBox.__divEl);
	    SearchBox.__resultEl[i].index = i;
	    xo.Event.on(SearchBox.__resultEl[i],'click',SearchBox.handle_click);
	    xo.Event.on(SearchBox.__resultEl[i],'mouseover',SearchBox.handle_mouseover);
	} else {
	    SearchBox.__resultEl[i].childNodes[0].innerHTML = title;
	    SearchBox.__resultEl[i].childNodes[1].innerHTML = url;
	}
	SearchBox.__resultEl[i].style.display = 'block';
	SearchBox.__resultEl[i].url = url;
	// SearchBox.__resultEl[i].setAttribute('href',results[i][SearchBox.URL_FIELD]);
    }
    for(i=nr;i<SearchBox.__length;i++) {
	SearchBox.__resultEl[i].style.display = 'none';
	// SearchBox.__resultEl[i].childNodes[0].innerHTML = "";
	// SearchBox.__resultEl[i].childNodes[1].innerHTML = "";
    }

    SearchBox.__length = nr;
    SearchBox.reset_bar();
    SearchBox.show_bar();
}

xo.exportSymbol("SearchBox",SearchBox);
xo.exportProperty(SearchBox,"init",SearchBox.init);
xo.exportProperty(SearchBox,"show",SearchBox.show);
