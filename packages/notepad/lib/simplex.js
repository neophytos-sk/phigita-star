/*
 * TODO:
 * - type of node, e.g. note (default), code, file, image, and so on
 * - http://stackoverflow.com/questions/1900117/how-can-i-get-auto-repeated-keydown-events-in-firefox-when-arrow-keys-are-held-d
 *
 */


xo.Dom.Helper = xo.DomHelper || {};

xo.DomHelper.isAncestorOf = function(x, y) {
    if (!xo.isDef(x) || !xo.isDef(y) || !x || !y)
	return false;
    var n = x.parentNode;
    while (n != null) {
	if (n == y)
	    return true;
	n = n.parentNode;
    }
    return false;
}

xo.Dom = xo.Dom || {};



WORD_CHARS="A-Za-z\\u00C0-\\u02AE\\u0386-\\u0523",WORD_CHARS_PLUS_DIGITS=WORD_CHARS+"\\d";
TAG_REGEXP=RegExp("(^|[ ])#([" + WORD_CHARS_PLUS_DIGITS + "\\-_]+)","ig");
SYMBOL_REGEXP=RegExp("(^|[ ])\\$(["+WORD_CHARS+"][" + WORD_CHARS_PLUS_DIGITS + "]+)","ig");
URL_REGEXP=RegExp("(https?:\\/\\/([a-z\\d\\-\\.]+)(\\:\\d+)?(\\/[a-z\\d\\/#?&%=~;$\\-_.+!*'(),]*)?)","ig");

/* We use this variables to shrink the resulting file size even more. */

var _id_          = 0;
var _text_        = 1;
var _parent_      = 2;
var _prev_        = 3;
var _next_        = 4;
var _prevSibling_ = 5;
var _nextSibling_ = 6;
var _collapsed_   = 7;
var _completed_   = 8;
var _noted_       = 9;
var _note_        = 10

// var _first = 9;
// var _lastDirect = 10;  // lastChild

var _saveButton_saveNow_ = 0;
var _saveButton_saving_  = 1;
var _saveButton_saved_   = 2;




xo.DomHelper.moveBefore = function(el,o) {
    el.parentNode.insertBefore(o,el);
    return o;
};


//Simplex
//Phigita
$ = xo.getDom;

var Simplex = {
    timeout: {}
};

//=============================================Server=============================================
//This namespace is responsible for the server communication - data saving
var Server = Server || {};
Server.queue = []; //all commands that are currently running - waiting server response
Server.logNotReady = [];
Server.currentRequest = "";
Server.remainingCallbackCount = 0; //count of callbacks remaining to complete the previous request

Server.baseUrl = "http://api.phigita.net/simplex/test?";
// Server.baseUrl = "http://localhost:8090/api/simplex/test?";
Server.userPrefix;
Server.sessionID;
Server.rootID_key; //ID of the ROOT item

Server.loadRequest = function(query){ //Responsible to create/send all requests	
    var script = DH.createDom({"tag":"script","type":"text/javascript"}, document.getElementsByTagName("head")[0]);	
    script.src = Server.baseUrl + query;
    // Server.setConnectionStatus("Talking with the server...");
    xo.log('loadRequest: ' + query);
};


Server.request = function(postData,callback) {
    xo.Ajax.asyncRequest(Server.baseUrl,callback,postData);
};



Server.batchData = "";
Server.batchCount = 0;
Server.batch_new = function(){
	Server.batch_send();
	Server.batchData ="";
	Server.batchCount = 0;
}

Server.batch_send = function(callbackName){
	//FORMAT: http://api.phigita.net/simplex/test?cmd=batch_mutation&batch_count=3&cmd0=put&argv0=a%201&cmd1=put&argv1=b%202&cmd2=put&argv2=c%203&callback0=a&callback1=2&callback2=2&callback=generic_callback_for_all_subcmds
    if(Server.batchCount > 0){
	var query = "cmd=batch_mutation&batch_count=" + (Server.batchCount) + "&" + Server.batchData;
	if (callbackName) {
	    query = query + "&callback=" + callbackName;
	}
	Server.queue.push(query);
	Server.run_next();
	Simplex.publish("refreshData");
	xo.log("batchCount:" + Server.batchCount);
    }
}

Server.batch_include = function(type, args){
    switch (type){
    case "SET":
	Server.batchData += Server.getargs_setItem(args, Server.batchCount,true) + "&";  // true is for nocallback for the given SET command
	break;
    case "GET":
	Server.batchData += Server.getargs_getItem(args, Server.batchCount) + "&";
	break;
    case "DEL":
	Server.batchData += Server.getargs_deleteItem(args, Server.batchCount) + "&";
	break;
    default:
	return;
    }
    Server.batchCount++;
}

Server.reqSuccess = function(o,arg) {
    //evalJS
    xo.log("asyncRequest success: " + xo.encode(o));
    eval( o.responseText );
    // if (o["session_id"]) {
    // localStorage["session_id"] = session_id;
    // }
}
Server.reqFailure = function(o) {
    xo.log("asyncRequest failure: " + o.tId + ": " + o.statusText);
}

Server.run_next = function(){
	if(Server.queue.length == 0) return;
	

//	if(Server.remainingCallbackCount == 0)
		Server.logNotReady = [];
		var query = Server.queue.shift();
		
		var callbacksExpected = 1;
		
		var v = query.split("&");
		for(var i = 0; i < v.length; i++){
			if(v[i].indexOf("batch_count=") == 0){
				v = v[i].split("=");
				callbacksExpected = v[1];
				break;
			}
		}
		
		Server.remainingCallbackCount = callbacksExpected;
		//xo.log("QUERY SENT:" + query);
		if(query.indexOf("HTMLDivElement") > -1 ){
			xo.log("FOUND HTMLDIV ELEM");
		}
		
		Server.currentRequest = query;
		//Server.load_resource(query);
		Server.request(query,{"success":Server.reqSuccess,"failure":Server.reqFailure});
/* else
		Server.logNotReady.push(Server.remainingCallbackCount);
		
		if(Server.logNotReady.length > 10)
			Server.setConnectionStatus("No server connection...");
		else if(Server.logNotReady.length > 5)
			Server.setConnectionStatus("Server connection too slow...");
		
			setTimeout("Server.run_next();",3000);
*/

};

Server.setConnectionStatus = function(msg){ //Set connection status
    var o = $("site_message");
    if(xo.isDef(msg))
	o.innerHTML = msg;
    else
	o.innerHTML = "";

};

Server.requestSessionInfo = function(){ //Get the User Prefix
    // var query = "cmd=whoami&argv=&callback=Server.cb_whoami";
    // Server.queue.push(query);
    // Server.run_next();
    Server.request("cmd=whoami&argv=&callback=Server.cb_whoami",{"success": Server.reqSuccess, "failure": Server.reqFailure});
};


Server.getargs_setItem = function(key, index, nocallback){
    if(!store.exists(key)) xo.log("Server.setargs_set_item("+key+","+index+")", "store.__NODES[key] undefined");
	
    var query = "cmd" + index + "=SET" + "&argv" + index + "_key=" + key + "&argv" + index + "_val=" + encodeURIComponent(Storage.serialize(key));

    if (!nocallback) {
	query = query + "&callback" + index + "=Server.cb_setItem";	
    }
    
    return query;
}


Server.getargs_deleteItem = function(key, index){
    var query = "cmd" + index + "=DEL"
	+ "&argv" + index + "=" + key + "&callback" + index +"=Server.cb_deleteItem";
    return query;
}

//Function to run before running each callback
Server.cb_before = function(){
	//xo.log("callbackfrom request " + currentRequest);	
	Server.remainingCallbackCount--;
	if(Server.remainingCallbackCount == 0){
		Server.setConnectionStatus();
		Server.currentRequest = "";		
	}
	Server.run_next();
};

//Callback: User Prefix received
Server.cb_whoami = function(json){
    Server.cb_before();	
	
    if(json["user_id"] == "0") return xo.log("Server.cb_whoami","userid=0");
	
    var current_session_id = json["session_id"];
    Server.userPrefix = "S." + json["user_id"] + ".";
    Server.sessionID = current_session_id;
    Server.rootID_key = Server.userPrefix + "rootid";
	


    if(json["session_id"]=="1"){
	//WARNING DELETE IT BEFORE RELEASING!
	//@DEBUG
	xo.log("CLEAR LOCAL STORAGE!");
	// delete store.__NODES
	// store.__NODES = {};
	localStorage.clear();
    }
    
    // TODO: add a realistic since parameter that would be stored in localStorage
    //if (!localStorage["session_id"] || localStorage["session_id"] < current_session_id - 1) {
	Server.request("cmd=prefix_match&callback=Simplex.loadTree&since=0&argv="+Server.userPrefix,{"success": Server.reqSuccess, "failure": Server.reqFailure, "argument":{"session_id":json["session_id"]}});
    //}

    // Server.queue.push(Server.getargs_getItem(Server.rootID_key,""));
    // Server.run_next();

    Simplex.__ready = 1;

}



//Callback: Item set
Server.cb_setItem = function(json){
	Server.cb_before();	
};

//Callback: Item deleted
Server.cb_deleteItem = function(json){ //Callback: item deleted
	Server.cb_before();	
};

xo.exportSymbol("Server", Server);
xo.exportProperty(Server, "run_next", Server.run_next);
xo.exportProperty(Server, "cb_whoami", Server.cb_whoami);
xo.exportProperty(Server, "cb_setItem", Server.cb_setItem);
xo.exportProperty(Server, "cb_deleteItem", Server.cb_deleteItem);

//=============================================STORAGE=============================================
//This namespace is responsible for the LOCAL and IN-MEMORY storage of the items 
var Storage = Storage || {};


Storage.valueOf = function(input) {
    // TODO: replace pipe char in the given input
    return xo.isDef(input) ? input : "";
}

Storage.serialize = function(id) {

    var o = store.find(id);

    return o[_id_] 
	+ "\t" + Storage.valueOf(o[_text_])
	+ "\t" + Storage.valueOf(o[_parent_])
	+ "\t" + Storage.valueOf(o[_prev_])
	+ "\t" + Storage.valueOf(o[_next_])
	+ "\t" + Storage.valueOf(o[_prevSibling_])
	+ "\t" + Storage.valueOf(o[_nextSibling_])
	+ "\t" + Storage.valueOf(o[_collapsed_])
	+ "\t" + Storage.valueOf(o[_completed_])
	+ "\t" + Storage.valueOf(o[_noted_])
	+ "\t" + Storage.valueOf(o[_note_]);

}

Storage.deserialize = function(str) {

    var parts = str.split("\t");

    var o = [
	/* "id" :          */ parts[_id_],
	/* "text" :        */ parts[_text_],
	/* "parent" :      */ parts[_parent_],
	/* "prev" :        */ parts[_prev_],
	/* "next" :        */ parts[_next_],
	/* "prevSibling" : */ parts[_prevSibling_],
	/* "nextSibling" : */ parts[_nextSibling_],
	/* "collapsed" :   */ (parts[_collapsed_] == "1" ? 1 : 0),
	/* "completed" :   */ (parts[_completed_] == "1" ? 1 : 0),
	/* "noted" :       */ (parts[_noted_] == "1" ? 1 : 0),
	/* "note" :        */ parts[_note_]
    ];

    // xo.log("id: " + o[_id_] + " collapsed: " + o[_collapsed_]);


    // _parent_, _prev_, _next_, _prevSibling_, and _nextSibling
    for (var i=2; i <= 6; i++) {
	if (o[i]=="") o[i] = undefined;
    }

    return o;

}


//Update storage: if item changed, save it in memory and ask the server to do so
//@key: Key of the item to save
//[@do_not_update_adjacent]: Whether or not to try updating adjacent items
Storage.update_item = function(key, do_not_update_adjacent){
    xo.log("WE ARE STILL CALLING update_item. key=" +key);
};

//Deletes item from memory and asks the server to do so too
//Deletes all children + updates adjacent(previous and next)
//@key: item of item to be deleted






Storage.setItem = function(id,obj) {
    var objLocalStorage = window.localStorage[id];
    if (objLocalStorage) {
	versionLocalStorage = objLocalStorage["version"];

	// IGNORE ME FOR NOW
	var version = obj["version"];
	if (version < versionLocalStorage) {
	    xo.log("we've got a newer version for: " + id);
	    // store.find(id) = objLocalStorage;
	    return;
	}
    }
    // TODO: this is not exactly right
    // both versions may have changed
    // e.g. local version via offline usage
    // whereas server version via online usage from another computer
    // we need conflict resolution here - maybe, ask the user about it
    // though here we give preference to the online version (the one that came from server)
    window.localStorage[id] = obj;
    store.__NODES[id] = obj;
};



// Undo/Redo

var _CMD_CREATE_      = 0;
var _CMD_UPDATE_TEXT_ = 1;
var _CMD_UPDATE_NOTE_ = 2;
var _CMD_EXPAND_      = 3;
var _CMD_COLLAPSE_    = 4;
var _CMD_INDENT_      = 5;
var _CMD_OUTDENT_     = 6;
var _CMD_TOGGLE_DONE_ = 7;
var _CMD_ENTER_       = 8;
var _CMD_MOVE_UP_     = 9;
var _CMD_MOVE_DOWN_   = 10;
var _CMD_DELETE_      = 11;

var _OP_CREATE_ = 0;
var _OP_UPDATE_ = 1;
var _OP_DELETE_ = 2;

var undoredo = {};
undoredo.CURRENT_ACTION = [];
undoredo.CURRENT_BATCH = [{},{},{}];
undoredo.UNDO_STACK = [];
undoredo.REDO_STACK = [];

undoredo.init = function() {
    var el = DH.createDom({'tag':'button','style':'position:absolute;top:100px;left:100px;','html':'undo'},document.body,true);
    xo.Event.on(el,'click',undoredo.undo);
    undoredo.clearCurrent();
};

undoredo.clearCurrent = function() {
    undoredo.CURRENT_ACTION = [];
    undoredo.CURRENT_BATCH = [{},{},{}];
};

