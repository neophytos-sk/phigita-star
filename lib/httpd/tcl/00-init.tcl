config section ::httpd

config param host [info hostname]
config param port 8080
config param homedir [file normalize [file join [file dirname [info script]] ../www]]
config param default_page index.html

