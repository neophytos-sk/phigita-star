
function Dialog(url,action,init){if(typeof init=="undefined"){init=window;}
Dialog._geckoOpenModal(url,action,init);}
Dialog._parentEvent=function(ev){setTimeout(function(){if(Dialog._modal&&!Dialog._modal.closed){Dialog._modal.focus()}},50);try{if(Dialog._modal&&!Dialog._modal.closed){Xinha._stopEvent(ev);}}catch(e){}};Dialog._return=null;Dialog._modal=null;Dialog._arguments=null;Dialog._geckoOpenModal=function(url,action,init){var dlg=window.open(url,"hadialog","toolbar=no,menubar=no,personalbar=no,width=10,height=10,"+"scrollbars=no,resizable=yes,modal=yes,dependable=yes");Dialog._modal=dlg;Dialog._arguments=init;function capwin(w){Xinha._addEvent(w,"click",Dialog._parentEvent);Xinha._addEvent(w,"mousedown",Dialog._parentEvent);Xinha._addEvent(w,"focus",Dialog._parentEvent);}
function relwin(w){Xinha._removeEvent(w,"click",Dialog._parentEvent);Xinha._removeEvent(w,"mousedown",Dialog._parentEvent);Xinha._removeEvent(w,"focus",Dialog._parentEvent);}
capwin(window);for(var i=0;i<window.frames.length;i++){try{capwin(window.frames[i]);}catch(e){}};Dialog._return=function(val){if(val&&action){action(val);}
relwin(window);for(var i=0;i<window.frames.length;i++){try{relwin(window.frames[i]);}catch(e){}};Dialog._modal=null;};Dialog._modal.focus();};
