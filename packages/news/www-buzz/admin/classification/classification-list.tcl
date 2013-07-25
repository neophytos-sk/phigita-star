ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
}



set oTemp1 [db::Set new -pool newsdb -select * -from xo.xo__buzz_in_greek -where [list url=[ns_dbquotevalue ${url}]]]
$oTemp1 load

set data [[$oTemp1 head] set ts_vector]

doc_return 200 text/html [subst {
    Topic: [::bow::getClassTreeSk [::bow::getExpandedVector $data] 1821]
<p>
    Edition: [::bow::getClassTreeSk [::bow::getExpandedVector $data] 1822]
<p>
<pre>
--------------------------
[join [::bow::getClassificationList [::bow::getExpandedVector $data] 1821] "\n"]
</pre>
<pre>
--------------------------
[join [::bow::getClassificationList [::bow::getExpandedVector $data] 1822] "\n"]
</pre>

<p>
[::bow::getExpandedVector $data]
<p>
$data
}]