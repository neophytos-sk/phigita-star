$ = xo.getDom;
DH = xo.DomHelper;

var echo = {};

echo.init = function(config) {
    var el = $(config['applyTo']);
    echo.CountChars(el);

    xo.Event.on(el,"focus",echo.UpdateFn);
    xo.Event.on(el,"blur",echo.UpdateFn);
    xo.Event.on(el,"keyup",echo.UpdateFn);

    var commentEl = $(xo.getCssName("echo_comment_text"));
    xo.Event.on(commentEl,"focus",echo.CommentFn);
    xo.Event.on(commentEl,"keyup",echo.CommentFn);

};

echo.CommentFn = function(e,target,options) {
    echo.autogrow(target);
};

echo.UpdateFn = function(e,target,options) {
    echo.CountChars(target);
};

echo.CountChars = function(domEl){
    try {
	var stext = domEl.value;
	var CC_el=$(xo.getCssName('charcount'));
	var CC_btnEl=$(xo.getCssName('update_btn'));
	var el = CC_el;
	var btnEl = CC_btnEl;
	var remaining = 250 - stext.length;
	el.childNodes[0].nodeValue = remaining;
	if (remaining<0) {
	    el.className=xo.getCssName('ch-cnt-neg');
	} else {
		el.className=xo.getCssName('ch-cnt-pos');
	}
	if (remaining < 0 || stext.length == 0) {
	    btnEl.disabled=true;
	} else {
	    btnEl.disabled=false;
	}
	echo.autogrow(domEl);
    } catch (ex) {
	// do nothing
    }
};

echo.autogrow = function(el,minHeight,maxHeight) {
    var count=25;
    while (el.scrollHeight > el.clientHeight  && !window.opera && count) {
	el.rows += 1;
	count -= 1;
    }
};

echo.show = function(node_id,msg_id) {
    var node = $(xo.getCssName(node_id));
    var pivot_node=$('cbox_'+msg_id);
    var p = pivot_node.parentNode;
    p.insertBefore(node,pivot_node);
    node.style.display = 'block';
    return false;
};

echo.hide = function(id) {
    var el = $(xo.getCssName(id));
    el.style.display = 'none';
    return false;
};

echo.comment_box = function(msg_id){
    var input_node =$(xo.getCssName('echo_parent_id'));
    input_node.value = msg_id;
    return echo.show('echo_comment_box',msg_id);
};

echo.toggleDisplay = function(id){
    var el = $(xo.getCssName(id));
    var el2 = $(xo.getCssName(id + '_0'));
    if (el.style.display === 'block') {
	el.style.display = 'none';
	el2.style.display= 'block';
    } else {
	el2.style.display= 'none';
	el.style.display = 'block';
	// TODO: use layer/popup with option to upload or link to image url
	// var divEl = DH.createDom({'id':el.id + '-popup','tag':'div','style':'position:absolute;top:100px;left:100px;z-index:1000;','html':'do something'},el);
    }
    return false;
};

echo.bg_upload = function() {

    var frmEl = $(xo.getCssName('echo_attach_frm'));
    var file =  frmEl['upload_file'].files[0];
    xo.log('file name:' + file.name);
    xo.log('file size:' + file.size);
    xo.log('file type:' + file.type);
    frmEl.submit();
};



echo.clearFileInputField = function(id) { 
    var el = $(id);
    el.style.display = 'none';
    el.setAttribute('type','text');
    el.setAttribute('type','file');
    el.style.display = 'block';
};

//    var baseUrl = 'http://localhost:8090/my/media/view/';
echo.attach = function(o) {
    var baseUrl = 'http://my.phigita.net/media/view/';
    var id = 'attachment_' + o['object_id'];
    var pivotEl = $(xo.getCssName('echo_file_0'));
    var attachmentEl = DH.insertBefore(pivotEl,{
	'tag':'div',
	'cn':[
	    {'tag':'input','id':id,'type':'checkbox','value':o['object_id'],'name':'attachment','checked':'checked'},
	    {'tag':'span','html':'&nbsp;'},
	    {'tag':'img','style':'width:75px;','src':baseUrl + o['object_id']+'?size=120'},
	    {'tag':'label','for':id,'html':o['title']}
	]
    },true);
    echo.clearFileInputField(xo.getCssName('attachment_1'));
    xo.log(attachmentEl);
}

xo.exportSymbol("echo",echo);
xo.exportProperty(echo,"init",echo.init);
xo.exportProperty(echo,"cbox",echo.comment_box);
xo.exportProperty(echo,"hide",echo.hide);
xo.exportProperty(echo,"attach",echo.attach);
// xo.exportProperty(echo,"autogrow",echo.autogrow);

xo.exportProperty(echo,"toggleDisplay",echo.toggleDisplay);
xo.exportProperty(echo,"bg_upload",echo.bg_upload);
xo.exportProperty(echo,"show",echo.show);


//window['echo']=echo;
// window['toggleDisplay']=echo.toggleDisplay;
// window['bg_upload']=echo.bg_upload;
// window['CountChars'] = echo.CountChars;
// window['show'] = echo.show;
// window['hide'] = echo.hide;
// window['cbox'] = echo.comment_box;
// window['autogrow'] = echo.autogrow;

// HTML5
// http://www.matlus.com/html5-file-upload-with-progress/
/*
function uploadFile() {
  var xhr = new XMLHttpRequest();
  var fd = document.getElementById('form1').getFormData();

  // event listners
  xhr.upload.addEventListener("progress", uploadProgress, false);
  xhr.addEventListener("load", uploadComplete, false);
  xhr.addEventListener("error", uploadFailed, false);
  xhr.addEventListener("abort", uploadCanceled, false);
  // Be sure to change the url below to the url of your upload server side script
  xhr.open("POST", "UploadMinimal.aspx");
  xhr.send(fd);
}
*/
