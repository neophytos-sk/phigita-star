###ad_conn_set user_id 814
set ::csstransform false
 

ad_page_contract {
    @author Neophytos Demetriou
} {
    {url:trim ""}
    {snippet:trim,allhtml ""}
    {title:trim,allhtml ""}
    {feed:trim,allhtml ""}
    {referrer:trim ""}
    {feed:multiple,trim,notnull ""}
}

ns_log notice "feed=$feed"

set v_url [::uri::canonicalize ${url}]
set v_referrer [::uri::canonicalize ${referrer}]
set v_snippet [subst -novar -nocommand [string map {% \\} ${snippet}]]
set v_title [subst -novar -nocommand [string map {% \\} ${title}]]
set v_feed ""
if {[exists_and_not_null feed]} {
    # TODO:
    # * check if valid feed url
    # * check if url in feed / find feed that contains the given url
    # set v_feed [uri::resolve ${v_url} ${feed}]
}
array set uri [uri::split ${v_url}]

#########################################################



#set labels [[db::Set new -pathexp [list "User [ad_conn user_id]"] -select * -type ::bm::Label -order "name" -load] set result]

set rs [db::Set new -pathexp [list "User [ad_conn user_id]"] -select * -type ::bm::Bookmark -where url=[ns_dbquotevalue ${v_url}] -load]

if {![string equal [${rs} set result] {}]} {
    script -language "javascript" {
	c {
	    
	    alert("Duplicate Alert:\nThe URL you are saving already exists\nin your archive. This window will close.")
	    window.close();
	}
    }
}

#########################################################


set externs [list \
		 [acs_root_dir]/www/my/js/common-lib.js \
		 [acs_root_dir]/www/my/js/common-lib-2.js]

