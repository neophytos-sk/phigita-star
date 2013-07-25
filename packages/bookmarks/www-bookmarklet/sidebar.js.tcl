#set signed_user_id [::xo::session::signed_value "_T" [ad_conn user_id]]
#set js "var _T=[::util::jsquotevalue ${signed_user_id}];"

#append js {}
#set key BOOKMARKS.WWW-BOOKMARKLET.SIDEBAR
#set compiled_js [::xo::js::get_compiled ${key} ${js}]

append js [::xo::js::include_compiled BOOKMARKS.LIB.SIDEBAR-LOAD {
    kernel/lib/base.js
    kernel/lib/event.js
    kernel/lib/JSON.js
    bookmarks/lib/sidebar-load.js
}]

doc_return 200 text/javascript ${js}