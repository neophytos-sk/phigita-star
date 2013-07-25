
//streaming

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



function getData() {
  //alert('access responseText'); // hmm, IE does not allow us to access responstext in state == 3 :(
  var response = http.responseText.substring(http_last);
  var messages = document.getElementById('messages');
	var users = document.getElementById('users');
	var statusNode = document.getElementById('statusNode');
  var data;
//alert(response);
  //alert('access responseText done');
//alert(decodeURIComponent(response));
  // we recognize a complete message by a trailing }\n


  if (response.match(/\n\}\t[ ]*$/)) {

	// DEBUG - AdjustBufferSize: if (http.responseText.length - http_last < 8192) {return;}

	var cursorY=0;
	try {
		cursorY=messages.scrollHeight - messages.scrollTop - messages.offsetHeight;
	} catch (e) {
	//do nothing
	}
	var response_chunks=response.split('\t');
	for (var j=0;j<response_chunks.length-1;j++) {


    data=null;
	try {
	    data = eval('(' + response_chunks[j] + ')');
	} catch (ex) {
		alert('o diaxeiristis prepei na kamnei pellares me to sistima, please dokimase 3ana argotera j='+j);
		alert(response_chunks[j]);
	}

	//if (data.instruction) {	for (var i=0; i<data.instruction.length;i++) {alert(data.instruction[i].fn());	}}

	if (data.presence) {
	for (var i=0; i<data.presence.length;i++) {
	if (data.presence[i].user_id==user_id) {
		for (var k=0;k<statusNode.childNodes.length;k++) {
			if (statusNode.childNodes[k].value==data.presence[i].status) {
				statusNode.selectedIndex=k;
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
    for (var i=0;i<data.messages.length;i++) {
		toggleTitle();
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
	if (cursorY <= 0) {
	      messages.scrollTop = messages.scrollHeight;
	}
    }
	}
	}

    http_last = http.responseText.length;
  }
}

var http = getHttpObject();
var http_last = 0;
var http_send = getHttpObject();

function chatChangeStatus(status) {
    var currentDate = new Date();
    http_send.open('GET',status_url+status+'&s='+currentDate.getTime());
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

function pingServer() {
    var status = '';
    chatChangeStatus(status);
    setTimeout(pingServer,30000);
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





function chatSubscribe(subscribe_url) {
	var url_parts = subscribe_url.split('?');

//url_parts[1]=url_parts[1].split('&');
//  http.open('GET', subscribe_url, true);
  http.open('POST', url_parts[0], true);
//http.setRequestHeader("Transfer-Encoding", "chunked");
http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
http.setRequestHeader("Content-length", url_parts[1].length);
http.setRequestHeader("Connection", "close");

//  http.setRequestHeader('Transfer-Encoding','chunked');
  http.onreadystatechange = function() {
    if (http.readyState == 3) {
      getData();
    } else if (http.readyState == 4) {
	document.getElementById('errdiv').innerHTML='You have been disconnected.';
	document.title='[ * ] Chat-IM';
//	window.setInterval("window.location.reload(true)", 5000);
//      alert('You have been disconnected. Please refresh...');
      if (http.status == 200) {
//	document.getElementById('chatMsg').value = 'logout';
//	chatSendMsg();
//	chatLogout();
      } else {
	alert('Something wrong in HTTP request, status code = ' + http.status);
      }
    }
  };
//  http.send(null);
  http.send(url_parts[1]);
  http_last = 0;
}
function tell(msg) {
  document.monitor.window.value =  msg;
}


document.title='[ - ] Chat-IM';
ascii_spinner='-\|/';
ascii_spinner_length=ascii_spinner.length;

last_toggle_length=0; 
ascii_spinner_pos=0;

function toggleTitle(){ 
	if (http_last > last_toggle_length) { 
		ascii_spinner_pos=(ascii_spinner_pos + 1) % ascii_spinner_length; 
		document.title='[ ' + ascii_spinner.charAt(ascii_spinner_pos) + ' ] Chat-IM';
		last_toggle_length=http_last;
	}
	//setTimeout(toggleTitle,1000);
}

__adjust_buffer_size__max_runs=3;
function AdjustBufferSize() {
    if (http_last==0 && __adjust_buffer_size__max_runs--) {
	HttpSend(adjust_url);
	setTimeout(AdjustBufferSize,3000);
	//return http_last;
    }
}

//HERE: setTimeout(AdjustBufferSize,3000);
// setTimeout(pingServer,30000);

function emptyFn(){}