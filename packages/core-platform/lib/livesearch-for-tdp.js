var load_resource = function(url){
    var script = DH.createDom({"tag":"script","type":"text/javascript"}, document.getElementsByTagName("head")[0]); 
    script.src = url;
};

var LS_r;
xo.global["DATA"]={};
function dh_new(tag){
    return DH.createDom({"tag":tag});
}
function dh_add(pn,tag) {
    var cn=dh_new(tag);
    pn.appendChild(cn);
    return cn;
}
function dh_del(n) {
    try {
	while (n.childNodes.length>0) dh_del(n.lastChild);
	n.parentNode.removeChild(n);
	delete n;
    } catch (ex) {
	// do nothing
    }
}
function on_mousedown_handler(e){
    var i=this.getAttribute('s');
    top.location.href=STUB_URL+DATA[i][0];
}
function on_mouseover_handler(e) {
    if(LS_r){LS_r.className=xo.getCssName('ac_a');}
    this.className=xo.getCssName('ac_a') + ' ' + xo.getCssName('ac_mo');
    LS_r=this;
}
function on_mousemove_handler(e){
    on_mouseover_handler.call(this);
}

function livesearch_request(e){
    var q = $("q_proxy").value;
    load_resource(LIVESEARCH_URL + q + '&callback=livesearch_show&t=' + (new Date()).getTime());
    xo.Event.stopEvent(e);
}

var STUB_URL;
var LIVESEARCH_URL; 
window["livesearch_init"] = function(config) {
    STUB_URL = config['stub_url'];
    LIVESEARCH_URL = config['livesearch_url'];
    var inputEl = $(config['applyTo']);
    xo.Event.on(inputEl, "keyup", livesearch_request);
}

window["livesearch_show"] = function(q,results) {

    var inp=xo.getDom("q_proxy");
    if (q != inp.value) return;


    DATA=results;
    var t = $("search-results");
    if (t) dh_del(t);
    if (DATA.length==0) return;
    try {
	var t=dh_new('table');
	t.id='search-results';
	t.className=xo.getCssName('ac_m');
	var inp_coords = xo.Dom.getXY(inp);
	t.style['left']= (inp_coords[0] - 400 + parseInt(inp.width) + 20) + 'px';
	t.style['top']=(inp_coords[1] + inp.offsetHeight+1) + 'px';
	var tbody=dh_add(t,'tbody');
	inp.parentNode.appendChild(t);
	for (var i=0;i<DATA.length;i++) {
	    var tr=dh_add(tbody,'tr');
	    var td_c=dh_add(tr,"td");
	    var td_d=dh_add(tr,"td");
	    tr.setAttribute('s',i);
	    tr.className=xo.getCssName('ac_a');
	    td_c.className=xo.getCssName('ac_c');
	    td_d.className=xo.getCssName('ac_d');
							 
	    td_c.appendChild(document.createTextNode(DATA[i][1]));
	    td_d.appendChild(document.createTextNode(DATA[i][2]));
							 
	    tr.onmousedown=on_mousedown_handler;
	    tr.onmouseover=on_mouseover_handler;
	    tr.onmousemove=on_mousemove_handler;
	}
    } catch (ex) {
	console.log(ex);
	// do nothing
    }

}
