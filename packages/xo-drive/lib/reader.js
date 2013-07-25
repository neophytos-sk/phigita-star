$ = xo.getDom;


/**
 * Global namespace.
 * @type {Object}
 */
var DR = DR || {};

/**
 * Initiates the main application logic. This is the first point at which any
 * scripting logic is applied.
 */

DR.init = function(config) {

    xo.apply(DR,config,{'docId':null,'pages':0,'currentPage':1,'size':500,'view':0,'baseUrl':''});
    DR.ratio = 1;

    DR.loadPrefs();

    $('totalpages').innerHTML = DR['pages'];

    //Calculate width/height ratio  

    var a=$('page_1').lastChild;
    DR.ratio = a.clientWidth/a.clientHeight;

    addPageStyle();

    for(var i=2;i<=DR['pages'];i++) {
	DR.addPlaceholder(i);
    }

    DR.update();

    //Check whether fits in page
    //if(DR['size']> window.innerWidth) {
    //	DR.zoom(-1);
	//$('search').style.display='none';
	//$('btnfullscreen').style.display='inline';
    //}
    DR.savePrefs();


    DR.showAllVisible();
  
    registerEvents();

    setSpacer();

};


DR.setView = function(v) {
    /*Views:
      0: Scroll
      1: Slideshow
    */
    DR['view'] = v;		
    var c = DR.getCur();
    $('viewtooltip').style.display='none';
    addPageStyle();	
    setSpacer();
    var ids = ['toolbar','zoomcontrols','pagecontrols','slidecontrols','slidemask'/*,'searchcontrols'*/]
    var display = [
		   ['block','inline','inline','none','none'/*,'inline'*/]
		   ,['none','none','none','inline','block'/*,'none'*/]
		   ]
    for(var i = 0; i < ids.length; i++)
	{
	    $(ids[i]).style.display=display[v][i];
	}

    switch (v)
	{
	case 0:
	$('curview').src='/graphics/reader/viewscroll.gif';
	break;
	case 1:
	$('curview').src='/graphics/reader/viewslideshow.gif';			
	DR['size'] = availableSizes[availableSizes.length-1];
	DR.reload();
	break;
	}
    DR.goToPage(c);
	
};

//Document reader general functions
var availableSizes = [120,240,500,800];
var sizes = [120,240,400,500,600,700,800,900,1000,1200];

DR.getSizeId = function() {  
    var bestIndex = 0;
    var minDiff  = Math.abs(availableSizes[bestIndex]-DR['size']);
    for (var i=1;i<availableSizes.length;i++) {
	if (Math.abs(availableSizes[i]-DR['size'])<minDiff) {
	    bestIndex = i;
	}
    }
    return availableSizes[bestIndex];
};

DR.getImageUrl = function(page) {
    return DR['baseUrl'] + DR['docId'] + '/?size='+ DR.getSizeId() +'&p=' + page;
};

DR.addPlaceholder = function(page){
    xo.DomHelper.createDom({
	'tag':'div',
	'id':'page_'+page,
	'cls':'page'
    }, $('content'));
    //DH.add($('content'),'div',{'id':'page_'+page,'class':'page'});  
};

DR.isPageLoaded = function(page){
    if(page<1 || page>DR['pages']) return false;
    var pageEl = $('page_'+page);
    return pageEl && pageEl.hasChildNodes();
};

DR.getCur = function() {
    var c=1;
    switch (DR['view']) {
    case 0:
	c=Math.round((window.pageYOffset)/DR.getPageHeight())+1;
	break;
    case 1:			
	c=Math.floor((window.pageXOffset)/(window.innerWidth-30))+1;
	break;
    }
    if(c<1) return 1;
    if(c>DR['pages']) return DR['pages'];
    return c;
};

DR.getPageHeight = function getPageHeight() {
    return Math.ceil(DR.getPageWidth()/DR.ratio);
};

DR.getPageWidth = function getPageWidth() {
    return DR['size'];
};

