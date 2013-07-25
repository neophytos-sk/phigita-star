// XMLhttpRequest stuff
var aXmlHttp = new Array();
var aXmlResponse = new Array();
function xmlResult()
{
    for(var i=0;i<aXmlHttp.length;i++)
    {
        if(aXmlHttp[i] && aXmlHttp[i][0] && aXmlHttp[i][0].readyState==4&&aXmlHttp[i][0].responseText)
        {
            //must null out record before calling function in case
            //function invokes another xmlHttpRequest.
            var f = aXmlHttp[i][2];
            var o = aXmlHttp[i][1];
            var s = aXmlHttp[i][0].responseText;
            aXmlHttp[i][0] = null;
            aXmlHttp[i][1] = null;
            aXmlHttp[i] = null;
            f.apply(o,new Array(s));
        }
    }
}

// u -> url
// o -> object (can be null) to invoke function on
// f -> callback function
// p -> optional argument to specify POST
function call(u,o,f)
{
    var method = "GET";
    var dat;
    if (arguments.length==4){
      method = "POST";
      tmp = u.split(/\?/);
      u = tmp[0];
      dat = tmp[1];

    }
    var idx = aXmlHttp.length;
    for(var i=0; i<idx;i++)
    if (aXmlHttp[i] == null)
    {
        idx = i;
        break;
    }
    aXmlHttp[idx]=new Array(2);
    aXmlHttp[idx][0] = getXMLHTTP();

    aXmlHttp[idx][1] = o;
    aXmlHttp[idx][2] = f;
    if(aXmlHttp[idx])
    {
        aXmlHttp[idx][0].open(method,u,true);
        if(method == "POST"){
          aXmlHttp[idx][0].setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

          aXmlHttp[idx][0].send(dat);
        }
        aXmlHttp[idx][0].onreadystatechange=xmlResult;
        
       if(method =="GET"){ aXmlHttp[idx][0].send(null);}
    }
}

function getXMLHTTP()
{
    var A=null;
    if(!A && typeof XMLHttpRequest != "undefined")
    {
        A=new XMLHttpRequest();
    }
    if (!A)
    {
        try
        {
            A=new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch(e)
        {
            try
            {
                A=new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch(oc)
            {
                A=null
            }
        }
    }    
    return A;
}

function drawNull(s)
{
    eval(s);
    return false;
}
