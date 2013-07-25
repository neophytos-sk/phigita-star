<html>
<head>
<META HTTP-EQUIV="CONTENT-TYPE" CONTENT="text/html; charset=UTF-8">
<META NAME="ROBOTS" CONTENT="NOARCHIVE"> 
<title>@title@</title>
@header_stuff@
<style><!--
body,td,font,.p,a{font-family:arial,sans-serif}
.q a:visited,.q a:link,.q a:active,.q {color: blue;}
//-->
</style>
<if @javascript@ not nil>
<script language="">
<!--
@javascript;noquote@
-->
</script>
</if>
</head>
<body<multiple name=attribute> @attribute.key@="@attribute.value@"</multiple>>
<form name=ps action=/search/ method=GET>
<table><tr><td>&nbsp;&nbsp;&nbsp;<a href="/"><img src="/graphics/logo.gif" width="173" height="35" border="0"></a></td>
<if @user_id@ eq 0>
<td width=7>&nbsp;</td>
<td nowrap><font size=-1>
<a class=q href="/preferences/?return_url=@return_url@"><trn key="Preferences">Preferences</trn></a>&nbsp;-&nbsp;<a href="/my/"><b><a class=q href=/accounts/?return_url=@return_url@><trn key="Registration_Message">Sign in</trn></a></b></font><br>
</if><else>
<td width="7">&nbsp;</td><td nowrap><font size="-1">
<a class=q href="/preferences/?return_url=@return_url@"><trn key="Preferences">Preferences</trn></a>&nbsp;-&nbsp;<a class=q href="/my/"><trn key="Your_Workspace">Your Workspace</trn></a>&nbsp;-&nbsp;<a class=q href="/accounts/logout"><trn key="Logout">Logout</trn></a></font><br>
</font>
</else>
<input type=text name=q size=31 maxlength=256><input type=submit value=<trn key="Search">Search</trn>></form></td><td width="100%">&nbsp;</td>
<td width="7">&nbsp;</td></tr></table><hr size=-1 noshade>

<!--
<if @context_bar@ not nil>
<font face=Arial size=-1 color=666666><trn key="You_Are_Here">You Are Here:</trn></font> @context_bar;noquote@
</if>
-->
<p>
<slave>

<p>


<include src=g11n>

<hr size=1 noshade>
<i><font size="-1"><trn key="Powered_By">Powered by the blood, sweat, and tears of the phigita.net community.</trn></font></i>

<p>
<font size=-1 color=666666>Copyright &copy; 2003 Phigita Ltd. All Rights Reserved.</font>

</body>
</html>