//Document reader actions
DR.zoom = function(rel) {
    loadingcount=0;//'stop' loading
    var p=DR.getCur();
    var cur=0; 
    for(var i=1;i<sizes.length;i++){
	if(DR['size']==sizes[i]) {cur=i; break;}
    } //get current size index
	
    //if new size in range
    if (rel + cur > -1 && rel+cur<sizes.length) {
	DR['size'] = sizes[cur+rel];		
	addPageStyle();
	DR.reload();
    }
    if($('page_'+p)==null)return;
    window.scrollTo(0,$('page_'+p).offsetTop);
    DR.savePrefs();
    DR.showAllVisible();
};

DR.showAllVisible = function() {
    for(var i=2; i <= DR['pages']; i++) {
	if (DR['view'] == 0) {
	    var innerHeight = window.innerHeight;
	    var pageYOffset = window.pageYOffset;
	    if($('page_'+i).offsetTop <= innerHeight+pageYOffset && $('page_'+i).offsetTop >= pageYOffset) {
		DR.showPage(i);
	    }
	    else break;
	} else if (DR['view'] == 1) {
	    var innerWidth = window.innerWidth;
	    var pageXOffset = window.pageXOffset;
	    if($('page_'+i).offsetLeft <= innerWidth+pageXOffset && $('page_'+i).offsetLeft >= pageXOffset) {
		DR.showPage(i);
	    }
	    else break;
	}
    }
};

DR.reload = function() {
    var p = DR.getCur();
    DR.reloadPage(p);
    DR.reloadPage(p+1);
    DR.reloadPage(p-1);
    DR.goTo(p);
};

/*
DR.highlight = function(page,x,y,width,height){	
	var imgEl = DH.add(document.body,'img');
	imgEl.src= "/graphics/reader/hl_y.png";
	imgEl.style.position="absolute";
	imgEl.style.top=($('page_'+page).offsetTop+y)+"px";
	alert('need offset left!');
	imgEl.style.left=(offsetLeft+x)+"px";
	imgEl.width=width;imgEl.height=height;	
}*/
//Reader action helpers
DR.showPage = function(page) {
  if(page < 1 || page > DR['pages']) return;
  if(DR.isPageLoaded(page)) return;
  var imgEl = xo.DomHelper.createDom({
      'tag':'img',
      'src':DR.getImageUrl(page),
      'onload':function(){loadingcount--;}
  },$('page_'+page));
  //imgEl.src= DR.getImageUrl(page);
  //imgEl.onload = function(){loadingcount--;}
  loadingcount++;
};

var loadingcount=0;
DR.reloadPage = function(p) {  
  if(DR.isPageLoaded(p)==false) return;
  var pageEl = $('page_'+p); 
  if(pageEl.lastChild.src != DR.getImageUrl(p))
  {
	  pageEl.lastChild.src = DR.getImageUrl(p);
	  pageEl.lastChild.setAttribute('width', DR['size'] + 'px');
	  pageEl.lastChild.onload = function(){loadingcount--;}
	  loadingcount++;
  }
};

DR.goToPage = function(page){
    var c = $('page_'+page)
    if(c!=null){
	ssflag = true;
	if(DR['view'] == 0) window.scrollTo(0,c.offsetTop);		
	else if(DR['view'] == 1) window.scrollTo(c.offsetLeft,0);		
    }
};

DR.goTo = function(rel){
  DR.goToPage(DR.getCur()+rel);
};

DR.prevPage = function() {
    DR.goTo(-1);
};
DR.nextPage = function() {
    DR.goTo(1);
};

//Reader Preferences
DR.savePrefs = function(){
    if (typeof window.localStorage != 'undefined') {
	var key = DR['docId'] + '.size';
	window.localStorage.setItem(key, DR['size']);
    } else {
	document.cookie = "reader_size_"+DR['docId']+"="+DR['size'];
    }
};

DR.loadPrefs = function(){
    if (typeof window.localStorage != 'undefined') {
	var key = DR['docId'] + '.size';
	value=window.localStorage.getItem(key);
    } else {
	if(document.cookie==null)return;
	var c=document.cookie.split(";");
	for(var i=0;i<c.length;i++) {
	    if(c[i].indexOf("reader_size_"+DR['docId']+"=")==0) {
		value = c[i].replace("reader_size_"+DR['docId']+"=","");
		break;
	    }
	}
    }
    if (-1 != availableSizes.indexOf(value)) {
	DR['size']=value;
    }
};