undoredo.startBatch = function(actionType,actionArgs) {
    if (!undoredo.emptyCurrent())
	xo.log('ERROR: unfinished operation batch while trying to start a new batch');
    else
	undoredo.CURRENT_ACTION = [actionType,actionArgs];

};

undoredo.finishBatch = function(nocapture) {
    // do not capture (for undo purposes) inverted operations
    if (!nocapture) {
	undoredo.UNDO_STACK.push(undoredo.CURRENT_ACTION);
    }
    Server.syncBatch(undoredo.CURRENT_BATCH);
    undoredo.clearCurrent();
};

undoredo.undo = function(event) {

    xo.Event.stopEvent(event);

    if (undoredo.UNDO_STACK.length) {
	var action = undoredo.UNDO_STACK.pop();
	var actionType = action[0];
	var actionArgs = action[1];

	undoredo.invert(actionType,actionArgs);
    }

};

undoredo.invert = function(type,args) {

    xo.log('invert action ' + type + ' on object with args= ' + xo.encode(args));

    store.startBatch();

    if (type == _CMD_UPDATE_TEXT_) {
	var id = args[0];
	var value = args[1];
	store.update(store.find(id),_text_,value);
	// set div content
	var contentEl = Simplex.textDom($(id));
	Simplex.setContent(contentEl,value);
	Simplex.edit(id,"end",value);
    } else if (type == _CMD_MOVE_UP_) {
	var id = args[0];
	var prevLevel = args[1];
	var currLevel = args[2];
	Simplex.moveDown($(id),true);  // nocapture
	if (prevLevel<currLevel) {
	    Simplex.indent(id,true);
	} else if (prevLevel>currLevel) {
	    Simplex.outdent(id,true);
	}
    } else if (type == _CMD_MOVE_DOWN_) {
	var id = args[0];
	var nextLevel = args[1];
	var currLevel = args[2];
	Simplex.moveUp($(id),true);    // nocapture
	if (nextLevel<currLevel) {
	    Simplex.outdent(id,true);
	} else if (nextLevel>currLevel) {
	    Simplex.indent(id,true);
	}
    } else if (type == _CMD_INDENT_) {
	Simplex.outdent(id,true);
    } else if (type == _CMD_OUTDENT_) {
	Simplex.indent(id,true);
    } else if (type == _CMD_EXPAND_) {
	Simplex.collapse($(id),true);
    } else if (type == _CMD_COLLAPSE_) {
	Simplex.expand($(id),true);
    } else if (type == _CMD_TOGGLE_DONE_) {
	Simplex.toggleDone($(id),true);
    }
    store.finishBatch(true);

}

undoredo.redo = function() {};

undoredo.emptyCurrent = function() {
    return undoredo.CURRENT_ACTION=[];
}
undoredo.addUpdateOperationToCurrentBatch = function(o,key) {
    var delta = undoredo.CURRENT_BATCH[_OP_UPDATE_][o[_id_]] || [];
    delta.push([key, xo.isDef(o[key]) ? o[key] : ""]);
    undoredo.CURRENT_BATCH[_OP_UPDATE_][o[_id_]] = delta;
}
undoredo.addCreateOperationToCurrentBatch = function(o) {
    undoredo.CURRENT_BATCH[_OP_CREATE_][o[_id_]] = o;
}
undoredo.addDeleteOperationToCurrentBatch = function(o) {
    undoredo.CURRENT_BATCH[_OP_DELETE_][o[_id_]] = o;
}


// TODO: push these batches on a stack and synchronize later, i.e. during save/autosave (or an idle time)
Server.syncBatch = function(batch) {

    Simplex.saveButton_saving();

    Server.batch_new();
    var seen = {};

    for(var id in batch[_OP_DELETE_]) {
	if (!seen[id]) {
	    Server.batch_include("DEL", id);
	    seen[id] = 1;  // no need to SET an item after it has been deleted
	}
    }

    for(var id in batch[_OP_CREATE_]) {
	if (!seen[id]) {
	    Server.batch_include("SET",id);
	    seen[id] = 1;
	}
    }

    for(var id in batch[_OP_UPDATE_]) {
	if (!seen[id]) {
	    Server.batch_include("SET",id);
	    seen[id] = 1;
	}
    }

    Server.batch_send("Simplex.saved");

}


var store = {};
store.__NODES = {};

store.init = function() {
    store.__NODES = {};
}
store.startBatch = function(actionType,actionArgs) {
    undoredo.startBatch(actionType,actionArgs);
}
store.finishBatch = function(nocapture) {
    undoredo.finishBatch(nocapture);
}
store.create = function(o) {
    store.__NODES[o[_id_]] = o;
    undoredo.addCreateOperationToCurrentBatch(o);
}
store.update = function(o, key, value) {

    // first save current value for undo purposes
    undoredo.addUpdateOperationToCurrentBatch(o, key);

    // then update value
    o[key] = value;

    // TODO: o[_version_] = Simplex.now();

};
store.updateIf = function(o, key, value) {
    if (o) store.update(o, key, value);
};
store.remove = function(o) {
    xo.log('store.remove ' +  xo.encode(o));

    // save current value for undo purposes
    undoredo.addDeleteOperationToCurrentBatch(o);

    // then delete object
    var id = o[_id_];

    try {
	delete store.__NODES[id];
    } catch (ex) {
	store.__NODES[id] = undefined;
    }

}
store.exists = function(id) {
    return xo.isDef(store.find(id));
}
store.set = function(id,o) {
    store.__NODES[id] = o;
}
store.find = function(id) {
    return store.__NODES[id];
}

//=============================================TEXTAREA FUNCTIONS=============================================
//Textareas move over the div element that contains the item text/note (performance purposes)
//A textarea acts as the ACTIVE textarea - the one where the user can type text and edit
//A secondary textarea just MOVES over the desired text/note div (mouseover)
//When the user clicks on the secondary textarea (over the desired item text/note), the textarea roles get swapped.
//The clicked "secondary" textarea becomes the "active" textarea and the former "active" textarea becomes the "secondary" textarea.
//[Note that 2 textareas are required as the user needs to set the caret where he/she clicked]

Simplex.textPri;
Simplex.textPriDiv; //This is the related text/note div
Simplex.textSec;
Simplex.textSecDiv; //This is the related text/note div

Simplex.textarea_swapRoles = function(nosave){ //This function swaps the textareas' roles.
    // Simplex.__hovered = Simplex.projectDom(Simplex.textPriDiv);

    if (!nosave) Simplex.textarea_save();
	
    //Swap primary/secondary
    var tmp = Simplex.textPri;
    Simplex.textPri = Simplex.textSec;
    Simplex.textSec = tmp;

    var primaryEditorEl = Simplex.textPri.parentNode;
    var secondaryEditorEl = Simplex.textSec.parentNode;

    DH.removeClass(primaryEditorEl, ["hovered","lastEdited"]);
    DH.removeClass(secondaryEditorEl, "fixed");
    DH.addClass(secondaryEditorEl, "hovered");
    DH.addClass(primaryEditorEl, ["fixed","lastEdited"]);


    tmp = Simplex.textPriDiv;
    Simplex.textPriDiv = Simplex.textSecDiv;
    Simplex.textSecDiv = tmp;

    // hide textEl
    DH.removeClass(Simplex.textSecDiv, "editing");
    DH.addClass(Simplex.textPriDiv, "editing");

};


Simplex.getXY = function(el) {
    if (!Simplex.__elPosVisible) {
	Simplex.__elPosVisible = xo.Dom.getXY($("visible"));
    }
    var elPosEl = xo.Dom.getXY(el);
    var elPos = [elPosEl[0]-Simplex.__elPosVisible[0],elPosEl[1]-Simplex.__elPosVisible[1]];
    return elPos;
}

//Move the (secondary) textarea to <el>
Simplex.textarea_moveTo = function(el){
    if(!Simplex.util_isItemText(el) && !Simplex.isNoteContentDom(el)){
    	xo.log("textarea_moveTo: given el is not a textDom / noteDom: ");
	xo.log(el);
    	return;
    }

    if(el == Simplex.textSecDiv || el == Simplex.textPriDiv) return; //Textarea already there, so do move nothing

    //Move the current item's text to the textarea, move it there, resize it, etc
    var projectEl = Simplex.projectDom(el);
    var projectId = projectEl["id"];

    if (projectId == "simplex") return;


    var ta = Simplex.textSec;
    var editorEl = ta.parentNode;

    Simplex.textSecDiv = el;
    editorEl.setAttribute("editId",projectId);
    ta.style.display = "none";
    ta.value = "";

    var elPos = Simplex.getXY(el);

    // Note: Used to be DH.moveBefore(el,editorEl);


    // editorEl.style.display = "none";
    editorEl.style.left = elPos[0] + "px";
    editorEl.style.top = elPos[1] + "px";


    ta.value = Simplex.getText(projectId);

    editorEl.style.width = (el.clientWidth || el.offsetWidth ) + "px";
    editorEl.style.height = (el.clientHeight || el.offsetHeight || 20) + "px";

    Simplex.clearEditorClasses(editorEl);
    DH.addClass(editorEl,"hovered");
    Simplex.setEditorClasses(editorEl,projectEl,el);

    editorEl.style.display = "block";
    ta.style.display = "block";
};



Simplex.redrawEditors = function(){ //Redraw the textareas: resize to fill the window
    Simplex.redrawEditor(Simplex.textPri.parentNode,Simplex.textPriDiv);
    Simplex.redrawEditor(Simplex.textSec.parentNode,Simplex.textSecDiv);
};

Simplex.redrawEditor = function (editorEl,contentEl) {
    if (!contentEl) return;

    var elPosPri = Simplex.getXY(contentEl);
    editorEl.style.left = elPosPri[0] + "px";
    editorEl.style.top = elPosPri[1] + "px";

    editorEl.style.width = (contentEl.clientWidth || contentEl.offsetWidth) + "px";
    editorEl.style.height = (contentEl.clientHeight || contentEl.offsetHeight) + "px";

    Simplex.setEditorClasses(editorEl,$(editorEl.getAttribute("editId")),contentEl);
};

Simplex.edit = function(id,pos,newtext) {
    var el = $(id);

    var projectEl = Simplex.projectDom(el);
    if (DH.hasClass(projectEl,"parent")) {
	Simplex.zoomTo(projectEl["id"]);
    }

    var textEl = Simplex.textDom(el);
    Simplex.textarea_edit(textEl,pos || "beginning",newtext);
};

//Set editting item (set focus)
//@el: Item or Note to focus to
//[@pos]: Set caret to that pos [numeric value, beginning, end]
//[@newtext]: Set the NEW text for the item and save it
Simplex.textarea_edit = function(el, pos, newtext){ //Set the secondary area as EDITABLE (active) (swap roles and focus)
    if (!el) return;
    if (el != Simplex.textPriDiv) {

	// xo.log(el.parentNode.parentNode);

	Simplex.textarea_save(); // save PREVIOUS focused item
	// xo.log('after textarea_save');
	Simplex.textarea_moveTo(el); //Move the (secondary) textarea there
	// xo.log('after textarea_moveTo');
	Simplex.textarea_swapRoles(); //Set is as active (swap Roles) (make it primary)
	// xo.log('after textarea_swapRoles');
    }

    // xo.log(Simplex.textPri);

    Simplex.textPri.focus();

    if(xo.isDef(newtext)){
    	Simplex.textPri.value = newtext;
    	Simplex.textarea_save(); //Save instantly!
    }

    if(pos == "beginning")
    	Simplex.setCaret(Simplex.textPri, 0);
    else if(pos == "end")    		
    	Simplex.setCaret(Simplex.textPri, Simplex.textPri.value.length);
    else
    	Simplex.setCaret(Simplex.textPri, pos);


};

Simplex.handleMouseClick = function(e){ //Swap roles when clicking on the secondary textarea
    if(e.target == Simplex.textSec) {
	// var projectId = e.target.getAttribute("editId");
	// var projectEl = $(projectId);
	// var projectEl = Simplex.projectDom(e.target);
	// if (DH.hasClass(projectEl,"parent")) {
	//    Simplex.zoomTo(projectEl["id"]);
	//}
	Simplex.textarea_swapRoles();
    }
};


Simplex.handleMoveHandleMouseDown = function(e,target,options) {
    xo.Event.stopEvent(e);

    var projectEl = Simplex.projectDom(e.target);
    Simplex.__dragProjectEl = projectEl;
    DH.addClass(projectEl,"moving");

    // TODO: addClass ui-droppable to all dropTarget elements
    xo.log("move handle mouse down: " + projectEl["id"]);
    // document.onmousemove = Simplex.handleMoveHandleMouseMove;
    $("simplex").style.cursor = "move";
    document.onmouseup = Simplex.handleMoveHandleMouseUp;
};

Simplex.handleMoveHandleMouseMove = function(e) {
    if (Simplex.__dragProjectEl) {
	xo.Event.stopEvent(e);
	var projectEl = Simplex.projectDom(e.target);
	if (!projectEl || projectEl["id"]=="simplex") return;
	DH.moveBefore(projectEl,$("sortDrop"));
	return;
    }

};

Simplex.handleMoveHandleMouseUp = function(e,target,options) {
    if (Simplex.__dragProjectEl) {

	Simplex.hideControls();


	DH.removeClass(Simplex.__dragProjectEl,"moving");
	xo.log(e.target);
	xo.Event.stopEvent(e);
	var sortDropEl = $("sortDrop");
	var projectEl = sortDropEl.nextSibling;
	DH.moveLast($("hidden"),sortDropEl);
	var objSource = store.find(Simplex.__dragProjectEl["id"]);
	var objTarget = store.find(projectEl['id']);
	if (Simplex.isAncestorOf(objTarget, objSource)) {
	    xo.log('NOTICE: cannot drag&drop to a child node');
	} else {
	    xo.log("move " + Simplex.__dragProjectEl["id"] + " before " + projectEl['id']);
	}
	// TODO: removeClass ui-droppable to all dropTarget elements
	Simplex.__dragProjectEl = undefined;
	$("simplex").style.cursor = "auto";
	document.onmouseup = undefined;
    }
};

