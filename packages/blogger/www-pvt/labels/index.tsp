
set pathexp [list "User [ad_conn user_id]"]
set labeldata [db::Set new -pathexp ${pathexp} -select "*" -type ::Blog_Item_Label -order "name" -load]

script -language "javascript" -src "/js/common-lib.js"
script -language "javascript" {
    c {
	function check(func,label,count){
	    if (func==0) {
		return confirm("Remove the label \"" + label + "\" from " + count + " entries and delete the label?");
	    }
	    return true;
	}

	function CollapseWhitespace(str) {
	    return str.replace(/\s+/g," ").replace(/^ /,"").replace(/ $/,"");
	}

	function IsEmpty(str) {
	    return CollapseWhitespace(str)=="";
	}

	function Set(array) {
	    if (array) {
		for(var i=0;i<array.length;i++) { 
		    this.add(array[i]);
		}
	    }
	}

	Set.prototype.add=function (entry){this[':'+entry]=1;};
	Set.prototype.remove=function (entry){delete this[':'+entry];};
	Set.prototype.contains=function (entry){return (this[':'+entry]==1);};

	function PR_OnCreateLabelChanged(win, text,e) {
	    try{
		var button=document.getElementsByTagName("button")[0];
		button.disabled=(IsEmpty(text.value));
	    } catch(e2) {
	    }
	}

	var cat_re_=/^[^^]+$/;
	var bad_label_names=new Set(['inbox','star','starred','draft','drafts','sent','sentmail','sent-mail','sent mail','all','allmail','all-mail','all mail','anywhere','archive','spam','trash']);
	function ValidateCategoryName(cat) {
	    if (cat.length>30) {
		return "The name is too long.";
	    } else {
		if (IsEmpty(cat)) {
		    return "No name specified.";
		} else {
		    if (!cat_re_.test(CollapseWhitespace(cat))) {
			return "The ^ character is not allowed.";
		    } else {
			if (bad_label_names.contains(cat.toLowerCase())) {
			    return "System specific label names are not allowed.";
			}
		    }
		}
	    }
	    return null;
	}

	function PromptNewCategory(prompt_str, default_text) {
	    var cat=prompt(prompt_str,default_text);
	    while (cat!=null) {
		var error=ValidateCategoryName(cat);
		if (!error) {return cat;}
		cat=prompt(error + " Please try another label name:", cat);
	    }
	    return null;
	}


    function PR_RenameLabelXmlHttpHandler() {

      if (myxmlhttp.readyState != 4 || myxmlhttp.status != 200) {
        return;
      }
      var sLabelId = parseResponseHeader("Label-ID", myxmlhttp.responseText);
      var sLabelName = parseResponseHeader("Label-Name", myxmlhttp.responseText);
      var sS = parseResponseHeader("S", myxmlhttp.responseText);
      var sMsg = parseResponseHeader("Info-Text", myxmlhttp.responseText);
      if (sS) {
	if (sS=='NU') {
	  // Name Updated
	  UpdateMenuAfterRename(sLabelId,sLabelName);
	}
	if (errMsgTimeout) window.clearTimeout(errMsgTimeout);
        display(sMsg);
        errMsgTimeout=window.setTimeout("HideMessage()",5000);
      } else {
	if (errMsgTimeout) window.clearTimeout(errMsgTimeout);
        display(myxmlhttp.responseText);
        errMsgTimeout=window.setTimeout("HideMessage()",5000);
      }

    }

	function PR_RenameLabel(cat_id,cat_name) {
	    var name=PromptNewCategory('What would you like to call this label?', cat_name);
	    if (!name) return false;
	    var url = "one-rename?id="+cat_id+"&name=" + encodeURIComponent(name) + "&oldname="+encodeURIComponent(cat_name);
	    myxmlhttp = CreateXmlHttpReq(PR_RenameLabelXmlHttpHandler);
	    XmlHttpGET(myxmlhttp, url);
	}

    function display (msg) {
        var errMsgDiv = document.getElementById("errMsgDiv");
        errMsgDiv.innerHTML=msg;
        errMsgDiv.style.display='inline';
    }

    function HideMessage () {
        var errMsgDiv = document.getElementById("errMsgDiv");
        errMsgDiv.style.display='none';
        errMsgDiv.innerHTML="";

    }

    function UpdateMenuAfterRemove(sLabelId) {
	document.getElementById('labeldata').removeChild(document.getElementById(sLabelId));
    }

    function UpdateMenuAfterRename(sLabelId,sLabelName) {
	var o=document.getElementById(sLabelId).childNodes[2].childNodes[1];
	o.appendChild(document.createTextNode(sLabelName));
	o.removeChild(o.firstChild);
	document.getElementById(sLabelId).getElementsByTagName('a')[0].onclick=new Function('PR_RenameLabel('+sLabelId+',\''+sLabelName+'\');return false;');
	document.getElementById(sLabelId).getElementsByTagName('a')[1].onclick=new Function('PR_RemoveLabel('+sLabelId+',\''+sLabelName+'\',0);return false;');

    }

    function UpdateMenuAfterCreate(sLabelId,sLabelName) {
        var labeldataUL=document.getElementById('labeldata');
        var labeldataLI=document.createElement('li');
        var labeldataA1=document.createElement('a');
        var labeldataA2=document.createElement('a');
        var labeldataA3=document.createElement('a');
        var labeldataD1=document.createElement('div');
        var labeldataD2=document.createElement('div');
        var labeldataTEXT1=document.createTextNode(sLabelName);
        var labeldataTEXT2=document.createTextNode(' 0 entries ');

        labeldataLI.setAttribute('id',sLabelId);
        labeldataA1.setAttribute('href','../?label_id='+sLabelId);
        labeldataA1.className='cs';

        labeldataA2.className='lk';
        labeldataA2.setAttribute('href','one-rename?id='+sLabelId);
        labeldataA2.onclick=new Function('PR_RenameLabel('+sLabelId+',\''+sLabelName+'\');return false;');
        labeldataA2.appendChild(document.createTextNode('rename'));

        labeldataA3.className='lk';
        labeldataA3.setAttribute('href','one-delete?id='+sLabelId);
        labeldataA3.onclick=new Function('PR_RemoveLabel('+sLabelId+',\''+sLabelName+'\',0);return false;');
        labeldataA3.appendChild(document.createTextNode('remove'));

        labeldataD1.className='ldiv';
        labeldataD2.className='rdiv';

        labeldataA1.appendChild(labeldataTEXT1);
        labeldataD1.appendChild(document.createTextNode(' '));
        labeldataD1.appendChild(labeldataA1);
        labeldataD1.appendChild(document.createElement('br'));
        labeldataD1.appendChild(labeldataTEXT2);
        labeldataD2.appendChild(labeldataA2);
        labeldataD2.appendChild(labeldataA3);
        labeldataLI.appendChild(document.createTextNode(''));
        labeldataLI.appendChild(labeldataD2);
        labeldataLI.appendChild(labeldataD1);
        labeldataUL.appendChild(labeldataLI);
    }

    function CreateLabelXmlHttpHandler() {

      if (myxmlhttp.readyState != 4 || myxmlhttp.status != 200) {
        return;
      }

      var sLabelId = parseResponseHeader("Label-ID", myxmlhttp.responseText);
      var sLabelName = parseResponseHeader("Label-Name", myxmlhttp.responseText);
      var sS = parseResponseHeader("S", myxmlhttp.responseText);
      var sMsg = parseResponseHeader("Info-Text", myxmlhttp.responseText);

      if (sLabelId) {
	if (sS=='OC') {
	    document.getElementById('plt').value='';
	    document.getElementById('plb').disabled=true;
	    UpdateMenuAfterCreate(sLabelId,sLabelName);
	}
	if (sS=='OE') {
	  document.getElementById('plb').disabled=false;
	}
	if (errMsgTimeout) window.clearTimeout(errMsgTimeout);
        display(sMsg);
        errMsgTimeout=window.setTimeout("HideMessage()",5000);
      } else {
	if (errMsgTimeout) window.clearTimeout(errMsgTimeout);
        display(myxmlhttp.responseText);
        errMsgTimeout=window.setTimeout("HideMessage()",5000);
      }

    }

	function CreateLabel() {
	    var sLabelName=document.getElementById('plt').value;
	    var url = "one-create?name=" + encodeURIComponent(sLabelName);
	    myxmlhttp = CreateXmlHttpReq(CreateLabelXmlHttpHandler);
	    XmlHttpGET(myxmlhttp, url);
	}


    function PR_RemoveLabelXmlHttpHandler() {

      if (myxmlhttp.readyState != 4 || myxmlhttp.status != 200) {
        return;
      }

      var sLabelId = parseResponseHeader("Label-ID", myxmlhttp.responseText);
      var sLabelName = parseResponseHeader("Label-Name", myxmlhttp.responseText);
      var sS = parseResponseHeader("S", myxmlhttp.responseText);
      var sMsg = parseResponseHeader("Info-Text", myxmlhttp.responseText);

      if (sS=='OD') {
	document.getElementById('plt').value='';
	document.getElementById('plb').disabled=true;
	UpdateMenuAfterRemove(sLabelId);
	if (errMsgTimeout) window.clearTimeout(errMsgTimeout);
        display(sMsg);
        errMsgTimeout=window.setTimeout("HideMessage()",5000);
      } else {
	if (errMsgTimeout) window.clearTimeout(errMsgTimeout);
        display(myxmlhttp.responseText);
        errMsgTimeout=window.setTimeout("HideMessage()",5000);
      }

    }

	function PR_RemoveLabel(catid,name,count) {
	    if (!check(0,name,count)) return false;
	    var url = "one-delete?id=" + catid + "&name="+encodeURIComponent(name);
	    myxmlhttp = CreateXmlHttpReq(PR_RemoveLabelXmlHttpHandler);
	    XmlHttpGET(myxmlhttp, url);
	}


	function OnLoad() {
		PR_OnCreateLabelChanged(window, document.getElementById('plt'));
	}

	var errMsgTimeout;
	var sURL=unescape(window.location.pathname);
    }
}

