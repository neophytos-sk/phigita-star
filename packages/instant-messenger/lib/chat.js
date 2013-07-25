
//polling

var msgcount = 0;
var dataConnections = new Object;

function getHttpObject() {
     var http_request = false;
     if (window.XMLHttpRequest) { // Mozilla, Safari,...
         http_request = new XMLHttpRequest();
         if (http_request.overrideMimeType) {
              http_request.overrideMimeType('text/xml');
         }
     } else if (window.ActiveXObject) { // IE
         try {
             http_request = new ActiveXObject("Msxml2.XMLHTTP");
         } catch (e) {
             try {
                 http_request = new ActiveXObject("Microsoft.XMLHTTP");
             } catch (e) {}
         }
     }
     if (!http_request) {
         // alert('Cannot create an instance of XMLHTTP');
     }
   return http_request;
}

if (typeof DOMParser == "undefined") {
   DOMParser = function () {}
   DOMParser.prototype.parseFromString = function (str, contentType) {
      if (typeof ActiveXObject != "undefined") {
         var d = new ActiveXObject("MSXML.DomDocument");
         d.loadXML(str);
         return d;
        }
   }
}


function messagesReceiver(content) {
  var xmlobject = (new DOMParser()).parseFromString(content, 'application/xhtml+xml');
  var items = xmlobject.getElementsByTagName('p');
  var doc = frames['ichat'].document;
  var div = frames['ichat'].document.getElementById('messages');
  var tr, td, e, s;

var cursorY=0;
try {
cursorY=frames['ichat'].document.body.scrollHeight - frames['ichat'].document.body.scrollTop - document.getElementById('ichat').height;
} catch (e) {
//do nothing
}

  for (var i = 0 ; i < items.length ; i++) {
    p = doc.createElement('p');
    p.className = 'line';
    e = items[i].getElementsByTagName('span');
    span = doc.createElement('span');
    span.innerHTML = unescape(e[0].firstChild.nodeValue);
    span.className = 'timestamp';
    p.appendChild(span);

    span = doc.createElement('span');
    s = e[1].firstChild.nodeValue;
    span.innerHTML = unescape(e[1].firstChild.nodeValue.replace(/\+/g,' '));
    span.className = 'user';
    p.appendChild(span);

    span = doc.createElement('span');
    span.innerHTML = unescape(e[2].firstChild.nodeValue.replace(/\+/g,' '));
    span.className = 'message';
    p.appendChild(span);

    div.appendChild(p);
  }
  if (cursorY<=0) {
	  frames['ichat'].window.scrollTo(0,div.offsetHeight);
  }

}


function usersReceiver(content) {
  var xmlobject = (new DOMParser()).parseFromString(content, 'application/xhtml+xml');
  var items = xmlobject.getElementsByTagName('TR');
  var doc = frames['ichat-users'].document;
  var tbody = frames['ichat-users'].document.getElementById('users').tBodies[0];
  var tr, td, e, s, nbody;
  
  nbody = doc.createElement('tbody');
  
  for (var i = 0 ; i < items.length ; i++) {
    tr = doc.createElement('tr');
    e = items[i].getElementsByTagName('TD');
    td = doc.createElement('td');
    td.innerHTML = unescape(e[0].firstChild.nodeValue.replace(/\+/g,' '));
    td.className = 'user';
    tr.appendChild(td);
    nbody.appendChild(tr);
  }
  
  tbody.parentNode.replaceChild(nbody,tbody);
  
}

function DataConnection() {};

DataConnection.prototype = {
    handler: null,
    url: null,
    connection: null,
    
    httpSendCmd: function(url) {
	try {
        if (!this.connection) {
            this.connection = getHttpObject();
        }
        this.connection.open('GET', url + '&mc=' + msgcount++, true);
        var self = this;
        this.connection.onreadystatechange = function() {
            self.httpReceiver(self);
        }
        this.connection.send('');
	} catch(e) {
	//do nothing
	}
    },
    
    httpReceiver: function(obj) {
	try {
         if (obj.connection.readyState == 4) {
            if (obj.connection.status == 200 || obj.connection.status==0) {
                obj.handler(obj.connection.responseText);
            } else {
		//  alert('Something wrong in HTTP request, status code = ' + obj.connection.status);
            }
        }       
	} catch(e) {
	//do nothing
	}
    }, 
    
    chatSendMsg: function(send_url) {
	try {
        var msgField = document.getElementById('chatMsg');
        if (msgField.value == '') {
            return;
        }
        this.httpSendCmd(send_url + encodeURIComponent(msgField.value));
        msgField.value = '';
	} catch (e) {
		//do nothing
	}
    },   
    
    updateBackground: function() {
        this.httpSendCmd(this.url);
    }    
}

function registerDataConnection(handler,url) {
    var ds = new DataConnection(handler,url);
    ds.handler = handler;
    ds.url = url;
    dataConnections[url] = ds;
    return ds;
}

function updateDataConnections() {
    for (var ds in dataConnections) {
        dataConnections[ds].updateBackground();
    }
}