Simplex.textareaToPriDivSync = function() {

    if(!Simplex.textPriDiv) {
	xo.log('ERROR: no textPriDiv, why?');
	return;
    }
    Simplex.setContent(Simplex.textPriDiv, Simplex.textPri.value);

}

// Copy the primary textarea's text to the related div (save)
Simplex.textarea_save = function(noSyncPriDiv,objCurr){

    var ta = Simplex.textPri;
    var editorEl = ta.parentNode;
    var id = editorEl.getAttribute("editId");
    var content = ta.value;

    if (!noSyncPriDiv) {
	Simplex.textareaToPriDivSync();
    }

    if (!objCurr) {
	objCurr = store.find(id);
    }

    var changed = false;
    if (DH.hasClass(editorEl,"nameEditor")) {
	if (content != objCurr[_text_]) {
	    store.startBatch(_CMD_UPDATE_TEXT_,[id,objCurr[_text_]]);
	    store.update(objCurr, _text_, content);
	    store.finishBatch();
	}
    } else if (DH.hasClass(editorEl,"noteEditor")) {
	if (content != objCurr[_note_]) {
	    store.startBatch(_CMD_UPDATE_NOTE_,[id,objCurr[_note_]]);
	    store.update(objCurr, _note_, content);
	    store.finishBatch();
	}
    }

};

Simplex.save = function() {

    // TODO: check if we are connected

    if (Simplex.__saveButtonState != _saveButton_saveNow_) return;

    Simplex.textarea_save();    // starts its own batch

    // if (!Simplex.__todelete.length && !Simplex.__toupdate.length) return;

    // Simplex.saveButton_saving();

};

Simplex.autosave = function(){ //Copy the primary textarea's text to the related div (save) -- EVERY FEW SECONDS WHILE EDITING
    // xo.log('autosave');
    Simplex.save();
    Simplex.timeout["autosave"] = window.setTimeout("Simplex.autosave();", "5000");

};

Simplex.saved = function() {
    if (Simplex.__todelete.length == 0 && Simplex.__toupdate.length == 0) {
	Simplex.saveButton_saved();
    }
}


Simplex.setEditorClasses = function(editorEl,projectEl,contentEl) {

    var objCurr = store.find(projectEl["id"]);

    //Copy the related item text/note style
    if(DH.hasClass(contentEl.parentNode,"name")) {
	DH.addClass(editorEl, "nameEditor");
    } else {
	DH.addClass(editorEl, "noteEditor");
    }

    if(DH.hasClass(projectEl,"selected")) {
	DH.addClass(editorEl, "selectedEditor");
    } else {
	// if (!DH.hasClass(projectEl,"parent")) {
	// xo.log('zoomRoot: '+Simplex.__zoomRoot);
	// xo.log('objCurr parent: '+objCurr[_parent_]);
	if (objCurr[_parent_] && objCurr[_parent_] != Simplex.__zoomRoot) 
	    DH.addClass(editorEl,"twoLevelsDownEditor");
	else
	    DH.removeClass(editorEl,"twoLevelsDownEditor");
	//}
    }

    if (DH.hasClass(projectEl,"done")) {
	DH.addClass(editorEl, "doneEditor");
    }

}

Simplex.clearEditorClasses = function(editorEl) {
    DH.removeClass(editorEl,["nameEditor", "noteEditor", "selectedEditor", "doneEditor", "twoLevelsDownEditor"]);
    DH.removeClass(editorEl,["fixed", "hovered"]);
};

//Dispose the textareas in the disposalArea (#textareas div)
Simplex.textareas_dispose = function(nosave){
    if (!nosave) Simplex.textarea_save();

    if(Simplex.textPriDiv) {
	DH.removeClass(Simplex.textPriDiv, "editing");
	// Simplex.textPriDiv.style.width = "0px";
	// Simplex.textPriDiv.style.height = "0px";
    }
    Simplex.textPriDiv = undefined;

    if(Simplex.textSecDiv) {
	DH.removeClass(Simplex.textSecDiv, "editing");
	// Simplex.textSecDiv.style.width = "0px";
	// Simplex.textSecDiv.style.height = "0px";
    }
    Simplex.textSecDiv = undefined;

    Simplex.textPri.style.display = "none";
    Simplex.textSec.style.display = "none";

    Simplex.clearEditorClasses(Simplex.textPri);
    Simplex.clearEditorClasses(Simplex.textSec);

}

//Get the caret position for the specified el
Simplex.getCaret = function(el) {
    var pos = 0;
    if (document.selection) {
	el.focus();
	var sel = document.selection.createRange();
	sel.moveStart('character', -el.value.length);
	pos = sel.text.length;
    } else if (el.selectionStart || el.selectionStart == '0')
	pos = el.selectionStart;

    return pos;
};

//Set the caret position for the specified el to pos
Simplex.setCaret = function(el, pos) {
    if (!el) return;

    if (el.setSelectionRange) {
	el.focus();
	el.setSelectionRange(pos, pos);
    } else if (el.createTextRange) {
	el.focus();
	var range = el.createTextRange();
	range.collapse(true);
	range.moveEnd('character', pos);
	range.moveStart('character', pos);
	range.select();
    }
};

//=============================================EVENT FUNCTIONS=============================================

Simplex.placeControls = function(nameEl){
    nameEl.appendChild($("controls"));
}
Simplex.hideControls = function(){ 
    if (Simplex.__moveHovered) {
	DH.removeClass(Simplex.__moveHovered, ["highlighted","moveHovered"]);
	Simplex.__moveHovered = undefined;
    }
    $("hidden").appendChild($("controls"));
}




//Mouseover Container(and all children)
//If mouseover an item/note, then move the secondary textarea and the menu there
Simplex.handleMouseOver = function(e, target, options){

    if (Simplex.__dragProjectEl) {
	Simplex.handleMoveHandleMouseMove(e);
	return;
    }

    // if over tag or link, hide controls and set __overTag flag
    if (DH.hasClass(e.target,"contentTagClickable") || DH.hasClass(e.target,"contentLink")) {
	Simplex.__overTag = 1;
	Simplex.hideMenu();
	Simplex.hideControls();
	// xo.log("over tag");
	return;
    } else {
	if (Simplex.__hovered) {
	    Simplex.__overTag = 0;
	}
    }


    // check if we are still over the menu
    if (Simplex.__overMenu) {
	if (DH.isAncestorOf(e.target,$("controls"))) {
	    Simplex.__overMenu=1;
	} else {
	    //xo.log(e.target);
	    Simplex.__overMenu=0;
	    Simplex.hideMenu();
	}
    }

    var isMoveHandle = DH.hasClass(e.target,"ui-draggable");
    var isBullet = DH.hasClass(e.target,"bullet");
    var isContent = DH.hasClass(e.target,"content");
    var isProject = DH.hasClass(e.target,"project");

    if (!isProject && !isContent && !isBullet && !isMoveHandle) return;

    var projectEl = Simplex.projectDom(e.target);
    if (!projectEl) return;

    // if over context bar, do nothing
    if (DH.hasClass(projectEl,"parent")) return;

    // TODO: distinguish between the case when editorEl is nameEditor and noteEditor
    if (Simplex.__hovered != projectEl) {

	Simplex.hideMenu();

	var contentEl = Simplex.textDom(projectEl);
	var nameEl = Simplex.nameDom(projectEl);

	Simplex.placeControls(nameEl);
	Simplex.textarea_moveTo(contentEl);
	
	DH.removeClass(Simplex.__hovered_nameEl,"hovered");
	DH.removeClass(Simplex.__hovered_contentEl,"hovered");
	
	Simplex.__hovered = projectEl;
	Simplex.__hovered_nameEl = nameEl;
	Simplex.__hovered_contentEl = contentEl;
	
	DH.addClass(contentEl,"hovered");
	DH.addClass(nameEl,"hovered");
    }

    if (isBullet) {
	Simplex.showMenu();
    }

    if (isMoveHandle) {
	DH.addClass(projectEl,["highlighted","moveHovered"]);
	Simplex.__moveHovered=projectEl;
    } else {
	if (Simplex.__moveHovered) {
	    DH.removeClass(projectEl, ["highlighted","moveHovered"]);
	    Simplex.__moveHovered=undefined;
	}
    }




}


Simplex.showMenu = function() {
    Simplex.__overMenu = 1;
    if (Simplex.__hovered)
	DH.addClass(Simplex.__hovered,"highlighted");
    DH.addClass($("expandButton"),"controlsShow");
    DH.addClass($("controlsLeft"),"hovered");
}

Simplex.hideMenu = function() {
    Simplex.__overMenu = 0;
    DH.removeClass($("expandButton"),"controlsShow");
    DH.removeClass($("controlsLeft"),"hovered");
    if (Simplex.__hovered)
	DH.removeClass(Simplex.__hovered,"highlighted");
}

//Create new item when clicking on the "Create new item" button
Simplex.handleAddButton = function(e,target,options){
    if (!Simplex.__ready) return;

    var id = Simplex.generateId();
    store.startBatch(_CMD_CREATE_,[id]);

    var prevId, nextId, lastDirectChild;
    var lastLeafObj = store.find(Simplex.__zoomEnd);
    if (lastLeafObj) {
	prevId = lastLeafObj[_id_];
	nextId = lastLeafObj[_next_];
	store.update(lastLeafObj, _next_, id);


	lastDirectChild = Simplex.lastDirectChild(Simplex.__zoomStart);

	var objLastChild = store.find(lastDirectChild);
	store.updateIf(objLastChild, _nextSibling_, id);

	if (!nextId) Simplex.__last = id;
    } else {
	Simplex.__zoomStart = id;
	Simplex.__first = id;
	Simplex.__last = id;
    }

    var obj = [
	/* "id":          */ id,
	/* "text":        */ "",
	/* "parent":      */ Simplex.__zoomRoot,
	/* "prev":        */ prevId,
	/* "next":        */ nextId,
	/* "prevSibling": */ lastDirectChild ? lastDirectChild["id"] : undefined,
	/* "nextSibling": */ undefined,
	/* "collapsed":   */ 0,
	/* "completed":   */ 0,
	/* "noted":       */ 0,
	/* "note":        */ ""
    ];

    store.create(obj);
    Simplex.__zoomEnd = id;
    Simplex.renderItem(id,true); // focus

    store.finishBatch();

};


//Handle key presses
Simplex.handleKeyDown = function(e, target, options) {

    var targetEl = Simplex.textPriDiv;// different than target!
    if(!targetEl)return; //Textarea not associated with any item text/note!	
	
    var ta = e.target;
    var editorEl = ta.parentNode;
    var item = $(editorEl.getAttribute("editId"));
    var textEl = Simplex.textDom(item);

    var isNote = Simplex.util_isEditableNote(textEl);
	
	switch(e.keyCode){
	case xo.Event.ENTER:
	    if (isNote) { 
		if(e.shiftKey){  //Shift+Enter inside note: switch back to main item
		    xo.Event.stopEvent(e);
		    Simplex.textarea_edit(textEl);
		}
	    } else {
		Simplex.handleEnter(e, item, textEl, ta);
	    }
	    Simplex.saveButton_saveNow();
	    break;
	    
	case xo.Event.TAB:	
	    xo.Event.stopEvent(e);
	    var id = item["id"];
	    if(e.shiftKey)
		Simplex.outdent(id);
	    else
		Simplex.indent(id);

	    Simplex.textPri.focus();
	    Simplex.saveButton_saveNow();
	    break;
	    
	case xo.Event.BACKSPACE:
	    Simplex.handleBackspace(e, isNote, item, textEl, ta);
	    Simplex.saveButton_saveNow();
	    break;
	    
	case xo.Event.DELETE:
	    Simplex.handleDelete(e, isNote, item, textEl, ta);
	    Simplex.saveButton_saveNow();
	    break;
	    
	case xo.Event.SPACE:
	    if (e.ctrlKey) {
		xo.Event.stopEvent(e);
		Simplex.toggleCollapseExpand(item);
	    }
	    Simplex.saveButton_saveNow();
	    break;
	    
	case xo.Event.UP:
	case xo.Event.LEFT:
	case xo.Event.DOWN:
	case xo.Event.RIGHT:
	    Simplex.handleArrows(e, isNote, item, textEl, ta);
	    break;
	    
	case xo.Event.S:
	    if (e.ctrlKey) {
		Simplex.save();
		xo.Event.stopEvent(e);
	    }
	    break;
	case xo.Event.M:
	    // open menu
	    // Simplex.event_keypressed_handle_M(e, item);
	    break;
	case xo.Event.HOME:
	    if (e.ctrlKey) Simplex.edit(Simplex.__zoomStart);
	    break;
	case xo.Event.END:
	    if (e.ctrlKey) Simplex.edit(Simplex.__zoomEnd);
	    break;
	case xo.Event.PAGE_UP: 
	    if (e.ctrlKey || e.shiftKey) return;
	    xo.Event.stopEvent(e);
	    Simplex.pageUp(item["id"]);
	    break;
	case xo.Event.PAGE_DOWN:
	    if (e.ctrlKey || e.shiftKey) return;
	    xo.Event.stopEvent(e);
	    Simplex.pageDown(item["id"]);
	    break;
	case xo.Event.Z:
	    if (e.ctrlKey) undoredo.undo(e);
	    break;
	default:
	    // if key is SHIFT, CTRL, ALT 
	    if (e.keyCode == 16 || e.keyCode == 17 || e.keyCode == 18) return;
	    Simplex.saveButton_saveNow();
	    // Simplex.resizeEditors();
	    break;
	}


    if (Storage.isConsistent) Storage.isConsistent();
};

Simplex.resizeEditors = function() {
    // TODO - THIS IS NEEDED FOR ELASTIC TEXTAREA - DO NOT REMOVE
}

Simplex.pageUp = function(id) {
    var scroll = 20;
    var adj = store.find(id);
    var scrollTo = adj;
    while(adj && scroll--){
	scrollTo = adj;
	adj = Simplex.prevVisible(scrollTo[_id_]);
    }
    Simplex.textarea_edit(Simplex.textDom($(scrollTo[_id_])));
};