set URL_ADD_JS_CODE [::xo::js::get_compiled BOOKMARKS.URL_ADD {


    function CreateLabelXmlHttpHandler() {

      if (myxmlhttp.readyState != 4 || myxmlhttp.status != 200) {
        return;
      }

      var sLabelId = parseResponseHeader("Label-ID", myxmlhttp.responseText);
      var sLabelName = parseResponseHeader("Label-Name", myxmlhttp.responseText);
      var sMsg = parseResponseHeader("Info-Text", myxmlhttp.responseText);

      if (sLabelId) {
        display(sMsg);
        updateLabelMenu(sLabelId,sLabelName);
	applyLabel(sLabelId,sLabelName);
        window.setTimeout("HideMessage()",5000);
      } else {
        display(myxmlhttp.responseText);
        window.setTimeout("HideMessage()",5000);
      }

    }

    function CreateBookmarkXmlHttpHandler() {

      if (myxmlhttp.readyState != 4 || myxmlhttp.status != 200) {
        return;
      }

      var sOK = parseResponseHeader("OK", myxmlhttp.responseText);
      var sMsg = parseResponseHeader("Info-Text", myxmlhttp.responseText);

      if (sOK) {
        display(sMsg);
	window.setTimeout("window.close()",1000);
      } else {
        display(myxmlhttp.responseText);
        window.setTimeout("HideMessage()",5000);
      }

    }

    function createLabel(sLabelName) {

	var url = "labels/one-create?name=" + encodeURIComponent(sLabelName);

      myxmlhttp = CreateXmlHttpReq(CreateLabelXmlHttpHandler);
      XmlHttpGET(myxmlhttp, url);
    }

    function updateLabelMenu(sLabelId,sLabelName) {
        if (existsLabelData(sLabelId)) return true;
	var labeldataUL=document.getElementById('labeldata');
        var labeldataTEXT=document.createTextNode(sLabelName);
	var labeldataLI=labeldataLI=document.getElementById('labeldata').getElementsByTagName('li')[0].cloneNode(true);

	labeldataLI.setAttribute('id',sLabelId);
	labeldataLI.setAttribute('value',sLabelId);
	labeldataLI.removeChild(labeldataLI.firstChild);
        labeldataLI.appendChild(labeldataTEXT);
        labeldataUL.appendChild(labeldataLI);
    }

    function applyLabel(sLabelId,sLabelName) {
        if (existsLabelMap(sLabelId)) return true;
	var labelmapTD=document.getElementById('labelmap');
	var labelmapLI=document.createElement('li');
        var labelmapINPUT=document.createElement('input');
        var labelmapTEXT1=document.createTextNode(sLabelName+' ');
        var labelmapA=document.createElement('a');
        var labelmapTEXT2=document.createTextNode('[x]');
        var labelmapTEXT3=document.createTextNode(' ');

	labelmapLI.setAttribute('id',getLabelMapId(sLabelId));
        labelmapINPUT.setAttribute('type','hidden');
        labelmapINPUT.setAttribute('name','label');
	labelmapINPUT.setAttribute('value',sLabelId);

        labelmapA.setAttribute('href','');
        labelmapA.onclick=new Function('removeLabelMap('+sLabelId+');return false;');

	labelmapA.appendChild(labelmapTEXT2);
        labelmapLI.appendChild(labelmapINPUT);
        labelmapLI.appendChild(labelmapTEXT1);
        labelmapLI.appendChild(labelmapA);

        labelmapTD.appendChild(labelmapTEXT3);
        labelmapTD.appendChild(labelmapLI);

    }

    function getLabelMapId(sLabelId) {
       return 'LM'+sLabelId;
    }

    function removeLabelMap(sLabelId) {
        var obj = document.getElementById(getLabelMapId(sLabelId));
        obj.parentNode.removeChild(obj);
	return false;
    }

    function existsLabelMap(sLabelId) {
        if (document.getElementById(getLabelMapId(sLabelId))) return true; else return false;
    };

    function existsLabelData(sLabelId) {
        if (document.getElementById(sLabelId)) return true; else return false;
    };

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

	function getValue(formObj) {
	    var value;
	    if (formObj.options) { // select
		if (formObj.selectedIndex > -1)
		value = formObj.options[formObj.selectedIndex].value
	    } else {
		if (formObj.length) { // radio
		    for (var b = 0; b < formObj.length; b++)
		    if (formObj[b].checked)
		    value = formObj[b].value
		}
		else if (formObj.checked) // checkbox
		value = formObj.value
	    }
	    return value;
	}

	function nvl (v1,v2) {
	  return (v1==null || v1==undefined)?v2:v1;
	}


    function saveURL () {

      var v_feed = escape(document.forms[0].feed.value);
      var v_referrer = escape(document.forms[0].referrer.value);
      var v_url        = escape(document.forms[0].url.value);
      var v_title      = encodeURIComponent(document.forms[0].title.value);
      //var v_snippet    = encodeURIComponent(document.forms[0].snippet.value);
      var v_description= encodeURIComponent(document.forms[0].description.value);
      var v_shared_p  = getValue(document.forms[0].shared_p);
      var v_unread_p = nvl(getValue(document.forms[0].unread_p),'f');
      var v_favorite_p = nvl(getValue(document.forms[0].favorite_p),'f');
      var v_intersting_p = nvl(getValue(document.forms[0].interesting_p),'f');
      var v_sticky_p = nvl(getValue(document.forms[0].sticky_p),'f');
      var v_subscribe_p = nvl(getValue(document.forms[0].subscribe_p),'f');
      var v_cache_p = nvl(getValue(document.forms[0].cache_p),'f');
      var v_adult_p = nvl(getValue(document.forms[0].adult_p),'f');

      if (v_title==null || v_title.replace(/^\s*|\s*$/g,"")=='') {
	document.getElementById("sb").disabled=false;
	display("You must specify something for title.");
        window.setTimeout("HideMessage()",5000);
	return
      }
      if (document.forms[0].snippet.value.length>512) {
	document.getElementById("sb").disabled=false;
	display("Note is too long (max. 512 chars).");
        window.setTimeout("HideMessage()",5000);
	return
      }

      //"&snippet=" + v_snippet +

      var url = "one-create?url=" + v_url +
		"&title=" + v_title +
		"&description=" + v_description +
		"&shared_p=" + v_shared_p +
		"&favorite_p=" + v_favorite_p +
		"&interesting_p=" + v_intersting_p +
		"&unread_p=" + v_unread_p +
		"&sticky_p=" + v_sticky_p +
                "&subscribe_p=" + v_subscribe_p +
                "&cache_p=" + v_cache_p +
                "&adult_p=" + v_adult_p +
		"&feed=" + v_feed +
                "&referrer=" + v_referrer;

//(document.forms[0].label)
      var labelmap=document.getElementById("labelmap").getElementsByTagName("input");
      if (labelmap.length) {
          var i=0;
          while (labelmap[i]) {
	    url += "&label="+labelmap[i].value;
	    i++;
          }
      }
      myxmlhttp = CreateXmlHttpReq(CreateBookmarkXmlHttpHandler);
      XmlHttpGET(myxmlhttp, url);
    }

    function OnLoad() {
        var oApplyLabel = new MenuButton('applylabel',Move_Click,'labelmenu',DestinationFolder_Click); document.forms[0].elements['title'].focus();
    }

    window['saveURL']=saveURL;
    window['OnLoad']=OnLoad;
    window['applyLabel']=applyLabel;
    window['updateLabelMenu']=updateLabelMenu;
    window['display']=display;

} ADVANCED_OPTIMIZATIONS ${externs}]


