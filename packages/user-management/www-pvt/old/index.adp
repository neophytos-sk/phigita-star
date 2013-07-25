<%

set context_bar [ad_context_bar]

%>

<master>
<property name="title">Your Workspace</property>
<property name="context_bar">@context_bar@</property>


<table><tr><td width=100% valign=top>

<ul> <trn key="Account_Information">Account Information</trn>
<li> <a href=/register/logout><trn key="Logout">Logout</trn></a>
<li> <a href=/my/password-update><trn key="Update_Password">Change your password</trn></a>
<li> <a href="/my/basic-info-update"><trn key="Update_Info">Update Info</trn></a><li> <a href="/my/notifications/"><trn key="Notifications">Notifications</trn></a>
</ul>

<ul> <trn key="Personal_Assistant">Personal Assistant</trn>
<li> <a href=address-book/><trn key="Address_Book">Address Book</trn></a>
<li> <a href=bookmarks/><trn key="Bookmarks">Bookmarks</trn></a>
<li> <a href=calendar/><trn key="Calendar">Calendar</trn></a>
<li> <a href=webmail/><trn key="Webmail">Webmail</trn></a>
<li> <a href=im/><trn key="Instant_Messenger">Instant Messenger</trn></a>
</ul>

<ul> Your Content
<li> <a href=files/><trn key="Files">Files</trn></a>
<li> <a href=photos/><trn key="Photos">Photos</trn></a>
<li> <a href=presentations/><trn key="Presentations">Presentations</trn></a>
</ul>


<a href="/~@uid@/">Your public homepage & profile</a>

</td><td valign=top>

<table border=0 cellpadding=0 cellspacing=0 width="100%"><tr><td bgcolor="ccccff"  width="100%"><table border=0 cellpadding=4 cellspacing=0 width="100%"><tr><td><b><font face="Arial">Calculator</font></b></td></tr></table></td></tr></table>
<include src="../tmpl/calculator">


</td></tr></table>