//Handle the PAGE UP/DOWN keys
Simplex.pageDown = function(id){
    var scroll = 20;
    var adj = store.find(id);
    var scrollTo = adj;
    while(adj && scroll--){
	scrollTo = adj;
	adj = Simplex.nextVisible(scrollTo[_id_]);
    }
    Simplex.textarea_edit(Simplex.textDom($(scrollTo[_id_])));
};

//Handle the M key
Simplex.event_keypressed_handle_M = function(e, item){
    if(e.ctrlKey){
	xo.Event.stopEvent(e);
	// Simplex.showMenu();
    }
}


Simplex.addNote = function(projectEl) {
    if (DH.hasClass(projectEl,"noted")) return;

    var projectId = projectEl["id"];
    var noteEl = Simplex.noteDom(projectEl);
    var noteContentEl = Simplex.noteContentDom(noteEl);

    // xo.log(noteEl);
    // xo.log(noteContentEl);

    DH.addClass(projectEl,"noted");
    DH.createDom({"tag":"div","cls":"spacer","html":"."},noteContentEl);

    store.startBatch(_CMD_CREATE_NOTE_,[projectId]);
    var objCurr = store.find(projectId);
    store.update(objCurr, _note_, "");
    store.update(objCurr, _noted_, 1);
    store.finishBatch();

}

Simplex.editNote = function(projectEl) {
    if (!projectEl) return;
    var objCurr = store.find(projectEl["id"]);
    if (!objCurr) return;

    var noteEl = Simplex.noteDom(projectEl);
    var noteContentEl = Simplex.noteContentDom(noteEl);
    Simplex.textarea_edit(noteContentEl,"beginning",objCurr[_note_]);
}

// Handles the ENTER key
Simplex.handleEnter = function(e, item, itemtext, textarea){
    
    // Shift+Enter: Add/Edit note
    if(e.shiftKey){
	xo.Event.stopEvent(e);
	var editorEl = textarea.parentNode;
	if (DH.hasClass(editorEl,"noteEditor")) {
	    Simplex.edit(item["id"]);
	} else if (DH.hasClass(editorEl,"nameEditor")) {
	    xo.Event.stopEvent(e);
	    var noteContentEl = Simplex.addNote(item);  // starts its own batch
	    Simplex.editNote(item)
	}
	return;
    } else if (e.ctrlKey) {  //Control+Enter: Switch Completed sate
	xo.Event.stopEvent(e);
	Simplex.toggleDone(item);  // starts its own batch
	return;
    }

    var editorEl = textarea.parentNode;
    if (DH.hasClass(editorEl,"noteEditor")) {
	// let it propagate the event
	return;
    }


    xo.Event.stopEvent(e);

    // make sure that what the user just wrote
    // still persists (if enter is pressed before sync-ing)
    // sync textarea with underlying object
    Simplex.textarea_save();  // noSyncPriDiv=false


    // Add new item, moving text like using enter to create a new paragraph in a text editor
    var pos = Simplex.getCaret(textarea);
    var len = textarea.value.length;
    var objCurr = store.find(item["id"]);

    if (pos==0 && len==0 && objCurr[_parent_] != Simplex.__zoomRoot) {

	Simplex.outdent(objCurr[_id_]);  // starts its own batch

	// HERE: not sure if dispose is needed - check
	Simplex.textareas_dispose();     // calls textarea_save
	Simplex.edit(objCurr[_id_], "beginning");
	return;
    }



    var id = Simplex.generateId();
    store.startBatch(_CMD_ENTER_,[id]);


    var hasChildren = Simplex.hasChildren(objCurr);
    var hasNote = Simplex.hasNote(objCurr);
    var becomeFirstChild = (hasChildren && pos == len && !objCurr[_collapsed_]) ? true : false;
    var becomePrevSibling = (pos==0 || (pos!=len && (hasChildren || hasNote))) ? true : false;
    var editId;

    // xo.log(becomeFirstChild ? "becomeFirstChild" : becomePrevSibling ? "becomePrevSibling" : "becomeNextSibling");

    if (becomeFirstChild) {

	var obj = [
	    /* "id":          */ id,
	    /* "text":        */ "",
	    /* "parent":      */ objCurr[_id_],
	    /* "prev":        */ objCurr[_id_],
	    /* "next":        */ objCurr[_next_],
	    /* "prevSibling": */ undefined,
	    /* "nextSibling": */ objCurr[_next_],
	    /* "collapsed":   */ 0,
	    /* "completed":   */ 0,
	    /* "noted":       */ 0,
	    /* "note":        */ ""
	];

	store.create(obj);

	// by definition of becomeFirstChild, objCurr has children
	var objFirst = store.find(objCurr[_next_]);  // objCurr["firstChild"]
	store.update(objFirst, _prev_, id);
	store.update(objFirst, _prevSibling_, id);
	store.update(objCurr, _next_, id);

	Simplex.renderItem(id,true);  // focus = true
	editId = id;

    } else {

	if (becomePrevSibling) {

	    var obj = [
		/* "id":          */ id,
		/* "text":        */ objCurr[_text_].substr(0,pos),
		/* "parent":      */ objCurr[_parent_],
		/* "prev":        */ objCurr[_prev_],
		/* "next":        */ objCurr[_id_],
		/* "prevSibling": */ objCurr[_prevSibling_],
		/* "nextSibling": */ objCurr[_id_],
		/* "collapsed":   */ 0,
		/* "completed":   */ 0,
	        /* "noted":       */ 0,
	        /* "note":        */ ""
	    ];
	    store.create(obj);


	    var objPrevSibling = store.find(objCurr[_prevSibling_]);
	    store.updateIf(objPrevSibling, _nextSibling_, id);

	    var objPrev = store.find(objCurr[_prev_]);
	    store.updateIf(objPrev, _next_, id);

	    store.update(objCurr, _text_, objCurr[_text_].substr(pos));
	    store.update(objCurr, _prev_, id);
	    store.update(objCurr, _prevSibling_, id);
	    
	    // TODO: textarea.value = objCurr[_text_];
	    textarea.value = textarea.value.substr(pos);
	    Simplex.setContent(itemtext, textarea.value);

	    Simplex.renderItem(id);

	    editId = objCurr[_id_];

	} else {

	    // becomeNextSibling

	    var objCurrLastLeaf = Simplex.lastLeaf(objCurr[_id_]) || objCurr;
	    var objNextNonChild = store.find(objCurrLastLeaf[_next_]);
	    var objNextSibling = store.find(objCurr[_nextSibling_]);

	    if (objCurrLastLeaf[_id_] == Simplex.__zoomEnd) {
		// xo.log("handleEnter: __zoomEnd change to " + id);
		Simplex.__zoomEnd = id;
		if (objCurrLastLeaf[_next_]=="") Simplex.__last = id;
	    }

	    var obj = [
		/* "id":          */ id,
		/* "text":        */ objCurr[_text_].substr(pos),
		/* "parent":      */ objCurr[_parent_],
		/* "prev":        */ objCurrLastLeaf[_id_],
		/* "next":        */ objCurrLastLeaf[_next_],
		/* "prevSibling": */ objCurr[_id_],
		/* "nextSibling": */ objCurr[_nextSibling_],
		/* "collapsed":   */ 0,
		/* "completed":   */ 0,
		/* "noted":       */ 0,
		/* "note":        */ ""
	    ];
	    store.create(obj);

	    store.update(objCurr, _text_, objCurr[_text_].substr(0,pos));
	    store.update(objCurr, _nextSibling_, id);
	    store.updateIf(objNextNonChild, _prev_, id);
	    store.updateIf(objNextSibling, _prevSibling_, id);
	    store.updateIf(objCurrLastLeaf, _next_, id);

	    // TODO: textarea.value = objCurr[_text_];
	    textarea.value = textarea.value.substr(0,pos);
	    Simplex.setContent(itemtext, textarea.value);

	    Simplex.renderItem(id);

	    editId = id;

	}
    }

    store.finishBatch();

    Simplex.textareas_dispose();
    Simplex.edit(editId, "beginning");
    
};


//Handle the BACKSPACE key
Simplex.handleBackspace = function(e, isNote, item, itemtext, textarea){
    if(isNote){ //Handle backspace for notes
	if((e.ctrlKey && e.shiftKey) || (textarea.value.length == 0)){ //If empty OR CTRL+SHIFT+BACKSPACE, delete the note
	    xo.Event.stopEvent(e);
	    Simplex.item_deleteNote(item);
	    Simplex.textarea_edit(Simplex.textDom(item), "end");
	    // TODO - HERE: 
	    Storage.update_item(item["id"]);
	    return;
	}
	return;
    }
	
    if(e.ctrlKey && e.shiftKey){  // Control+Backspace: Delete item(and children, if any)
	xo.Event.stopEvent(e);
	var deleteId = item["id"];
	if (deleteId == Simplex.__zoomRoot) return;
	Simplex.remove(deleteId);
	return;
    }


    var objCurr = store.find(item["id"]);
    var objPrevSibling = store.find(objCurr[_prevSibling_]);
    if (objPrevSibling && Simplex.getCaret(textarea) == 0 && !Simplex.hasNote(objPrevSibling) && !Simplex.hasChildren(objPrevSibling)) {
	xo.Event.stopEvent(e);
	var len = objPrevSibling[_text_].length;
	Simplex.textarea_save(true,objCurr); // noSyncPriDiv=true
	var text = objPrevSibling[_text_] + objCurr[_text_];
	Simplex.remove(objPrevSibling[_id_],true);  // noedit = true
	Simplex.textarea_edit(Simplex.textDom($(objCurr[_id_])), len, text);
    }

};

Simplex.hasNote = function(obj) {
    return (obj && obj[_noted_]);
};

//Handle the DELETE key
Simplex.handleDelete = function(e, isNote, item, itemtext, textarea){
    if(isNote) return;

    var objCurr = store.find(item["id"]);
    if (Simplex.getCaret(textarea) == textarea.value.length && !Simplex.hasNote(objCurr) && !Simplex.hasChildren(objCurr)) {
	var objNextSibling = store.find(objCurr[_nextSibling_]);
	// if (Simplex.hasNote(objNextSibling) || Simplex.hasChildren(objNextSibling)) return;

	// If caret at the end item does not have children or a note
	// and nextSibling doesn't have children or a note adjacent below does not have a note, MERGE
	xo.Event.stopEvent(e);
	Simplex.textarea_save(true, objCurr); // noSyncPriDiv=true
	var len = objCurr[_text_].length;
	var text = objCurr[_text_] + objNextSibling[_text_];
	Simplex.remove(objCurr[_id_],true);  // noedit = true
	Simplex.textarea_edit(Simplex.textDom($(objNextSibling[_id_])), len, text);
    }
};

//Moves Item UPWARDS
//@item: A "div.simplex-node" element
Simplex.moveUp = function(curr,nocapture){

    var prev = Simplex.prevVisibleDom(curr);
    if(!prev) return; //no previous item! (this is the first item so it cannot be moved further)
    var objPrev = store.find(prev["id"]);
    var objCurr = store.find(curr["id"]);

    // let us move up if this is the top level - otherwise, do not
    if(!objPrev || objPrev[_id_] == Simplex.__zoomRoot)	return; 

    var prevLevel = Simplex.item_getLevel(prev);
    var currLevel = Simplex.item_getLevel(curr);

    store.startBatch(_CMD_MOVE_UP_, [objCurr[_id_],prevLevel,currLevel]);

    if(prevLevel > currLevel) {
	DH.moveAfter(prev, curr);

	var objPrevSibling = store.find(objCurr[_prevSibling_]);
	var objNextSibling = store.find(objCurr[_nextSibling_]);
	if (objPrevSibling) {

	    store.update(objPrevSibling, _nextSibling_, objCurr[_nextSibling_]);
	}
	if (objNextSibling) {

	    store.update(objNextSibling, _prevSibling_, objCurr[_prevSibling_]);
	}

	var objLastChild = Simplex.lastDirectChild(objPrev[_parent_]);
	if (objLastChild) {

	    store.update(objLastChild, _nextSibling_, objCurr[_id_]);
	    store.update(objCurr, _prevSibling_, objLastChild[_id_]);

	} else {
	    store.update(objCurr,_prevSibling_, undefined);
	}

	store.update(objCurr, _nextSibling_, undefined);
	store.update(objCurr, _parent_, objPrev[_parent_]);

    } else {

	DH.moveBefore(prev, curr);

	// TODO: treat collapsed nodes

	var objCurrLastLeaf = Simplex.lastLeaf(objCurr[_id_]) || objCurr;
	var objPrevLastLeaf = Simplex.lastLeaf(objPrev[_id_]) || objPrev;
	var objNextNonChild = store.find(objCurrLastLeaf[_next_]);
	var objPrevPrev = store.find(objPrev[_prev_]);

	if (objPrev[_id_] == Simplex.__zoomStart) {
	    // xo.log("moveUp: __zoomStart change to " + objCurr[_id_]);
	    Simplex.__zoomStart = objCurr[_id_];
	    if (objCurr[_prev_]=="") Simplex.__first = objCurr[_id_];
	}

	if (objCurrLastLeaf[_id_] == Simplex.__zoomEnd) {
	    // xo.log("moveUp: __zoomEnd change to " + objPrevLastLeaf[_id_]);
	    Simplex.__zoomEnd = objPrevLastLeaf[_id_];
	    if (objPrevLastLeaf[_next_]=="") Simplex.__last = objPrevLastLeaf[_id_];
	}


	// var objNextNonChild = Simplex.nextNonChild(objCurr,false);  // visibleOnly=false
	// xo.log("objNextNonChild: " + xo.encode(objNextNonChild));

	store.updateIf(objPrevPrev, _next_, objCurr[_id_]);

	if (prevLevel < currLevel) {
	    // xo.log('level(prev) < level(curr)');

	    store.update(objPrev, _next_, objCurrLastLeaf[_next_]);
	    store.update(objCurrLastLeaf, _next_, objPrev[_id_]);
	    store.updateIf(objNextNonChild, _prev_, objPrev[_id_]);

	} else {
	    store.update(objPrevLastLeaf, _next_, objCurrLastLeaf[_next_]);
	    store.update(objCurrLastLeaf, _next_, objPrev[_id_]);

	    // xo.log('level(prev) == level(curr)');

	    // if level(prev) == level(curr)
	    // we need this, in case objPrev is a collapsed item with children
	    // objPrevLastLeaf[_next_] = objCurrLastLeaf[_next_];
	    // objCurrLastLeaf[_next_] = objPrev[_id_];

	    store.updateIf(objNextNonChild, _prev_, objPrevLastLeaf[_id_]);

	}

	store.update(objCurr, _prev_, objPrev[_prev_]);
	store.update(objPrev, _prev_, objCurrLastLeaf[_id_]);

	/* update prevSibling/nextSibling */
	var objPrevPrevSibling = store.find(objPrev[_prevSibling_]);
	store.updateIf(objPrevPrevSibling, _nextSibling_, objCurr[_id_]);


	var objNextSibling = store.find(objCurr[_nextSibling_]);
	var objPrevSibling = store.find(objCurr[_prevSibling_]);

	store.updateIf(objNextSibling, _prevSibling_, objCurr[_prevSibling_]);
	store.updateIf(objPrevSibling, _nextSibling_, objCurr[_nextSibling_]);


	store.update(objCurr, _prevSibling_, objPrev[_prevSibling_]);
	store.update(objCurr, _nextSibling_, objPrev[_id_]);
	store.update(objPrev, _prevSibling_, objCurr[_id_]);
	store.update(objCurr, _parent_, objPrev[_parent_]);

    }

    Simplex.redrawEditors();

    store.finishBatch(nocapture);

};