global __HEAD__	
set __HEAD__ [head {
    meta -http-equiv "CONTENT-TYPE" -content "text/html; charset=UTF-8"
    title { t "phigita.net! Add URL" }
    
    script -language "javascript" -src "/js/common-lib.js"
    script -language "javascript" -src "/js/common-lib-2.js"
    script -language "javascript" { c $URL_ADD_JS_CODE }
}]

    ::xo::html::add_style {
/* Common elements */div{margin:0;}#swads{margin-top:.5em;}#swads div{height:25px;clear:both;border-style:solid;border-width:1px 0;padding:.5em .25em;font:78% verdana;}#swads img{margin-right:.5em;float:left;}#swads div.first{border-top:none;font-weight:bold;}#swads div.last{border-bottom:none;}#swads p{margin:0;padding:0;}#swads td{font-size:78%;}html>body #swads td{font-size:1em;}#swads td font{font-size:1em;}/* General application layout */#stateindicator{margin-bottom:.5em;}#applicationcontainer{border-style:solid;border-width:1px;}#applicationcontainer td#leftnav{background-repeat:repeat-x;background-position:top;padding:.75em .5em;}#applicationcontainer td#leftnavspacer { background-repeat:no-repeat;background-position:top;}#applicationcontainer td#maincontent { background-repeat:repeat-x;background-position:top;padding:.75em 0 1em 15px;}.alertbox { border-width:1px;border-style:solid;padding:.5em;margin:.5em 0;}.alertbox p{margin:0;padding:0;}.alertbox h3{font-size:100%;margin:0;}.alertbox h3 span{font-weight:normal;}.alertbox em{font-style:normal;font-weight:bold;}#footer{margin-top:1em;text-align:center;font:78% verdana;}#footer p{margin:0;padding:0;}/* Button bars */div.globalbuttonbar, div.contentbuttonbar{text-align:right;line-height:1.8em;height:2.8em;}html>body div.globalbuttonbar, html>body div.contentbuttonbar{height:2.8em;}@media all{html>body div.globalbuttonbar, html>body div.contentbuttonbar{height:1.8em;}}div.globalbuttonbar span.last button, div.contentbuttonbar span.last button{margin:0;}div.globalbuttonbar span span{display:none;}div.globalbuttonbar span.first{float:left;text-align:left;}div.globalbuttonbar span.last a{font-weight:bold;}div.globalbuttonbar span.last span{display:inline;}.contentnav{margin:4px 0;font:78% verdana;text-align:right;}.contentnav span.first{float:left;text-align:left;}.contentnav span.last span{margin-left:1em;}.contentnav #checkall, .contentnav #clearall{margin:0;cursor:pointer;cursor:hand;}#contentnavtop{border-top-width:1px;border-top-style:solid;padding-top:.5em;}.contentbuttonbar span.first{float:left;text-align:left;}/* Buttons */.button, button, .inputbutton{font:bold 78% verdana;border-style:outset; border-width:2px;}@media all{.button, button{position:relative;}}button{padding:.2em 0;cursor:pointer;cursor:hand;}html>body button{padding:.2em .8em;line-height:150%;height:1.8em;}@media all{html>body button{height:auto;position:relative;display:inline;}}.button{padding:.4em .8em;height:2em;}.button:hover{text-decoration:none;}html>body .button{height:auto;line-height:2em;}button.menubutton{background:url(/graphics/bt/bt_b_dd_2.gif) no-repeat right center;padding-right:20px;}button.hasdefaultstate{background:url(/graphics/bt/bt_s_dd_2.gif) no-repeat right center;padding-right:20px;}.contentnav #filtercontrol span{display:block;float:left;margin:0 .5em 0 0;padding:0;}.contentnav #filtercontrol span.filterbutton{background:url(/graphics/bt/bt_dd_2.gif) no-repeat 95% 50%;font:normal 100% verdana;border-width:1px;border-style:solid;padding:0 20px 0 .25em;position:relative;cursor:pointer;cursor:hand;width:auto;}/* Button menus */.buttonmenu{top:0;left:0;z-index:2;position:absolute;visibility:hidden;border-style:solid;border-width:1px;font:78% verdana;}.buttonmenu strong{display:none;}.buttonmenu ul{margin:0;list-style:none;padding:.5em;}.buttonmenu li{padding:.25em;border-width:1px;border-style:solid;cursor:pointer;cursor:hand;}.buttonmenu li.hover, #movemenu li.hover{width:100%;}.buttonmenu li a:hover{text-decoration:none;}html>body .buttonmenu ul{float:left;}@media all{html>body .buttonmenu ul{float:none;width:auto;}}html>body .buttonmenu li{float:left;display:block;clear:both;white-space:nowrap;}@media all{html>body .buttonmenu li{float:none;clear:none;display:list-item;width:auto;}}#labelmenu li{background:url(/graphics/perc1.gif) left center no-repeat;margin:0;padding:.25em .25em .25em 2em;white-space:nowrap;}html>body #movemenu li{padding-left:20px;}.overflow{width:200px;height:150px;overflow:auto;}    .overflowX{width:200px;overflow:auto;}html>body .overflowX{overflow:-moz-scrollbars-horizontal;}.overflowY{height:150px;overflow:auto;}html>body .overflowY{overflow:-moz-scrollbars-vertical;}/* Button bars */#contentbuttonbartop{border-bottom-color:#C1C1C1;}/* Buttons */button, .button, .inputbutton, button.menubutton, button.hasdefaultstate{background-color:#E6E6E6;border-color:#FFF #C1C1C1 #C1C1C1 #FFF;color:#333;}/* Button Menus */.buttonmenu{border-color:#C1C1C1;background-color:#F6F6F6;}.buttonmenu li, #movemenu li{border-color:#F6F6F6;}.buttonmenu li.hover, #movemenu li.hover, .buttonmenu li:hover, #movemenu li:hover{background-color:#E6E6E6;border-color:#C1C1C1;}

	.errMsg {
	  display:none;
	  padding:2 7; 
	  background: #FAD163;
	  font-size:small; 
	  font-weight:bold; 
          border-radius:1em; 
	  -moz-border-radius:1em;
	} 

	#labelmap li {color:#063; border: 1px solid #20ff40; background:#c0ffd0;padding: 1px;margin: 0px 0px 3px 0px; font-size:14px; 	  line-height:28px;  	  list-style: none;	  display: inline;	}

	#labelmap a {	  color:blue;text-decoration:underline;	}

	#bmmd th {	  background:#cccccc;	}

	#bmmd td {	  background:#f0f0f0;	}

	#u { color:#66e; }
	#f { color:#36a; }
	#s { color:#e5dc5c;}
	#x { color:#666; }
        #i {color:dc5ce5;}
 
        .fl {
	color:#7777CC;
	text-decoration:underline;
	cursor:pointer;
	display:inline;
	}
    }