style {
    c {
        .errMsg {
          display:none;
          padding:2 7;
          background: #FAD163;
          font-size:small;
          font-weight:bold;
          border-radius:1em;
          -moz-border-radius:1em;
	  width:450;
        }

	#labeldata {padding:0;margin:0;}
	#labeldata li {background:#FFF7D7;border-top: 2px solid #FAD163;list-style:none;padding: 5 10 5 10;}

	.rdiv {
	  float:right;
	  line-height:2em;
	}

	.pe {font-size:85%;}
	.pr {background:"#FAD163"}
        .cs {color: #063;  white-space:nowrap;font-weight:bold;} 
	    .lk {color: #0000CC; text-decoration:underline; cursor:pointer;cursor:hand; white-space:nowrap;padding:3;}
	    }
	}

	tmpl::master -title "Blog Labels" -context_bar [ad_context_bar "Labels"] -onload "OnLoad();" {
	    center {
              div -id "errMsgDiv" -class "errMsg" { t -disableOutputEscaping "&nbsp;" }
	    }
	p
	    table -class "pe" -cellspacing 0 -cellpadding 6 -border 0 -width "100%" {
		tr -bgcolor "#FFF7D7" -style "padding-top:16" {
		    td -colspan "3" -align "center" {
			form -style "margin:0" -method "post" -onsubmit "document.getElementById('plb').disabled=true;CreateLabel();return false;" {
			    span -style "font-size:85%" {
				b {
				    t -disableOutputEscaping "Create new label:&nbsp;"
				}
				input -type "text" -size "20" -maxlength "30" -id "plt" -onkeyup "return PR_OnCreateLabelChanged(window,this,event)" -name "name"
				t -disableOutputEscaping "&nbsp;"
				button -id "plb" -name "plb" -type submit -disabled "" {
				    t "Create"
				}
			    }
			    br
			    br
			    if { ![${labeldata} emptyset_p] } {
				b {
				    t -disableOutputEscaping "Note:"
				}
				t -disableOutputEscaping "&nbsp;Removing a label will not delete the entries with that label."
			    }
			    tr {
				td -colspan "3" -height "2" -class "pr" style "padding:0" {
				}
			    }
			}
		    }
		}
	}

	    ul -id "labeldata" {
		foreach labelObj [${labeldata} set result] {
		    li -id [${labelObj} set id] {
			div -class "rdiv" {
			  a -class "lk" -href "one-rename?id=[${labelObj} set id]" -onclick "PR_RenameLabel([${labelObj} set id],'[${labelObj} set name]');return false;" {
			    t "rename"
			  }
			  t " "
			  a -class "lk" -href "one-delete?id=[${labelObj} set id]" -onclick "PR_RemoveLabel([${labelObj} set id],[${labelObj} quoted name],[${labelObj} set cnt_entries]);return false;" {
			    t "remove"
			  }
			}
			div -class "ldiv" {
			  a -class "cs" -href "../?label_id=[${labelObj} set id]" {
			    t [${labelObj} set name]
			  }
			  br
		          t " [${labelObj} set cnt_entries] [ad_decode [${labelObj} set cnt_entries] 1 entry entries] "
			}			
		    }
		}
	    }
	}