//@curr: a "div.simplex-node" element
Simplex.moveDown = function(curr,nocapture) {

    // TODO: make descend more smooth, 
    // i.e. proceed level by level in the case that
    // level(next) < level(curr)

    if (!curr) return;
    var objCurr = store.find(curr["id"]);

    var objNext = Simplex.nextNonChild(objCurr,true);
    if(!objNext) return; //no previous item! (this is the first item so it cannot be moved further)		
    var next = $(objNext[_id_]);

    // TODO: change this to Simplex.moveAfter
    // if(objNext[_collapsed_]) Simplex.expand(next);

    var objCurrLastLeaf = Simplex.lastLeaf(objCurr[_id_]) || objCurr;
    if(objCurrLastLeaf[_id_] == Simplex.__zoomEnd) return; 

    var nextLevel = Simplex.item_getLevel(next);
    var currLevel = Simplex.item_getLevel(curr);

    store.startBatch(_CMD_MOVE_DOWN_,[objCurr[_id_],nextLevel,currLevel]);

    if(nextLevel < currLevel) {
      DH.moveBefore(next, curr);

      var objPrevSibling = store.find(objCurr[_prevSibling_]);

      store.updateIf(objPrevSibling, _nextSibling_, undefined);

      var objNextPrevSibling = store.find(objNext[_prevSibling_]);
      store.update(objNextPrevSibling, _nextSibling_, objCurr[_id_]);

      // no objNextSibling in this case - objCurr suppose to be last child of parent

      store.update(objCurr, _prevSibling_, objNext[_prevSibling_]);
      store.update(objCurr, _nextSibling_, objNext[_id_]);
      store.update(objNext, _prevSibling_, objCurr[_id_]);

      // TODO: make me a sibling of my parent
      // objCurr[_prevSibling_] = objParent[_id_]
      // objCurr[_nextSibling_] = objParent[_nextSibling_]
      // objParent[_nextSibling_] = objCurr[_id_]
      // objCurr[_parent_] = objParent[_parent_]

      store.update(objCurr, _parent_, objNext[_parent_]);

  } else {

      var objNextLastLeaf = Simplex.lastLeaf(objNext[_id_]) || objNext;

      /* UPDATE zoomStart and zoomEnd */
      if (objCurr[_id_] == Simplex.__zoomStart) {
	  xo.log("moveDown: __zoomStart change to " + objNext[_id_]);
	  Simplex.__zoomStart = objNext[_id_];
	  if (objNext[_prev_] == "") Simplex.__first = objNext[_id_];
      }
      
      if (objNext[_id_] == Simplex.__zoomEnd || (objNext[_collapsed_] && objNextLastLeaf[_id_] == Simplex.__zoomEnd)) {
	  xo.log("moveDown: __zoomEnd change to " + objCurrLastLeaf[_id_]);
	  Simplex.__zoomEnd = objCurrLastLeaf[_id_];
	  if (objCurrLastLeaf[_next_]=="") Simplex.__last = objCurrLastLeaf[_id_];
      }

      var objPrev = store.find(objCurr[_prev_]);

      var objNextSibling = store.find(objCurr[_nextSibling_]);
      var objPrevSibling = store.find(objCurr[_prevSibling_]);

      store.updateIf(objNextSibling, _prevSibling_, objCurr[_prevSibling_]);
      store.updateIf(objPrevSibling, _nextSibling_, objCurr[_nextSibling_]);

      if (Simplex.hasChildren(objNext) && !objNext[_collapsed_]) {

	  var objNextNext = store.find(objNext[_next_]);
	  var objNextPrev = store.find(objNext[_prev_]);
	  var objFirst = store.find(objNext[_next_]);  // TODO: objNext["firstChild"]

	  store.update(objFirst, _prevSibling_, objCurr[_id_]);
	  store.update(objNext, _prevSibling_, objCurr[_prevSibling_]);
	  // TODO: store.update(objNext, "firstChild", objCurr[_id_]);

	  store.update(objCurr, _prevSibling_, undefined);
	  store.update(objCurr, _nextSibling_, objFirst[_id_]);
	  store.update(objCurr, _parent_, objNext[_id_]);

	  // if next node has children, move 'curr' before 'first child'
	  DH.moveBefore($(objNextNext[_id_]), curr);
	  
	  store.update(objNextPrev, _next_, objNext[_next_]);
	  store.update(objNext, _next_, objCurr[_id_]);
	  store.update(objNext, _prev_, objCurr[_prev_]);  // undefined if objCurr is __zoomStart
	  store.update(objCurr, _prev_, objNext[_id_]);

	  store.update(objNextNext, _prev_, objNextPrev[_id_]);
	  store.updateIf(objPrev, _next_, objNext[_id_]);

      } else {

	  // case when objNext has no children or it is collapsed

	  DH.moveAfter(next, curr);

	  var objNextNext = store.find(objNextLastLeaf[_next_]);
	  var objNextNextSibling = store.find(objNext[_nextSibling_]);
	  store.updateIf(objNextNextSibling, _prevSibling_, objCurr[_id_]);

	  store.update(objNext, _prevSibling_, objCurr[_prevSibling_]);
	  store.update(objCurr, _prevSibling_, objNext[_id_]);
	  store.update(objCurr, _nextSibling_, objNext[_nextSibling_]);
	  store.update(objNext, _nextSibling_, objCurr[_id_]);

	  // if (objNextNext) {
	  // objNextPrev[_next_] = objNextNext[_id_];
	  //} else {
	  /* There is only one obj where obj[_next_] is undefined and
	   * that's the last node in the zoom window, i.e. __zoomEnd
	   */
	  //objNextPrev[_next_] = undefined;
	  //}

	  // if objNext is collapsed, this works better
	  store.update(objCurrLastLeaf, _next_, objNextLastLeaf[_next_]);
	  store.update(objNextLastLeaf, _next_, objCurr[_id_]);
	  store.update(objNext, _prev_, objCurr[_prev_]);  // undefined if objCurr is __zoomStart
	  store.update(objCurr, _prev_, objNextLastLeaf[_id_]);

	  store.updateIf(objNextNext, _prev_, objCurrLastLeaf[_id_]);
	  store.updateIf(objPrev, _next_, objNext[_id_]);

      }

      // xo.log("objNext (after): " + xo.encode(objNext));    
      // xo.log("objCurr (after): " + xo.encode(objCurr));
      
  }

    Simplex.redrawEditors();

    store.finishBatch(nocapture);

};

//Moves the TEXTAREA (focuses) to the PREVIOUS item
//@item: A "div.simplex-node" element
Simplex.gotoPrev = function(item){
    if(!Simplex.util_isItem(item)) return;
    // Simplex.edit(item["id"]);//Force Focus to item as it is considered as the current!
    
    //Find PREV item
    var adjEl = Simplex.prevVisibleDom(item);
    if (!adjEl){//If no prev item (first item!), then move the caret at the beginning
	Simplex.setCaret(Simplex.textPri, 0);
	return;
    }
    //Focus to PREV item (and set the caret at the end)
    Simplex.textarea_edit(Simplex.textDom(adjEl), "end");
};


//Moves the TEXTAREA (focuses) to the NEXT item
//@item: A "div.simplex-node" element
Simplex.gotoNext = function(item){
    if(!Simplex.util_isItem(item)) return;
    // Simplex.edit(item["id"]);//Focus to CURRENT item
    
    //Find NEXT item
    var adjEl = Simplex.nextVisibleDom(item);

    if (!adjEl){ //If no next item (last item!), then move the caret at the end
	// xo.log('gotoNext: already at __zoomEnd, move caret to the end');
	Simplex.setCaret(Simplex.textPri, Simplex.textPri.value.length);
	return;
    }
    //Focus to NEXT item (and set the caret at the beginning)
    Simplex.textarea_edit(Simplex.textDom(adjEl), "beginning");
};

//Handles the ARROW keys (UP, DOWN, LEFT, RIGHT)
//For Note items: Just allow the default action 
//				EXCEPT if caret at the beginning and pressed left/up,
//				or caret at the end and pressed right/down
//For Items:
//Key combinations:
//	*ALT+RIGHT, ALT+LEFT: Zoom IN, OUT
//	*ALT+UP, ALT+DOWN: Move Item UP/DOWN
//  *CTRL+UP, CTRL+DOWN: Expand/Collapse
//  *UP, DOWN: Move between list items
//
Simplex.handleArrows = function(e, isNote, item, itemtext, textarea){	
	//REL: +1 [RIGHT, DOWN ARROW KEYS]
	//	   -1 [LEFT, UP ARROW KEYS]
    var rel = (e.keyCode == xo.Event.RIGHT || e.keyCode == xo.Event.DOWN) ? +1 : -1;
    
    //Handle Note items
    if(isNote) {
    	var curpos = Simplex.getCaret(textarea);
    	if(curpos == 0 && rel == -1){ //Caret at the beginning and pressed LEFT/UP
    	    xo.Event.stopEvent(e);
    	    Simplex.textarea_edit(Simplex.textDom(item));
    	} else if (curpos == itemtext.length && rel == +1){ //Caret at the END and pressed RIGHT/DOWN
    	    //TODO Detect Last Line, Last char position of the caret!
    	    xo.Event.stopEvent(e);
    	    Simplex.moveDown(item);
	    Simplex.publish("moveDown",item);
    	}
	return;
    }
    
    if (e.keyCode == xo.Event.RIGHT && e.altKey) {
	xo.Event.stopEvent(e);
	Simplex.zoomTo(item["id"]);
	Simplex.publish("zoomTo",item["id"]);
	return;
    } else if (e.keyCode == xo.Event.LEFT && e.altKey) {
	xo.Event.stopEvent(e);
	var objZoomRoot = store.find(Simplex.__zoomRoot);
	if (objZoomRoot) {
	    Simplex.zoomTo(objZoomRoot[_parent_]);
	    Simplex.publish("zoomTo",objZoomRoot[_id_]);
	}
	return;
    } else if (e.keyCode == xo.Event.DOWN && e.altKey) {
	xo.Event.stopEvent(e);
	Simplex.moveDown(item);
	Simplex.textarea_edit(Simplex.textDom(item));
	Simplex.publish("moveDown",item["id"]);
	return;
    } else if (e.keyCode == xo.Event.UP && e.altKey){
	xo.Event.stopEvent(e);
	Simplex.moveUp(item);		
	Simplex.textarea_edit(Simplex.textDom(item));
	Simplex.publish("moveUp",item["id"]);
	return;
    } else if (e.keyCode == xo.Event.DOWN && e.ctrlKey) {
	xo.Event.stopEvent(e);
	Simplex.expand(item);
	Simplex.publish("expand",item["id"]);
	return;
    } else if (e.keyCode == xo.Event.UP && e.ctrlKey) {
	xo.Event.stopEvent(e);
	Simplex.collapse(item);
	Simplex.publish("collapse",item["id"]);
	return;
    }
    
    //UP, DOWN: Move between list items    
    var curpos = Simplex.getCaret(textarea);
    if (e.keyCode == xo.Event.UP || (e.keyCode == xo.Event.LEFT && curpos == 0)) {
	xo.Event.stopEvent(e);
	Simplex.gotoPrev(item);
	Simplex.publish("gotoPrev",item["id"]);
    } else if (e.keyCode == xo.Event.DOWN || (e.keyCode == xo.Event.RIGHT && curpos == textarea.value.length)) {
	xo.Event.stopEvent(e);
	Simplex.gotoNext(item);
	Simplex.publish("gotoNext",item["id"]);
    }
};


//=============================================ITEM FUNCTIONS=============================================
Simplex.newItemCount = 0;

Simplex.generateId = function() {
    return Server.userPrefix + Server.sessionID + "." + (++Simplex.newItemCount);
}

