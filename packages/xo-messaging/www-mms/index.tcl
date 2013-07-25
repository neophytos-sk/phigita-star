set filename [acs_root_dir]/tmp/neo-mms.raw
set fp [open $filename w]
fconfigure $fp -translation binary
ns_conncptofp $fp
close $fp

set fp [open $filename]
fconfigure $fp -translation binary
set data [read $fp]
close $fp

source [acs_root_dir]/packages/xo-messaging/tcl/mms-procs.tcl
set o [::messaging::mms::RequestHandler new -data $data]
ns_write "HTTP/1.0 200 OK\r\nContent-Type: application/vnd.wap.mms-message\r\n\r\n"
ns_write [$o confirm]

