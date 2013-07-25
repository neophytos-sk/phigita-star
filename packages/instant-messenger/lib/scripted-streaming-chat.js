
function getHttpObject() {
  var http_request = false;
  if (window.XMLHttpRequest) { // Mozilla, Safari,...
    http_request = new XMLHttpRequest();
  } else if (window.ActiveXObject) { // IE
    try {
      http_request = new ActiveXObject('Msxml2.XMLHTTP');
    } catch (e) {
      try {
	http_request = new ActiveXObject('Microsoft.XMLHTTP');
      } catch (e) {}
    }
  }
  
  if (!http_request) {
    alert('Cannot create and instance of XMLHTTP');
  }
  return http_request;
}

function getData(data) {  
toggleTitle();

	var messages = document.getElementById('messages');
	var users = document.getElementById('users');
	var statusNode = document.getElementById('statusNode');

	if (data.presence) {
	for (var i=0; i<data.presence.length;i++) {
	if (data.presence[i].user_id==user_id) {	
		for (var k=0;k<statusNode.childNodes.length;k++) {
			if (statusNode.childNodes[k].value==data.presence[i].status) {
				statusNode.childNodes[k].setAttribute('selected',true);
			} else {
				statusNode.childNodes[k].setAttribute('selected',false);
			}
		}
		document.getElementById('chatMsg').focus();
	}
	span=null;
	span=document.getElementById('u'+data.presence[i].user_id);
	if (!span) {
	        p = document.createElement('p');
	        span = document.createElement('a');
	        span.innerHTML = data.presence[i].screen_name;
		span.setAttribute('id','u'+data.presence[i].user_id);
		span.style.cssText='color:'+data.presence[i].color+';';
		span.setAttribute('title',decodeURIComponent(data.presence[i].full_name));
		span.setAttribute('href',data.presence[i].profile_link);
		span.setAttribute('target','_blank');
	        span.className = data.presence[i].status;
	        p.appendChild(span);
	        users.appendChild(p);
	} else {
	        span.className = data.presence[i].status;
		if (data.presence[i].status == 'disconnected') {
			span.parentNode.removeChild(span);
		} else if (data.presence[i].status == 'online' && data.presence[i].color) {
			span.style.cssText='color:'+data.presence[i].color+';';
		}
	}
	}
	}

	if (data.messages) {
	var cursorY=0;
	try {
		cursorY=messages.scrollHeight - messages.scrollTop - messages.offsetHeight;
	} catch (e) {
	//do nothing
	}

    for (var i=0;i<data.messages.length;i++) {
      p = document.createElement('p');
      p.className = 'line';
      span = document.createElement('span');
      span.innerHTML = data.messages[i].time;
      span.className = 'timestamp';
      p.appendChild(span);
      
      span = document.createElement('span');
      span.innerHTML = '&nbsp;' + data.messages[i].user + '&nbsp;';
      span.className = 'user';
      p.appendChild(span);
      
      span = document.createElement('span');
      span.innerHTML = decodeURIComponent(data.messages[i].msg);
      span.className = 'message';
      p.appendChild(span);

      
      messages.appendChild(p);
	if (cursorY<=0) {
	      messages.scrollTop = messages.scrollHeight;
	}
}
}
}



var http_send = getHttpObject();
function chatChangeStatus(status) {
	http_send.open('GET',status_url+status);
	http_send.send(null);
}

function chatSendMsg() {
  var msg = document.getElementById('chatMsg').value;
  if (msg == '') {
         return;
  }
  HttpSend(send_url+encodeURIComponent(msg));
  document.getElementById('chatMsg').value = '';
}


function HttpSend(url) {
  //alert(send_url + encodeURIComponent(msg));
  http_send.open('GET', url, true);
  http_send.onreadystatechange = function() {
    if (http_send.readyState == 4) {
      if (http_send.status != 200) {
	alert('Something wrong in HTTP request, status code = ' + http_send.status);
      }
    }
  };
  http_send.send(null);
}


function tell(msg) {
  document.monitor.window.value =  msg;
}

document.title='[ - ] Chat-IM';
var ascii_spinner='-\|/';
var ascii_spinner_length=ascii_spinner.length;
var ascii_spinner_pos=0;

function toggleTitle(){ 
	ascii_spinner_pos=(ascii_spinner_pos + 1) % ascii_spinner_length; 
	document.title='[ ' + ascii_spinner.charAt(ascii_spinner_pos) + ' ] Chat-IM';
}





//test