//Add new item
//[@insertAt]: Array containing either {"parent":el} or {"before":el} or {"after":el} -- optional - if undefined inserted as last child to topcontainer
//Render item in DOM(based on store.__NODES)
Simplex.renderItem = function(id,focus){
    if(!id) return;	
    var objCurr = store.find(id);
    if(!objCurr) return xo.log("Storage.renderItem("+id+")","Id not found in store.__NODES");

    var content = objCurr[_text_];
    if(!content) content = "";
	
    var classes = "project";  // consider using class name "project"
    if(objCurr) {
	if(objCurr[_collapsed_]==0) classes += " open";
	if(objCurr[_completed_]==1) classes += " done";
	if(objCurr[_noted_]==1) classes += " noted";
	if(!Simplex.hasChildren(objCurr)) classes += " task";
    }
	
    // if it does not have children, addClass "task"

    var n;
    var nodeOptions = {
	"tag" : "div",
	"id" : id,
	"class" : classes,
	"cn" : [{
	    "tag" : "div",
	    "class" : "dropTarget"
	}, {
	    "tag" : "div",
	    "class" : "highlight"
	}, {
	    "tag" : "div",
	    "class" : "name",
	    "cn" : [{
		"tag" : "a",
		"href": "#" +id,
		"class" : "bullet",
		"html" : "&bull;"
	    }, {
		"tag" : "div",
		"class" : "content",
		"html" : Simplex.toHtml(objCurr[_text_])
	    }, {
		"tag" : "span",
		"class" : "parentArrow"
	    }]
	}, {
	    "tag" : "div",
	    "class" : "notes",
	    "cn" : [{
		"tag" : "div",
		"class" : "content",
		"html" : (objCurr[_noted_] ? objCurr[_note_] + '<div class="spacer">.</div>' : "")
	    }]
	}, {
	    "tag" : "div",
	    "class" : "children",
	    "cn" : [{
		"tag" : "div",
		"class" : "childrenEnd"
	    }]
	}]
    };


    
    // find appropriate place to insert new node
    var insertAt = {"parent": $(objCurr[_parent_])};

    if(xo.isDef(objCurr[_next_]) && $(objCurr[_next_]) && store.find(objCurr[_next_])[_parent_] == objCurr[_parent_])
    	insertAt = {"before": $(objCurr[_next_])};
    

    if(insertAt["before"])
	n = DH.insertBefore(insertAt["before"], nodeOptions);
    else if(insertAt["after"])
	n = DH.insertAfter(insertAt["after"], nodeOptions)
    else {
	if(!insertAt || !insertAt["parent"]) {
	    n = DH.createDom(nodeOptions, Simplex.ui_container);
	} else {
	    n = DH.insertBefore(Simplex.childrenEndDom(insertAt["parent"]),nodeOptions);
	}
    }
    
    //focus to text area if such option is requested
    if(focus) {
	Simplex.textarea_edit(Simplex.textDom(n));
    }

    // xo.log("added dom node: " + n.id + " class=" + n.className);
    return n;
};


Simplex.remove = function(id,noedit) {
    if (!id) return;
    var el = $(id);
    if (!el || !Simplex.util_isItem(el))return;

    Simplex.textareas_dispose();

    Simplex.hideControls();


    // -----

    if (!id) return;
    var objCurr = store.find(id);
    if (!objCurr) return;

    store.startBatch(_CMD_DELETE_,[id]);

    var objPrev = store.find(objCurr[_prev_]);
    var objCurrLastLeaf = Simplex.lastLeaf(id) || objCurr;
    xo.log('objCurrLastLeaf[_next_]=' + objCurrLastLeaf[_next_]);

    var objPrevSibling = store.find(objCurr[_prevSibling_]);
    store.updateIf(objPrevSibling, _nextSibling_, objCurr[_nextSibling_]);

    var objNextSibling = store.find(objCurr[_nextSibling_]);
    store.updateIf(objNextSibling, _prevSibling_, objCurr[_prevSibling_]);

    var objNextNonChild = store.find(objCurrLastLeaf[_next_]);
    store.updateIf(objNextNonChild, _prev_, objCurr[_prev_]);
    xo.log('objNextNonChild=' + xo.encode(objNextNonChild));

    var adj = objCurr;
    var stop = objCurrLastLeaf[_next_];
    while (adj && adj[_id_] != stop) {
	store.remove(adj);
	// xo.log('adj[_id_]=' + adj[_id_] + ' adj[_next_]=' + adj[_next_] + ' stop=' + stop);
	// if (adj[_next_] == stop) break;
	adj = store.find(adj[_next_]);
    }

    if (objPrev) {
	if (objCurrLastLeaf[_id_] ==  Simplex.__zoomEnd) {
	    xo.log("Storage.remove: __zoomEnd change to " + objPrev[_id_]);
	    Simplex.__zoomEnd = objPrev[_id_];
	    if (objPrev[_next_]=="") Simplex.__last = objPrev[_id_];
	}

	store.update(objPrev, _next_, objCurrLastLeaf[_next_]);
    }


    if (id == Simplex.__zoomStart) {
	if (objCurrLastLeaf[_id_] == Simplex.__zoomEnd) {
	    Simplex.__zoomStart="";
	    Simplex.__zoomEnd="";
	    var objZoomRoot = store.find(Simplex.__zoomRoot);
	    if (objZoomRoot)
		Simplex.zoomTo(objZoomRoot[_parent_]);
	    else
		xo.log('NOTICE: means there are no more nodes in the tree');
	} else {
	    if (objNextNonChild) {
		xo.log("Storage.remove: __zoomStart change to " + objNextNonChild[_id_]);
		Simplex.__zoomStart = objNextNonChild[_id_];
		if (objNextNonChild[_prev_]=="") 
		    Simplex.__first = objNextNonChild[_id_];
	    } else {
		xo.log('ERROR: does not make sense - objNextNonChild must exist at this point');
	    }
	}
    }


    store.finishBatch();


    // -----


    DH.remove(el); //Delete DOM node

    if (!noedit) {
	// must be here because __zoomStart may have changed in Storage.remove
	try {
	    var editId = objPrev ? objPrev[_id_] : Simplex.__zoomStart;
	    xo.log('editId: ' + editId);
	    if (editId && editId != "") {
		var textEl = Simplex.textDom($(editId));
		Simplex.textarea_moveTo(textEl); //Move the (secondary) textarea there
		Simplex.textarea_swapRoles(true);  // nosave, do not call textarea_save()
		Simplex.textPri.focus();
	    } else {
		Simplex.textareas_dispose(true);  // nosave, do not call textarea_save()
	    }
	} catch(ex) {
	    xo.log(ex);
	}
    }
	
    //Menu.redraw();
};

Simplex.item_deleteNote = function(el){
    if(!el || !Simplex.util_isItem(el)) return;
    var note = Simplex.item_getNodeNote(el);
    if(xo.isDef(note)){
	Simplex.textareas_dispose();
	DH.remove(note);
    }
}


Simplex.item_getLevel = function(el) {
    if (!el || !xo.isDef(el))
	return 0;
    var l = 0;
    while (el != null && el != Simplex.ui_container) {
	el = el.parentNode;
	l++;
    }
    return l;
};


Simplex.toHtml = function(text) {
    var html = Util.quotehtml(text);

    html = html.replace(TAG_REGEXP,'$1<span class="contentTag">#<span class="contentTagText">$2</span><div title="Filter #$2" data-tag="#$2" class="contentTagClickable"></div></span>').replace(URL_REGEXP,'<a href="$1" target="_blank" class="contentLink">$1</a>').replace(SYMBOL_REGEXP,'$1<span class="contentTag">$$<span class="contentTagText">$2</span><div title="Symbol $$$2" data-symbol="$$$2" data-type="symbol" class="contentTagClickable"></div></span>');

    return html;
}

// set name or note content to dom
Simplex.setContent = function(contentEl, content) {
    if(!contentEl) return;
    contentEl.innerHTML = Simplex.toHtml(content);

    var editorEl = Simplex.textPri.parentNode;
    var el = contentEl;
    editorEl.style.width = (el.clientWidth || el.offsetWidth ) + "px";
    editorEl.style.height = (el.clientHeight || el.offsetHeight || 20) + "px";

};

Simplex.getText = function(id) {
    if (!id) return;
    var objCurr = store.find(id);
    if (!objCurr) {
	xo.log("no object for id=" + id);
    }
    return objCurr[_text_];
};


Simplex.item_getChildrenIndicator = function(el){
    if(!el) return;
	
    if(!Simplex.util_isItem(el)) {
	xo.log("passed something that is not an item!" + xo.encode(el));
	return;
    }

    var result = DQ.byClassName(el.childNodes, null, "expandButton");
    return result[0];

};

Simplex.projectDom = function(el) {
    while (el && !DH.hasClass(el,"project")) 
	el = el.parentNode;
    return el;
}

Simplex.nameDom = function(el) {
    var nodes = DQ.byClassName(el.childNodes, null, "name");
    return nodes ? nodes[0] : undefined;
}

Simplex.textDom = function(el) {
    if(!Simplex.util_isItem(el)) {
	xo.log("Simplex.textDom: passed something that is not an item!" + xo.encode(el));
	return;
    }

    var nameEl = Simplex.nameDom(el);
    if (!nameEl) return;
    return DQ.byClassName(nameEl.childNodes, null, "content")[0];
};

Simplex.noteDom = function(el) {
    return DH.hasClass(el.childNodes[3],"notes") ? el.childNodes[3] : DQ.byClassName(el.childNodes, null, "notes")[0];
}

Simplex.noteContentDom = function(el) {
    return DH.hasClass(el.firstChild,"content") ? el.firstChild : DQ.byClassName(el.childNodes, null, "content")[0];
}

Simplex.childrenDom = function(el) {
    if(!Simplex.util_isItem(el)) {
	xo.log("Simplex.childrenDom: passed something that is not an item!" + el);
	return;
    }
    return DQ.byClassName(el.childNodes, null, "children")[0];
}

Simplex.childrenEndDom = function(el) {
    if (!Simplex.util_isItem(el)) {
	xo.log("Simplex.childrenEndDom: passed something that is not an item!" + xo.encode(el));
	return;
    }
    var childrenEl = Simplex.childrenDom(el);
    if (!childrenEl) return;
    return DQ.byClassName(childrenEl.childNodes, null, "childrenEnd")[0];
}


Simplex.item_getNodeChildItem = function(el, index){
	if(!el || !Simplex.util_isItem(el)) return;
	if(!xo.isDef(index))index=0;	
	var i;
	var n = DQ.byClassName(el.childNodes, null, "project");
	n = DQ.byTag(n, "DIV");
	if(!n.length || n.length <= Math.abs(index)) return;
	if(index>-1)
		return n[index];
	else
		return n[n.length+index];
};

Simplex.item_setNote = function(el, text) {
	if(!el || !xo.isDef(el) || !Simplex.util_isItem(el)) return;
	
	var i = Simplex.item_getNodeNote(el);
	if(!Simplex.item_hasNote(el))
		i = Simplex.item_addNote(el, true);
	
	i.innerHTML = Util.quotehtml(text)+'';
};

Simplex.item_getNote = function(el) {
	if(!el || !xo.isDef(el) || !Simplex.util_isItem(el)) return;	
	
	var t = Simplex.item_getNodeNote(el);
	return  (t && t.innerHTML ? Util.unquotehtml(t.innerHTML) : "");
};

Simplex.item_getNodeNote = function(el){
	if(!el) return;
	if(!Simplex.util_isItem(el))//return;
		//@DEBUG
		{
			alert("Simplex.item_getNodeNote: passed something that is not an item!"+el);
			xo.log("Simplex.item_getNodeNote: passed something that is not an item!"+el);
			xo.log(el);
			return;
	}
	var t = $(el.id + "_note");
	if(t && xo.isDef(t))
		return t;
	return undefined;
};


Simplex.item_isCompleted = function(el){
	if(el && !Simplex.util_isItem(el))
		el = el.parentNode;
	if(!el || !Simplex.util_isItem(el))return;
	
	return (DH.hasClass(el, "node-completed"));
};



Simplex.item_hasNote = function(el){
	if(!el || !Simplex.util_isItem(el))return;
	
	var n = DQ.byClassName(el.childNodes, null, "note");
	if(n.length)
		return true;
	return false;
};


Simplex.handleShowCompletedButton = function(e,target,options) {

    Simplex.hideMenu();
    Simplex.textareas_dispose();

    var editId = Simplex.textPri.getAttribute("editId");

    var buttonEl = $("showCompletedButton");
    var hideEl = DQ.byClassName(buttonEl.childNodes,null,"hide")[0];
    var showEl = DQ.byClassName(buttonEl.childNodes,null,"show")[0];
    if (DH.hasClass(document.body,"showCompleted")) {
	DH.removeClass(document.body,"showCompleted");
	hideEl.style.display = "none";
	showEl.style.display = "inline";

	var objNext = Simplex.nextVisible(editId);
	if (objNext)
	    Simplex.edit(objNext[_id_]);

    } else {
	DH.addClass(document.body,"showCompleted");
	hideEl.style.display = "inline";
	showEl.style.display = "none";

	Simplex.edit(editId);
    }

}

Simplex.hideCompleted = function() {
    return !DH.hasClass(document.body,"showCompleted");
}

Simplex.toggleDone = function(el) {

    Simplex.hideMenu();
    Simplex.textareas_dispose();

    var id = el["id"];
    var objCurr = store.find(id);

    store.startBatch(_CMD_TOGGLE_DONE_,[id]);
    if (objCurr[_completed_]) {
	store.update(objCurr, _completed_,0);
	DH.removeClass(el,"done");
    } else {
	store.update(objCurr, _completed_, 1);
	DH.addClass(el,"done");
    }

    store.finishBatch();

    Simplex.edit(id);
};


Simplex.handleExpandButton = function(e,target,options){
    var projectEl = Simplex.projectDom(e.target);
    Simplex.toggleCollapseExpand(projectEl);
    Simplex.edit(projectEl["id"]);
};

Simplex.toggleCollapseExpand = function(el) {
    var objCurr = store.find(el["id"]);
    if (!objCurr) return;

    if (objCurr[_collapsed_]){
	Simplex.expand(el);
    } else {
	Simplex.collapse(el);
    }
}

Simplex.expand = function(el,nocapture) {
    if (!el || !Simplex.util_isItem(el)) return;

    var id = el.id;
    var objCurr = store.find(id);
    if (!objCurr) return;
    if (!objCurr[_collapsed_]) return;

    store.startBatch(_CMD_EXPAND_,[id]);
    store.update(objCurr, _collapsed_, 0);  // false
    store.finishBatch(nocapture);

    DH.addClass(el, "open");

}

Simplex.collapse = function(el) {
    if (!el || !Simplex.util_isItem(el)) return;
    var id = el.id;

    var objCurr = store.find(id);
    if (!objCurr) return;

    // if given element is zoomRoot, return
    if (id == Simplex.__zoomRoot) return;

    // if already collapsed, return
    if (objCurr[_collapsed_]) return;

    // if no children, return
    if (!Simplex.hasChildren(objCurr)) return;

    store.startBatch(_CMD_COLLAPSE_,[id]);
    store.update(objCurr, _collapsed_, 1);  // true
    store.finishBatch();

    DH.removeClass(el, "open");
}