//Mouse functions
var mouseX=0,mouseY=0;
var mdown=false;
function getMouseX(e){
    return e.clientX+window.pageXOffset;
};

function getMouseY(e) {
    return e.clientY+window.pageYOffset;
};

function onmdown(e){
    xo.Event.stopEvent(e);
    if(DR['view']==0) {
	mdown=true;
	ssflag=true;
	mouseX=getMouseX(e);
	mouseY=getMouseY(e);		
    }
    $('viewtooltip').style.display='none';
    return false;
};

function onmmove(e){
    switch(DR['view']) {
    case 0:
	if(mdown==true) {
	    var x=window.pageXOffset+(mouseX-getMouseX(e));
	    var y=window.pageYOffset+(mouseY-getMouseY(e));
	    window.scrollTo(x,y);		
	}	
	break;
    case 1:
	$('toolbar').style.display='block';
	counter=3000;
	break;
    }
};

function onmup(e){
    mdown = false;	
};

//Scroll wheel
var last_delta=0, ssflag=false, step_size=15;

DR.smoothScroll=function (delta,duration){
    if(ssflag==true){last_delta=0;return;}
    if(duration<=0){last_delta=0;return;}
    //if(delta<0 && window.pageYOffset == 0) return;
    
    if(typeof duration =='undefined'){duration = Math.floor(Math.abs(delta*10));}
    else{duration -= 1;}
   
    if((delta>0 && last_delta>0) || (delta<0 && last_delta<0) || last_delta==0)
	{
	    last_delta+=delta;
	}
    else
	{
	    ssflag=true;return;
	}
    var dy = -delta*step_size;
    window.scrollBy(0,dy);
    setTimeout("DR.smoothScroll("+delta+","+duration+");",10);    
};

function wheel(e){
    xo.Event.stopEvent(e);
    var delta = 0;
    if(e.wheelDelta){delta=e.wheelDelta/120;}
    if(e.detail){delta=-e.detail/3;}
    if (!delta) {return;}
  
    var rel = delta>0?1:-1;

    switch (DR['view']) {
    case 0:	  
	if (e.ctrlKey) {
	    DR.zoom(rel);
	    return false;
	} else {	   
	    ssflag=false;
	    if(e.altKey){DR.smoothScroll(delta,99999);}
	    else{DR.smoothScroll(delta);}
	}
	break;
    case 1:	   
	DR.goTo(-rel);
	break;
    }
};

//Keyboard functions
window.onkeydown = function(e){

    switch(DR['view']) {
    case 0:
	if(e.ctrlKey && e.keyCode == xo.Event.NUM_MINUS) {DR.zoom(-1);return false;}
	if(e.ctrlKey && e.keyCode == xo.Event.NUM_EQUAL) {DR.zoom(1);return false;}
	if(e.keyCode == xo.Event.PAGE_UP){DR.goTo(-1);return false;}
	if(e.keyCode == xo.Event.PAGE_DOWN){DR.goTo(+1);return false;}
	break;
    case 1:
	if(e.keyCode == xo.Event.PAGE_UP){DR.goTo(-1);return false;}
	if(e.keyCode == xo.Event.PAGE_DOWN){DR.goTo(+1);return false;}
	if(e.keyCode == xo.Event.SPACE){DR.goTo(1);return false;}
	if(e.keyCode == xo.Event.UP || e.keyCode == xo.Event.LEFT ){DR.goTo(-1);return false;}
	if(e.keyCode == xo.Event.RIGHT || e.keyCode == xo.Event.DOWN){DR.goTo(+1);return false;}
	if(e.keyCode == xo.Event.HOME){DR.goToPage(1);return false;}
	if(e.keyCode == xo.Event.END){DR.goToPage(DR['pages']);return false;}
	break;
    }
};

function gotopagekeydown(e) {
    if(e.keyCode==13) {
	DR.goToPage(Math.floor($('goto').value));
    }
    return true;
};

function searchkeydown(e) {
    //if(e.keyCode==13){}
};

