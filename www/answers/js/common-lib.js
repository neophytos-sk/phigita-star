 
//------------------------------------------------------------------------
// Browser detect
//------------------------------------------------------------------------

var agt = navigator.userAgent.toLowerCase();
var is_ie = (agt.indexOf("msie") != -1);
var is_ie5 = (agt.indexOf("msie 5") != -1);
var is_opera = (agt.indexOf("opera") != -1);
var is_mac = (agt.indexOf("mac") != -1);
var is_gecko = (agt.indexOf("gecko") != -1);
var is_safari = (agt.indexOf("safari") != -1);

// Returns whether caribou supports this browser
// Currently supports IE5+ and Moz1.4+
function Supported() {

  // !is_opera: Opera can include the MSIE string when it masquerades as IE
  // !is_mac: Omniweb includes MSIE string
  if (is_ie && !is_opera && !is_mac) {

    var version = GetFollowingFloat(agt, "msie ");
    if (version != null) {
      return (version >= 5.5);
    }
  }

  // check for Moz1.4+

  // !is_safari: Safari includes Gecko string
  if (is_gecko && !is_safari) {

    var version = GetFollowingFloat(agt, "rv:");
    if (version != null) {
     return (version >= 1.4);

    } else {
      // no rv: version; check for Galeon versions that did't include rv:
      var i = agt.indexOf("galeon");
      version = GetFollowingFloat(agt, "galeon/");

      if (version != null) {
        // Galeon 1.3+ can be used with Moz 1.3+
        // to really check for Gecko 1.4+, should parse the date string
        // following "Gecko/"
        return (version >= 1.3);
      }
    }
  }

  // check for Safarai 1.2.1+
  if (is_safari) {
    var version = GetFollowingFloat(agt, "applewebkit/");
    if (version != null) {
      return (version >= 124);
    }
  }

  return false;
}

// Returns whether caribou supports this browser
// Currently supports IE5+ and Moz1.4+
function CheckBrowser(continueUrl) {
 
  if (!Supported()) {
    // unsupported browser
    var continueParam = escape(continueUrl);
    var url = "http://www.phigita.net/help/browser_requirements.html";
    url = url + "?continue=" + continueParam;

    top.location = url;
  }
}

// returns a float, so for a version only returns major.minor;
// doesn't return smaller grain versions
// if not found, return null
function GetFollowingFloat(str, prefix) {
  var i = str.indexOf(prefix);
  if (i != -1) {
    var version = parseFloat(str.substring(i + prefix.length));
    if (!isNaN(version)) {
      return version;
    }
  }
  return null;
}

//------------------------------------------------------------------------
// Communication with server
//------------------------------------------------------------------------

function CreateXmlHttpReq(handler) {

  var xmlhttp = null;
  if (is_ie) {
    // Guaranteed to be ie5 or ie6
    var control = (is_ie5) ? "Microsoft.XMLHTTP" : "Msxml2.XMLHTTP";

    try {
      xmlhttp = new ActiveXObject(control);
      xmlhttp.onreadystatechange = handler;
    } catch (ex) {
      // TODO: better help message
      alert("You need to enable active scripting and activeX controls");  
    }

  } else {

    // Mozilla
    xmlhttp = new XMLHttpRequest();
    xmlhttp.onload = handler;
    xmlhttp.onerror = handler;

  }

  return xmlhttp;
}

// XMLHttp send POST request
function XmlHttpPOST(xmlhttp, url, data) {
  try {
    xmlhttp.open("POST", url, true);
    xmlhttp.send(data);

  } catch (ex) {
    // do nothing
  }
}

// XMLHttp send GEt request
function XmlHttpGET(xmlhttp, url) {
  try {
    xmlhttp.open("GET", url, true);	
    xmlhttp.send(null);

  } catch (ex) {
    // do nothing
  }
}

//------------------------------------------------------------------------
// Response
//------------------------------------------------------------------------

    /**
     * Trim Function (trims leading and trailing whitespace)
     * This function is used by parseResponseHeader, needed because the
     * split function in IE doesn't strip the trailing "\n"
     */
    function trim(value) {
	return value;
       var temp = value;
       var obj = /^(\s*)([\W\w]*)(\b\s*$)/;
       if (obj.test(temp)) {
         temp = temp.replace(obj, '$2');
       }
       return temp;
    }


    function parseResponseHeader(key, header) {

      var lines = header.split("\n");
      var re = new RegExp("^" + key + ":\\s");

      for (var i in lines) {
        if (re.exec(lines[i])) {
          var returnValue = trim(RegExp.rightContext);
          return returnValue;
        }
      }
      return "";
    }



        function delay(gap) { /* gap is in millisecs */
            var then,now;
            then=new Date().getTime();
            now=then;
            while((now-then)<gap) {
                now=new Date().getTime();
            }
        }//