Simplex.zoomTo = function(id) {

    Simplex.textareas_dispose();

    if (!id || id=="simplex") {
	id = "";
	DH.removeClass(Simplex.__root, "parent");
	DH.addClass(Simplex.__root, "selected");
    } else {
	DH.removeClass(Simplex.__root, "selected");
	DH.addClass(Simplex.__root, "parent");
    }

    top.location.hash = id;

    // xo.log("zoomTo: " + id);

    // TODO: code review below
    
    var el;
    if (id != "") el = $(id);
    if(!el) el = Simplex.__root;
    if(!el || (!Simplex.util_isItem(el) && el != Simplex.__root)) return;

    Simplex.hideMenu();

    // fix old __zoomRoot ancestors
    if (Simplex.__zoomRoot != "") {
	var objCurr = store.find(Simplex.__zoomRoot);
	while (objCurr) {
	    var cn = $(objCurr[_id_]);
	    DH.removeClass(cn,"parent");
	    DH.removeClass(cn,"selected");
	    objCurr = store.find(objCurr[_parent_]);
	}
    }

    // fix new __zoomRoot ancestors
    if (id != "") {
	var objCurr = store.find(id);
	var objParent = store.find(objCurr[_parent_]);
	while (objParent) {
	    var pn = $(objParent[_id_]);
	    DH.removeClass(pn, "selected");
	    DH.addClass(pn,"parent");
	    if (!objParent[_parent_]) break;
	    objParent = store.find(objParent[_parent_]);
	}
    }

    DH.removeClass(el,"parent");
    DH.addClass(el,"selected");

    // Change Simplex.__zoomRoot 
    Simplex.__zoomRoot = id; // objCurr[_parent_]; (this holds for the very top level)

    
    if (id == "") {
	Simplex.__zoomStart = Simplex.__first;
	Simplex.__zoomEnd = Simplex.__last;
    } else {
	Simplex.__zoomStart = id;
	var objCurr = store.find(id);

	// TODO: Treat this case in other functions, 
	// for instance, in nextVisible check if we 
	// are zoomRoot and in that case allowed it
	if (objCurr[_collapsed_]) Simplex.expand($(objCurr[_id_]));

	var objCurrLastLeaf = Simplex.lastLeaf(objCurr[_id_]) || objCurr;
	Simplex.__zoomEnd = objCurrLastLeaf[_id_];

    }

    Simplex.edit(Simplex.__zoomStart);

    //Fit textareas!
    //Simplex.textarea_fit(Simplex.textPri);
    //Simplex.textarea_fit(Simplex.textSec);
	
    //Scroll to top!
    // window.scrollTo(0,0);

    return false;

};




Simplex.append = function(objParent,objChild) {

    // make necessary dom changes
    var o = $(objChild[_id_]);
    var pn = $(objParent[_id_]);
    var sentinel = Simplex.childrenEndDom(pn);

    sentinel.parentNode.insertBefore(o,sentinel);
    DH.removeClass(pn,"task");

};

Simplex.lastDirectChild = function(id) {
    var objParent = store.find(id);
    if (!objParent || !Simplex.hasChildren(objParent)) return;

    // given that we have children, the next of the parent is its first child
    var adj = store.find(objParent[_next_]);  // firstChild
    if (adj[_parent_] != id) return;

    // find last direct child of parent
    while (adj && adj[_nextSibling_])
	adj = store.find(adj[_nextSibling_]);

    return adj;
}

// direct or indirect child
Simplex.lastLeaf = function(id) {
    if (!id) return;
    var objParent = store.find(id);
    if (!objParent) return;

    // start from last direct child X
    // and find last indirect child Y
    // such that isAncestorOf(X,Y)
    var adj=Simplex.lastDirectChild(id);
    var last = adj;
    while (adj && Simplex.isAncestorOf(adj,objParent)) {
	last = adj;
	adj = store.find(adj[_next_]);
    }

    return last;
};

Simplex.indent = function(id,nocapture) {
    
    if (!id) return;

    var objCurr = store.find(id);
    if (!objCurr) return;

    var objPrevSibling = store.find(objCurr[_prevSibling_]);
    if (!objPrevSibling) return;
    if (objPrevSibling[_collapsed_]) return;

    store.startBatch(_CMD_INDENT_,[id]);

    store.update(objPrevSibling, _nextSibling_, objCurr[_nextSibling_]);

    // must preceed change of objCurr[_parent_] since
    // we use the value of objCurr[_parent_] to check
    // if objPrevSibling hasChildren
    if (!Simplex.hasChildren(objPrevSibling)) {
	// xo.log('no child nodes');
	// objCurr becomes the only child of prevSibling
	store.update(objCurr,_prevSibling_, undefined);
    } else {
	// objCurr becomes the last child of prevSibling
	var objLastChild = Simplex.lastDirectChild(objPrevSibling[_id_])
	store.update(objLastChild, _nextSibling_, objCurr[_id_]);
	store.update(objCurr, _prevSibling_, objLastChild[_id_]);
    }

    var objNextSibling = store.find(objCurr[_nextSibling_]);
    store.updateIf(objNextSibling, _prevSibling_, objPrevSibling[_id_]);

    store.update(objCurr, _parent_, objPrevSibling[_id_]);
    store.update(objCurr, _nextSibling_, undefined);

    Simplex.append(objPrevSibling,objCurr);

    Simplex.redrawEditors();

    store.finishBatch(nocapture);
    
};


// objRef - reference object
Simplex.moveAfter = function(objSibling,objCurr) {
    var curr = $(objCurr[_id_]);
    var sibling = $(objSibling[_id_]);
    DH.moveAfter(sibling, curr);
};

Simplex.outdent = function(id,nocapture) {
    if (!id) return;
    var objCurr = store.find(id);
    var objParent = store.find(objCurr[_parent_]);

    // if (objCurr[_parent_] == Simplex.__zoomStart && objParent[_parent_] != "") return;
    if (objCurr[_parent_] == Simplex.__zoomRoot) return;

    var objParent = store.find(objCurr[_parent_]);
    if (!objParent) return;

    store.startBatch(_CMD_OUTDENT_,[id]);

    Simplex.moveAfter(objParent,objCurr);


    // ONLY compute objParentLastLeaf
    // BEFORE changing objPrev[_next_] and objPrevSibling[_nextSibling_]
    var objParentLastLeaf = Simplex.lastLeaf(objParent[_id_]);
    var objCurrLastLeaf = Simplex.lastLeaf(objCurr[_id_]) || objCurr;
    var objPrevSibling = store.find(objCurr[_prevSibling_]);
    var objNextSibling = store.find(objCurr[_nextSibling_]);
    var objPrev = store.find(objCurr[_prev_]);

    // new parent is the parent of current parent
    store.update(objCurr, _parent_, objParent[_parent_]);

    store.update(objPrev, _next_, objNextSibling?objNextSibling[_id_]:objCurr[_id_]);
    xo.log('objPrev='+xo.encode(objPrev));

    store.updateIf(objPrevSibling, _nextSibling_, objCurr[_nextSibling_]);


    // must preceed objNextSibling if-branch otherwise
    // objParentLastLeafNext would have become objCurr
    var objParentLastLeafNext = store.find(objParentLastLeaf[_next_]);
    // xo.log('objParentLastLeaf: ' + xo.encode(objParentLastLeaf));
    // xo.log('objParentLastLeafNext: ' + xo.encode(objParentLastLeafNext));
    
    store.updateIf(objParentLastLeafNext, _prev_, objCurrLastLeaf[_id_]);

    var objParentNextSibling = store.find(objParent[_nextSibling_]);
    if (objParentNextSibling) {
	store.update(objParentNextSibling, _prevSibling_, objCurr[_id_]);
	store.update(objParentNextSibling, _prev_, objCurrLastLeaf[_id_]);
    }

    if (objNextSibling) {
	store.update(objNextSibling, _prev_, objCurr[_prev_]);
	store.update(objNextSibling, _prevSibling_, objCurr[_prevSibling_]);

	store.update(objCurr, _prev_, objParentLastLeaf[_id_]); // objParent["lastLeaf"]
	store.update(objCurrLastLeaf, _next_, objParentLastLeaf[_next_]);

	store.update(objParentLastLeaf, _next_, objCurr[_id_]);

	// xo.log("objParentLastLeaf: " + xo.encode(objParentLastLeaf));

    } else {
	// if there is no objNextSibling
	// then no point to change objCurr[_prev_] or objCurr[_next_]
	// and in this case objParent["lastLeaf"]==objCurr[_id_]
    }

    // becomes next sibling of parent
    // and parent becomes prev sibling of curr
    store.update(objCurr, _prevSibling_, objParent[_id_]);
    store.update(objCurr, _nextSibling_, objParent[_nextSibling_]);
    store.update(objParent, _nextSibling_, objCurr[_id_]);

    if (!Simplex.hasChildren(objParent)) {
	DH.addClass($(objParent[_id_]),"task");
    }

    if (!objCurrLastLeaf[_next_]) {
	// xo.log("outdent: __zoomEnd change to " + objCurrLastLeaf[_id_]);
	Simplex.__zoomEnd = objCurrLastLeaf[_id_];
	Simplex.__last = objCurrLastLeaf[_id_];
    }

    // xo.log("objCurr: " + xo.encode(objCurr));

    Simplex.redrawEditors();

    store.finishBatch(nocapture);

};


//=============================================UI FUNCTIONS/VARIABLES=============================================
Simplex.ui_container = undefined;
Simplex.ui_item_move = undefined;
Simplex.ui_move_handle = undefined;
Simplex.__zoomRoot = "";
Simplex.__zoomStart = "";
Simplex.__zoomEnd = "";
Simplex.__first = "";
Simplex.__last = "";
Simplex.__toupdate = [];
Simplex.__todelete = [];
Simplex.__ready = 0;
Simplex.__saveButtonState = _saveButton_saved_;
Simplex.__root = undefined;
Simplex.__countChanges = 0;
Simplex.__WINDOW_FOCUSED = false;
Simplex.ui_move_handle_locked = false;

Simplex.nonTextAreaClick = function(e,target,options) {
    xo.log('nonTextAreaClick');

    var projectEl = Simplex.projectDom(e.target);
    var projectId = projectEl["id"];
    if (DH.hasClass(e.target,"bullet")) {
	xo.Event.stopEvent(e);
	Simplex.zoomTo(projectId);
    } else if (DH.hasClass(projectEl,"parent")) {
	xo.Event.stopEvent(e);
	Simplex.zoomTo(projectId);
    } else if (DH.hasClass(e.target,"delete")) {
	xo.Event.stopEvent(e);
	Simplex.hideMenu();
	Simplex.remove(projectId);
    } else if (DH.hasClass(e.target,"complete")) {
	xo.Event.stopEvent(e);
	Simplex.hideMenu();
	Simplex.toggleDone(projectEl);  // starts its own batch
    } else if (DH.hasClass(e.target,"note")) {
	xo.Event.stopEvent(e);
	Simplex.hideMenu();
	if (!DH.hasClass(projectEl,"noted")) {
	    Simplex.addNote(projectEl);  // starts its own batch
	}
	Simplex.editNote(projectEl);
    } else if (DH.hasClass(e.target,"contentTagClickable")) {
	xo.Event.stopEvent(e);
	$("searchBox").value = e.target.getAttribute("data-tag");
	Simplex.search(e,target,options);
    }

};

Simplex.ui_load = function() {


    Simplex.__root = $("simplex");

    DH.addClass(Simplex.__root,"project");
    DH.addClass(Simplex.__root,"open");
    DH.addClass(Simplex.__root,"selected");

    Simplex.ui_container = Simplex.childrenDom(Simplex.__root);
    DH.addClass(Simplex.ui_container,"children");

    Simplex.editorPri = DH.createDom({"tag":"div","cls":"editor","cn":[{"tag":"textarea","spellcheck":"false"}]},$("visible"));
    Simplex.editorSec = DH.createDom({"tag":"div","cls":"editor","cn":[{"tag":"textarea","spellcheck":"false"}]},$("visible"));
    Simplex.textPri = Simplex.editorPri.firstChild;
    Simplex.textSec = Simplex.editorSec.firstChild;

    xo.Event.on(Simplex.__root, "mouseover", Simplex.handleMouseOver);
    xo.Event.on($("move"), "mousedown", Simplex.handleMoveHandleMouseDown);


    xo.Event.on(Simplex.__root,"click",Simplex.nonTextAreaClick);
    xo.Event.on(Simplex.textPri, "click", Simplex.handleMouseClick);
    xo.Event.on(Simplex.textSec, "click", Simplex.handleMouseClick);
    xo.Event.on(Simplex.textPri, "keydown", Simplex.handleKeyDown);
    xo.Event.on(Simplex.textSec, "keydown", Simplex.handleKeyDown);

    xo.Event.on($("searchBox"),"keyup",Simplex.search);
    xo.Event.on($("searchCancel"),"click",Simplex.searchCancel);

    store.init();	
    undoredo.init();

    // HERE - TODO - REFACTOR ME
    Server.requestSessionInfo(); //Load userprefix, etc.

}


Simplex.searchCancel = function(e,target,options) {
    $("searchBox").value = "";
    DH.removeClass(document.body, "searching");
}

Simplex.matches = function(el,query) {
    if (!query) return;
    var objCurr = store.find(el["id"]);
    if (!objCurr) return;
    var pattern = query.split(" ").join("|");
    if (objCurr[_text_].match(RegExp(pattern))) {
	return true;
    }
    return false;
}

