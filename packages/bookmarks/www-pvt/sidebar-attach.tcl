#::xo::kit::vcheck t "notnull lsearch:{image}"
#::xo::kit::vcheck u "notnull url"

set mediaType [::xo::kit::queryget t]
set mediaUrl  [::uri::canonicalize [::xo::kit::queryget u]]

lassign [::xo::buzz::wgetImage $mediaUrl] ok_p thumbnail_sha1 thumbnail_width thumbnail_height

set jsMediaType [::util::jsquotevalue ${mediaType}]
set jsMediaUrl  [::util::jsquotevalue ${mediaUrl}]
set jsImgOk     [::util::boolean $ok_p]
set jsImgSha1   [::util::jsquotevalue ${thumbnail_sha1}]
set jsImgWidth  [::util::jsquotevalue ${thumbnail_width}]
set jsImgHeight [::util::jsquotevalue ${thumbnail_height}]

append html {<script>}
append html [subst -nocommands -nobackslashes {parent.frames['_b_iframe'].AM(${jsMediaType},${jsMediaUrl},${jsImgOk},${jsImgSha1},${jsImgWidth},${jsImgHeight});}]
append html {</script>}
ns_return 200 text/html ${html}
