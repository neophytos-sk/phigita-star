	// Create the main namespace
	var POLL = POLL || {};

	POLL.MIN_CHOICES=2;
	POLL.MAX_CHOICES=10;

	function isArray(v){
	    return v && typeof v.length == 'number' && typeof v.splice == 'function';
	}
	function createDom(o, parentNode){
	    var el;
	    if (isArray(o)) {                       // Allow Arrays of siblings to be inserted
		el = document.createDocumentFragment(); // in one shot using a DocumentFragment
		for(var i = 0, l = o.length; i < l; i++) 
		{
		 createDom(o[i], el);
	     }
	    } else if (typeof o == "string") {         // Allow a string as a child spec.
		el = document.createTextNode(o);
	    } else {
		el = document.createElement(o['tag']||'div');
		var useSet = !!el.setAttribute; // In IE some elements don't have setAttribute
		for(var attr in o){
				   if(attr == "tag" || attr == "children" || attr == "cn" || attr == "html" || attr == "style" || typeof o[attr] == "function") continue;
				   if(attr=="cls"){
				       el.className = o["cls"];
				   }else{
				       if(useSet) el.setAttribute(attr, o[attr]);
				       else el[attr] = o[attr];
				   }
			       }
		//Ext.DomHelper.applyStyles(el, o.style);
		var cn = o['children'] || o['cn'];
		if(cn){
		    createDom(cn, el);
		} else if(o['html']){
		    el.innerHTML = o['html'];
		}
	    }
	    if(parentNode){
		parentNode.appendChild(el);
	    }
	    return el;
	};

	// Mozilla 1.8 has support for indexOf, lastIndexOf, forEach, filter, map, some, every
	// http://developer-test.mozilla.org/docs/Core_JavaScript_1.5_Reference:Objects:Array:lastIndexOf
	if (!Array.prototype.indexOf) {
	    Array.prototype.indexOf = function (obj, fromIndex) {
		if (fromIndex == null) {
		    fromIndex = 0;
		} else if (fromIndex < 0) {
		    fromIndex = Math.max(0, this.length + fromIndex);
		}
		for (var i = fromIndex; i < this.length; i++) {
							       if (this[i] === obj)
							       return i;
							   }
		return -1;
	    };
	}



	String.prototype.trim = function() {
	    return this.replace(/^\s+|\s+$/g,"");
	}


	POLL.firstChildByTagName = function(node,tag) {
	    return node.getElementsByTagName(tag)[0];
	}

	// TODO: just swap the values in the input boxes
	POLL.moveUp = function(e) {
	    if (-1 != e.className.split(" ").indexOf(POLL_CSS['first'])) return false;
	    var refNode = e.parentNode.parentNode;
	    var input_1 = POLL.firstChildByTagName(refNode,'input');
	    var input_2 = POLL.firstChildByTagName(refNode.previousSibling,'input');
	    var temp = input_1.value;
	    input_1.value=input_2.value;
	    input_2.value=temp;
	    return false;
	};
	POLL.delChoice = function(e) {
	    var el = e.parentNode.parentNode;
	    el.removeChild(e.parentNode);
	    update();
	    return false;
	};
	POLL.addChoice = function(e) {
	    var d = document;
	    var el = e.parentNode;
	    var newNode=createDom({'tag':'div',
		'children':[{'tag':'div','cls':POLL_CSS['arrows'],
		    'children':[{'tag':'a','cls':POLL_CSS['action'],'href':'#','onclick':'return moveUp(this)','html':''}]},
			    {'tag':'input','cls':POLL_CSS['choice'],'type':'text','name':'choice'},
			    {'tag':'a','cls':POLL_CSS['fl'],'href':'#','onclick':'return delChoice(this)','html':'[x]'}
			   ]});

	    el.insertBefore(newNode,e);
	    return false;
	};

	POLL.get = function(id) {
	    return document.getElementById(id);
	}

	POLL.init = function() {
	    var submitEl = POLL.get(POLL_CSS['submitBtn']);
	    submitEl.disabled=true;
	    var questionEl = POLL.get(POLL_CSS['question_textarea']);
	    update();
	    questionEl.focus();
	}

	POLL.update = function() {

	    var questionEl = POLL.get(POLL_CSS['question_textarea']);
	    if (!questionEl.value || questionEl.value.trim() == '') {
		return false;
	    }
	    var count=0;
	    var inputArr = POLL.get(POLL_CSS['choices']).getElementsByTagName('input');
	    var i;
	    for(i=0;i<inputArr.length;i++) {
					    if (inputArr[i].value.trim()!='') { count++; }
					}
	    var submitEl = POLL.get(POLL_CSS['submitBtn']);
	    if (count>=POLL.MIN_CHOICES) {
		submitEl.disabled=false;
	    } else {
		submitEl.disabled=true;
	    }
	    return true;
	}

	window['POLL']=POLL;
	//window['createDom']=createDom;
	window['addChoice']=POLL.addChoice;
	window['delChoice']=POLL.delChoice;
	window['moveUp']=POLL.moveUp;
	window['update']=POLL.update;
	window['init']=POLL.init;


