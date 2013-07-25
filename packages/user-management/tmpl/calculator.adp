<script language="javascript">
<!--
var finished=0
var mem=""

function bck() {
   tmp = document.pad.box.value
   tmplen = tmp.length
   tmp = tmp.substring(0,tmplen-1)
   document.pad.box.value = tmp
}

function key(data) {
   if ( (data=="/") || (data=="*") || (data=="-") || (data=="+")) {
       finished=0
   }
   if (finished) {
       document.pad.box.value=""
       finished=0
   }
   document.pad.box.value += data
}

function MP() {
   mem=document.pad.box.value
}

function MR() {
   if (finished) {
      document.pad.box.value=""
      finished=0
   }
   document.pad.box.value += mem
}
function done() {
   document.pad.box.value = eval(document.pad.box.value)
   finished=1
}

function clrx() {
   document.pad.box.value = ""
}

function backspace() {
   tmp = document.pad.box.value
   tmplen = tmp.length
   tmp = tmp.substring(0,tmplen-1)
   document.pad.box.value = tmp
}

function powx() {
   tmp = document.pad.box.value;
   document.pad.box.value="Math.pow("+tmp+",)"
}

function plusminus() {
   document.pad.box.value=eval("-("+document.pad.box.value+")")
   finished=1
}


function invx() {
   document.pad.box.value=eval("1/("+document.pad.box.value+")")
   finished=1

}

function squareRoot() {
   document.pad.box.value=eval("Math.sqrt("+ document.pad.box.value+")")
   finished=1
}


function errorHandler(message, url, line) {
   alert("sorry, there was a "+message)
   return true
}

window.onerror = errorHandler

//-->
</script>
<table border=0 cellpadding=4 cellspacing=0 width="100%"  bgcolor="eeeeee"><tr><td>
<form name="pad" onsubmit="done();return false">
<table width="100%" cellpadding=0 cellspacing=0 border=0 bgcolor=#3e3e68>
<tr><td align=center><input type=text size=20 name=box></td></tr>
<tr><td align=center><img usemap="#calcMap" src="/graphics/calculator" width="204" height="189"
alt="" border="0">
<map name="calcMap">
<area SHAPE="RECT" COORDS="27,22,52,47" HREF="javascript:key('7')">
<area SHAPE="RECT" COORDS="56,22,81,47" HREF="javascript:key('8')">

<area SHAPE="RECT" COORDS="85,22,110,47" HREF="javascript:key('9')">
<area SHAPE="RECT" COORDS="115,22,140,47" HREF="javascript:key('/')">
<area SHAPE="RECT" COORDS="143,22,168,47" HREF="javascript:squareRoot()">
<area SHAPE="RECT" COORDS="27,50,52,75" HREF="javascript:key('4')">
<area SHAPE="RECT" COORDS="56,50,81,75" HREF="javascript:key('5')">
<area SHAPE="RECT" COORDS="85,50,110,75" HREF="javascript:key('6')">
<area SHAPE="RECT" COORDS="115,50,140,75" HREF="javascript:key('*')">
<area SHAPE="RECT" COORDS="143,50,168,75" HREF="javascript:invx()">
<area SHAPE="RECT" COORDS="27,79,52,104" HREF="javascript:key('1')">
<area SHAPE="RECT" COORDS="56,79,81,104" HREF="javascript:key('2')">
<area SHAPE="RECT" COORDS="85,79,110,104" HREF="javascript:key('3')">
<area SHAPE="RECT" COORDS="115,79,140,104" HREF="javascript:key('-')">
<area SHAPE="RECT" COORDS="143,79,168,104" HREF="javascript:MR()">
<area SHAPE="RECT" COORDS="27,108,52,133" HREF="javascript:key('0')">
<area SHAPE="RECT" COORDS="56,108,81,133" HREF="javascript:key('.')">
<area SHAPE="RECT" COORDS="85,108,110,133" HREF="javascript:plusminus()">
<area SHAPE="RECT" COORDS="115,108,140,163" HREF="javascript:key('+')">

<area SHAPE="RECT" COORDS="143,108,168,133" HREF="javascript:MM()">
<area SHAPE="RECT" COORDS="27,136,52,161" HREF="javascript:clrx()">
<area SHAPE="RECT" COORDS="56,136,81,161" HREF="javascript:bck()">
<area SHAPE="RECT" COORDS="85,136,110,161" HREF="javascript:done()">
<area SHAPE="RECT" COORDS="143,136,168,161" HREF="javascript:MP()">
</map>
</td></tr></table>
</form>
</td></tr></table>
