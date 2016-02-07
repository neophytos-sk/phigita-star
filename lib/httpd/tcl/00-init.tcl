config section ::httpd

config param host [info hostname]
config param port 8080
config param homedir [file normalize [file join [file dirname [info script]] ../www]]
config param default_page index.html



global Httpd
global HttpdMimeType

array set Httpd {
    bufsize	32768
    sockblock	0
    handler,html Httpd_handle_static_page
    handler,tdp  Httpd_handle_dynamic_page
}


# convert the file suffix into a mime type
# add your own types as needed

array set HttpdMimeType {
    {}		text/plain
    .txt	text/plain
    .htm	text/html
    .html	text/html
    .gif	image/gif
    .jpg	image/jpeg
    .xbm	image/x-xbitmap
    .pdf    application/pdf
}