Simplex.search = function(e,target,options) {
    Simplex.textareas_dispose();
    var query = $("searchBox").value;
    if (query.length) {
	DH.addClass(document.body, "searching");
    } else {
	DH.removeClass(document.body, "searching");
    }

    xo.log("searching for: " + query);
    var el = $(Simplex.__first)
    while (el) {
	var nameEl = Simplex.nameDom(el);
	if (Simplex.matches(el,query)) {
	    DH.addClass(el,["matches","terminalMatch"]);
	    DH.addClass(nameEl,"matches");
	    // TODO: we also have notes matches
	    // TODO: highlight match: <span class="contentMatch">abc123</span>
	    var objCurr = store.find(el["id"]);
	    while (objCurr) {
		ancestorEl = $(objCurr[_parent_]);
		if (!ancestorEl) break;
		DH.addClass(ancestorEl,"uncompletedDescendantMatches");
		objCurr = store.find(objCurr[_parent_]);
	    }
	} else {
	    DH.removeClass(el,["matches","terminalMatch","uncompletedDescendantMatches"]);
	    DH.removeClass(nameEl,"matches");
	}
	el = Simplex.nextVisibleDom(el);
    }
}


Simplex.ui_completedVisible = function(){
	return (DH.hasClass(Simplex.ui_container, "hidecompleted") ? false : true);
};
//=============================================UTILITY FUNCTIONS=============================================

// if id exists, returns an object of the form:
// {collapsed:true, completed: true, id:"S.999.3.2", note: "", parent:"S.999.3.1", prev:"S.999.3.1", next:"S.999.3.3", text:"this is a test", version:1234567890}
// version is a timestamp


Simplex.isTheStart = function(obj) {
    return (!obj[_prev_]);
}

Simplex.isTheEnd = function(obj) {
    return (!obj[_next_]);
}

Simplex.refreshData = function() {
    // Simplex.ui_load();
    xo.log("refreshing data...");
}

// Publish/Subscribe callback - accept published messages
Simplex.sync_message_from_server = function(obj) {
    Simplex.subscribe();
    xo.log(xo.encode(obj));
    var parts = obj["message"].split(' ');
    var action = parts[0];
    var id = parts[1];
    var item = $(id);
    if (action=="gotoNext") {
	Simplex.gotoNext(item);
    } else if (action=="gotoPrev") {
	Simplex.gotoPrev(item);
    } else if (action=="moveUp") {
	Simplex.moveUp(item);
    } else if (action=="moveDown") {
	Simplex.moveDown(item);
    } else if (action=="zoomTo") {
	Simplex.zoomTo(id);
    } else if (action=="expand") {
	Simplex.expand(item);
    } else if (action=="collapse") {
	Simplex.collapse(item);
    } else if (action=="refreshData") {
	Simplex.__refreshData = true;
	xo.log("refreshData please...");
    }

    // top.location.href="http://www.phigita.net/";
}

Simplex.publish = function(action,id) {
    var message =  action;
    if (id) message += " " + id;
    Server.request("cmd=publish&argv=channel_"+Server.userPrefix+" "+xo.encode(message));
}

Simplex.subscribe = function() {
    // DISABLE FOR NOW
    // REMOVE RETURN TO ENABLE AGAIN
    return;

    Server.request("cmd=subscribe&callback=Simplex.sync_message_from_server&argv=channel_"+Server.userPrefix,{"success":Server.reqSuccess,"failure":Server.reqFailure});
}

// TODO: there are nodes without parent attribute - there should be only one such node - the root
Simplex.loadTree = function(o) {
    var dataLen = o["data"].length;
    if (dataLen==0) return;
    var startId, endId;
    for(var i=0;i<dataLen;i++) {
	// var obj = xo.decode( o["data"][i] );
	var obj = Storage.deserialize( o["data"][i] );
	if (store.exists(obj[_id_])) {
	    xo.log('object already exists: ' + obj[_id_]);
	    // xo.log(obj);
	    continue;
	}
	store.set(obj[_id_],obj);
	if (Simplex.isTheStart(obj)) startId = obj[_id_];
	if (Simplex.isTheEnd(obj)) endId = obj[_id_];
		
    }

    // var objRoot = store.find(""); // get the top node
    // var startId = objRoot[_next_]; // firstChild
    // var endId = Simplex.lastLeaf(objRoot[_id_]); // lastLeaf

    Simplex.__first = startId;
    Simplex.__last = endId;

    Simplex.__zoomStart = startId;
    Simplex.__zoomEnd = endId;
    var id = startId;
    var objTemp = store.find(id);
    while(dataLen-- && objTemp) {
	Simplex.renderItem(objTemp[_id_]);
	objTemp = store.find(objTemp[_next_]);
    }

    if (store.isConsistent && !store.isConsistent()) {
	// here - here - here
	xo.log("inconsistency detected");
    }

    // zoomTo given hashId
    // 
    var rootId = startId;
    var hash = top.location.hash;
    if (hash && hash != "") {
	var hashId = hash.substr(1);
	var el = $(hashId);
	if (el) {
	    rootId = hashId;
	    Simplex.zoomTo(el["id"]);
	} else {
	    top.location.hash="";
	}
    }
    if (rootId) Simplex.edit(rootId);

    Simplex.publish("user_just_logged_in");
    Simplex.subscribe();

}

Simplex.hasChildren = function(objCurr) {
    if (!objCurr) return;

    var objNext = store.find(objCurr[_next_]);

    if (objNext && objNext[_parent_] == objCurr[_id_])
	return true;
    else
	return false;
};


Simplex.isVisible = function(obj) {
    if (!obj) return false;

    var hideCompleted = Simplex.hideCompleted();
    // TODO: __zoomEnd
    while(obj && obj[_id_] != Simplex.__zoomStart) {
	if (hideCompleted && obj[_completed_]) return false;
	obj = store.find(obj[_parent_]);
	if (obj && obj[_collapsed_]) return false;
    }
    return true;
};

// Checks whether x is an ancestor of y via
// following obj[_parent_] edges
// Note that we do not use dom nodes here.
// See util_isXancestorOfY for dom nodes.
Simplex.isAncestorOf = function(x,y) {
    // xo.log('check if ' + x[_id_] + ' is an ancestor of ' + y[_id_]);
    if (!x || !y) return false;
    var parent = store.find(x[_parent_]);
    while (parent)
	if (y[_id_]==parent[_id_])
	    return true;
        else
	    parent = store.find(parent[_parent_]);

  return false;
};

// Returns next sibling of a given object within the current zoom window
Simplex.nextNonChild = function(obj, visibleOnly) {

    var objLastLeaf = Simplex.lastLeaf(obj[_id_]) || obj;

    if (visibleOnly && objLastLeaf && objLastLeaf[_id_] == Simplex.__zoomEnd) return;

    return (objLastLeaf ? store.find(objLastLeaf[_next_]) : undefined);

};

Simplex.nextNonChildDomNode = function(el){
	if(!el) return;
	var obj = Simplex.nextNonChild(store.find(el["id"]),true);  // visibleOnly=true
	if (obj) return $(obj[_id_]);
};


//Returns the Next Element as stored in memory that is IN the current viewport
//@el: A "div.simplex-node" element
Simplex.nextVisibleDom = function(el){
	if(!el) return;
	var obj = Simplex.nextVisible(el["id"]);
	if (obj) return $(obj[_id_]);
}

// Next active item. In other words, if 'id' denotes the current node,
// this function will return the object of the next node, 
// i.e. the one we must go to once the up arrow is pressed.
Simplex.nextVisible = function(id) {
    if (!id) return;
    if (id == Simplex.__zoomEnd) return;

    var hideCompleted = Simplex.hideCompleted();
  
    var obj = store.find(id);
    var adj;
    if (obj[_collapsed_] || (hideCompleted && obj[_completed_]) )
	adj = Simplex.nextNonChild(obj,true); // visibleOnly=true
    else 
	adj = store.find(obj[_next_]);

    var objZoomRoot = store.find(Simplex.__zoomRoot);
    if (objZoomRoot && !Simplex.isAncestorOf(adj,objZoomRoot)) return;

    if (hideCompleted)
	while (adj && adj[_completed_])
	    adj = Simplex.nextNonChild(adj,true);  // visibleOnly=true

    return adj;

};


//Returns the Previous Element as stored in memory that is IN the current viewport
//@el: A "div.simplex-node" element
Simplex.prevVisibleDom = function(el){
	if(!el) return;
	var obj = Simplex.prevVisible(el["id"]);
	if (obj) return $(obj[_id_]);
}

// Previous active item. In other words, if 'id' denotes the current node,
// this function will return the object representing the previous node,
// i.e. the one we must go to once the up arrow is pressed.
Simplex.prevVisible = function(id) {
  if (!id) return;
  if (id == Simplex.__zoomStart) return;

	var obj = store.find(id);
	var adj = store.find(obj[_prev_]);
	if (!adj) return;

	// TODO - keep hideCompleted in a state variable
    var hideCompleted = Simplex.hideCompleted();


	var best_adj = adj;
	var parent = store.find(adj[_parent_]);
	while (parent && parent[_id_] != Simplex.__zoomRoot) {
	    if (parent[_collapsed_]) best_adj = parent;
	    if (hideCompleted && parent[_completed_]) best_adj = parent;
	    parent = store.find(parent[_parent_]);
	}

	if (hideCompleted) {
	  adj = best_adj;
	  while (adj && adj[_completed_] && adj[_id_] != Simplex.__zoomRoot)
	    adj = store.find(adj[_prev_]);
	  best_adj = adj;
	}

// TODO - FIX - USE OBJECTS BELOW - NOT $(obj[_id_])
	  if (DH.hasClass($(best_adj[_id_]),'zoomhide')) return;
	return best_adj;
};

Simplex.now = function() {
  return (new Date).getTime();
}


Simplex.saveButton_saveNow = function() {
    Simplex.__countChanges = (Simplex.__countChanges + 1) % 5;
    if (Simplex.__countChanges == 0) Simplex.textarea_save();
    if (Simplex.__saveButtonState == _saveButton_saveNow_) return;
    var saveButtonEl = $("saveButton");
    DH.removeClass(saveButtonEl,"saving");
    DH.removeClass(saveButtonEl,"saved");
    DH.addClass(saveButtonEl,"saveNow");
    Simplex.__saveButtonState = _saveButton_saveNow_;
}

Simplex.saveButton_saving = function() {
    if (Simplex.__saveButtonState == _saveButton_saving_) return;
    var saveButtonEl = $("saveButton");
    DH.removeClass(saveButtonEl,"saveNow");
    DH.removeClass(saveButtonEl,"saved");
    DH.addClass(saveButtonEl,"saving");
    Simplex.__saveButtonState = _saveButton_saving_;
}

Simplex.saveButton_saved = function() {
    if (Simplex.__saveButtonState == _saveButton_saved_) return;
    var saveButtonEl = $("saveButton");
    DH.removeClass(saveButtonEl,"saveNow");
    DH.removeClass(saveButtonEl,"saving");
    DH.addClass(saveButtonEl,"saved");
    Simplex.__saveButtonState = _saveButton_saved_;
}


//Checks whether an element IS an Item
Simplex.util_isItem = function(el) {
    if(!el) return;
    return DH.hasClass(el,"project");
}

//Checks whether an element is a "text node"
Simplex.util_isItemText = function(el) {
    if(!el)return;
    return (DH.hasClass(el,"content") && el.tagName != "TEXTAREA");
}

//Checks whether an element is a "children indicator" 
Simplex.util_isChildrenIndicator = function(el) {
    if(!el)return;
    return (DH.hasClass(el,"expandButton"));
}

//Checks whether an element is a "note"
Simplex.isNoteContentDom = function(el){
    if(!el) return;
    return (DH.hasClass(el,"content") && DH.hasClass(el.parentNode,"notes") && el.tagName != "TEXTAREA");
}

Simplex.util_isEditableNote = function(el){
	if(!el)return;
	return (DH.hasClass(el, "note") && el.tagName == "TEXTAREA");
}



//=============================================ZOOM FUNCTIONS=============================================


Simplex.online = function() {
    xo.log("we are online");
}
Simplex.offline = function() {
    xo.log("we are offline");
}
Simplex.focused = function() {
    Simplex.__WINDOW_FOCUSED = true;
    xo.log("focused");
    if (Simplex.__refreshData) Simplex.refreshData();
}
Simplex.not_focused = function() {
    Simplex.__WINDOW_FOCUSED = false;
    xo.log("not_focused");
}


Simplex.unload = function(e){
    window.clearTimeout(Simplex.timeout["autosave"]);
    delete Simplex.timeout["autosave"];
    Simplex.save();
};

Simplex.init = function (config){
    Server.baseUrl = config["baseUrl"];
    DH.addClass(document.body,"showCompleted");
    if (xo.isGecko)
	DH.addClass(document.body,"mozilla");

    
    window.addEventListener('resize', Simplex.ui_resize, false);
    window.addEventListener('unload', Simplex.unload, false);
    window.addEventListener('focus', Simplex.focused, false);
    window.addEventListener('blur', Simplex.not_focused, false);

    xo.Event.on('addButton', 'click', Simplex.handleAddButton);
    xo.Event.on('expandButton', 'click', Simplex.handleExpandButton);
    xo.Event.on('showCompletedButton',"click", Simplex.handleShowCompletedButton);

    Simplex.ui_load();
    // window.addEventListener('online',Simplex.online,true);
    // window.addEventListener('offline',Simplex.offline,true);
    Simplex.timeout["autosave"] = window.setTimeout("Simplex.autosave();",5000);

};

///////////////////////////////////////////////////////////////////////////////////////////////////////////////


//On load
// window.addEventListener('DOMContentLoaded', Simplex.init, false);

/**
 * Assigning namespace to window object,
 */
xo.exportSymbol("Simplex", Simplex);
xo.exportProperty(Simplex, "init",Simplex.init);
xo.exportProperty(Simplex, "loadTree",Simplex.loadTree);
xo.exportProperty(Simplex, "saved",Simplex.saved);
xo.exportProperty(Simplex, "sync_message_from_server",Simplex.sync_message_from_server);
xo.exportProperty(Simplex, "autosave", Simplex.autosave);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//=============================================UTILITY FUNCTIONS=============================================

var Util = Util || {};

//Escapes text to html
Util.quotehtml = function(str){
	return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
};
//Escapes html to text (unescapes)
Util.unquotehtml = function(str){
	return str.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace('/&quot;/g','"');
};