body -onload "OnLoad();" {
  form -name "url-add-form" -method "post" -onsubmit "document.getElementById('sb').disabled=true;saveURL();return false;" {
      input -type hidden -name feed -value ${v_feed}
      input -type hidden -name referrer -value ${v_referrer}
    table -width "100%" -border "0" -cellpadding "4" -cellspacing "0" {
      tr -bgcolor "#EEF3FB" {
	td -align "left" { 
	    div -id "errMsgDiv" -class "errMsg" { t -disableOutputEscaping "&nbsp;" } 
        }
	td -align "right" { button -type "submit" -id "sb" -name "sb" { t "Save" } }
      }
    }
    p
    table -width "100%" -border "0" -cellpadding "2" -cellspacing "0" -bgcolor "#EEF3FB" {
      tr {
        td {
          table -cellspacing "0" -cellpadding "0" -border "0" -bgcolor "ffffff" {
            tr {
              td {
                font -size "-3" { t -disableOutputEscaping "&nbsp;" }
              }
            }
	   tr {
	     td -align "right" -valign "top" {
	       b { font -face "Arial" -size "-1" { t "URL:" } }
	       t -disableOutputEscaping "&nbsp;&nbsp;"
             }
	     td -width "100%" {
		 input -name "url" -type "text" -value ${v_url} -size "45" ;# -disabled ""
	       br
	       font -size "-3" { br }
	     }
	   }
	   tr {
	     td -align "right" -valign "top" {
		 b { font -face "Arial" -size "-1" { t "Note:" } }
		 t -disableOutputEscaping "&nbsp;&nbsp;" 
             }
	       td  {
		   textarea -name description -rows 4 -cols 55 {
		       t ${v_snippet}
		   }
		   br
		   font -size "-3" { br } 
	       }
	   }
	   tr {
	     td -align "right" -valign "top" {
	       b { font -face "Arial" -size "-1" { t "Title:" } }
	       t -disableOutputEscaping "&nbsp;&nbsp;"
             }
	     td {
               input -type "text" -id "title" -name "title" -value ${v_title} -size "45" -maxlength "255"
	       br
	       font -size "-3" { br }
             }
           }
         }
       }
     }
   }
   font -size "-3" { br }
   table -id "bmmd" -cellpadding "2" -cellspacing "2" -align "center" -width "100%" {
     tr {
       th {
         b { t "Access" }
       }
       th {
	   b { t -disableOutputEscaping "Flags" }
       }
       th -width "100%" -align "center" -valign "top" {
         div -style "margin:0" {
           input -type "hidden" -name "NewFol" -value ""
	   input -type "hidden" -name "destBox" -value ""
           input -type "hidden" -name "newfoldermessage" -id "newfoldermessage" -value "Please enter a new label name:"
         }
	 div -id "contentbuttonbartop" -class "contentbuttonbar" {
	   button -type "button" -id "applylabel" -name "applylabel" -class "menubutton" -title "Apply label to blog entry." { t "Apply Label..." }
         }
       }
     }
     tr {
       td -valign "top" -nowrap "" {
         small {
           input -type "radio" -name "shared_p" -value "f" -size "40" -checked "" -id "shared_p:f"
           label -for "shared_p:f" { t "Private" }
           t -disableOutputEscaping "&nbsp;&nbsp;&nbsp;"
           br
           input -type "radio" -name "shared_p" -value "t" -size "40" -id "shared_p:t"
           label -for "shared_p:t" { t "Public" }
           t -disableOutputEscaping "&nbsp;&nbsp;&nbsp;"
         }
       }
       td -align "left" -valign "top" -nowrap "" {
	   small {
	       #input -type checkbox -name "unread_p" -id "unread_p" -value "t"
	       #label -for "unread_p" { t -disableOutputEscaping "mark as unread \[&nbsp;<b id=u>U</b>&nbsp;\]" }
	       #br
	       input -type checkbox -name "favorite_p" -id "favorite_p" -value "t"
	       label -for "favorite_p" { t -disableOutputEscaping "starred \[&nbsp;<b id=f>&#9733;</b>&nbsp;]" }
	       br
	       #input -type checkbox -name "interesting_p" -id "interesting_p" -value "t"
	       #label -for "interesting_p" { t -disableOutputEscaping "interesting \[&nbsp;<b id=i>I</b>&nbsp;]" }
	       #br
	       input -type checkbox -name "sticky_p" -id "sticky_p" -value "t"
	       label -for "sticky_p" { t -disableOutputEscaping "sticky link \[&nbsp;<b id=s>S</b>&nbsp;\]" }
	       br
	       input -type checkbox -name "adult_p" -id "adult_p" -value "t"
	       label -for "adult_p" -title "Not Safe For Work" { t -disableOutputEscaping "NSFW  \[&nbsp;<b id=x>X</b>&nbsp;\]" }	       
	       br
	       eval input -type hidden -name "subscribe_p" -id "subscribe_p" -value "t" [ad_decode ${feed} "" {-disabled ""} ""]
#	       label -for "subscribe_p" { t "subscribe to feed" }
	       br
	       input -type hidden -name "cache_p" -id "cache_p" -value "t"
#	       label -for "cache_p" { t "cache text" }
	   }
       }
       td -id "labelmap" -valign "top" {
         t -disableOutputEscaping "&nbsp;"
       }
     }
   }
  }

    set comment {
	t "Jump to: "
	div -class "fl" -onclick "window.open('/','_blank');window.close();" {
	    t "phigita.net"
	}
	t " - "
	div -class "fl" -onclick "window.open('.','_blank');window.close();" {
	    t "your bookmarks"
	}
	t " - "
	div -class "fl" -onclick "window.open('/links/','_blank');window.close();" {
	    t "social links"
	}
    }
}