//UI Functions
var counter;
DR.update = function () {
    //Update loading message
    var l = $('loading');
    if(loadingcount==0){l.style.display='none';}
    else{l.style.display='block';}
    if(DR['view']==1) {
	if(counter>0){counter-=1000;}
	else $('toolbar').style.display='none';
    }
    setTimeout("DR.update();",1000);
};

DR.showViewModeSelector = function (){
    $('viewtooltip').style.display='inline-block';
};

function addPageStyle() {
    var stylesheet = document.styleSheets[0];
    stylesheet.deleteRule(0);
    if(DR['view']==0) {
	stylesheet.insertRule(".page {width:"+DR.getPageWidth()+"px;height:"+DR.getPageHeight()+"px;border:2px solid #000;margin:10px auto 10px auto;cursor:move;}",0);	
	$('content').style.width=(window.innerWidth-30)+'px';
	document.body.style.overflow='auto';
    } else {
	stylesheet.insertRule(".page {width:"+(window.innerWidth-30)+"px;height:"+(window.innerHeight-40)+"px;display:inline-block;*display:inline;zoom:1;margin:10px 0 0 0;cursor:normal;}",0);	
	$('content').style.width=window.innerWidth*DR['pages']+'px';		
	document.body.style.overflow='hidden';
    }
};

function setSpacer() {
    var h = 0;
    if (DR['view'] == 0)  h = window.innerHeight-DR.getPageHeight()-12;
    if(h<0) h=0;
    $('spacer').style.height=h+'px';
};

window.onresize = function(e){
    addPageStyle();
};


var reader = null;

window.onscroll = function(e){	
    //Load current page +-1
    var c = DR.getCur();
    if($('page_'+c)==null)return;
    if($('page_'+c).lastchild == null){
	for (var i=c-1;i<=c+1;i++){
	    DR.reloadPage(i);
	    DR.showPage(i);
	}
    }
    //Load all visible pages
    DR.showAllVisible();
    $('goto').value = c ;
    //More pages indicator
    if(window.pageYOffset > (DR['pages']-2)*DR.getPageHeight() || DR['view'] == 1) {
	$('morepages').style.visibility='hidden';
    } else {
	$('morepages').style.visibility='visible';
    }
    setSpacer();
};


DR.zoomOut = function(){  
    DR.zoom(-1);
};
DR.zoomIn = function(){  
    DR.zoom(1);
};

DR.setSlideShowMode=function(){
    DR.setView(1);
};
DR.setScrollMode=function(){
    DR.setView(0);
};

function registerEvents() {

    xo.Event.on('goto','keydown',gotopagekeydown);
    //xo.Event.on('search','keydown',searchkeydown);
    xo.Event.on('content','mousedown',onmdown);
    xo.Event.on('slidemask','mousedown',onmdown);
    xo.Event.on('content','mousemove',onmmove);
    xo.Event.on('slidemask','mousemove',onmmove);
    xo.Event.on('content','mouseup',onmup);
    xo.Event.on('curview','click',DR.showViewModeSelector);
    xo.Event.on('btnslideshow','click',DR.setSlideShowMode);
    xo.Event.on('btnscroll','click',DR.setScrollMode);

    xo.Event.on('btnprev','click',DR.prevPage);
    xo.Event.on('btnnext','click',DR.nextPage);
    xo.Event.on('btnprevslide','click',DR.prevPage);
    xo.Event.on('btnnextslide','click',DR.nextPage);
    xo.Event.on('prevslide','click',DR.prevPage);
    xo.Event.on('nextslide','click',DR.nextPage);

    xo.Event.on('btnzoomout','click',DR.zoomOut);
    xo.Event.on('btnzoomin','click',DR.zoomIn);

    if (window.addEventListener)
        window.addEventListener('DOMMouseScroll', wheel, false);
    window.onmousewheel = document.onmousewheel = wheel;
}


/**
 * Assign namespace to window object.
 */

xo.exportSymbol("DR",DR);
xo.exportProperty(DR,"init",DR.init);
xo.exportProperty(DR,"smoothScroll",DR.smoothScroll);
xo.exportProperty(DR,"update",DR.update);