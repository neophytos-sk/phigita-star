#::xo::kit::reload [acs_root_dir]/packages/kernel/tcl/20-xo/media/converter-procs.tcl

ad_maybe_redirect_for_registration

# Size of ns_set : 4

# key: cb value: uploadSuccessFn
# key: upload_file value: libdai-mooij10a.pdf
# key: upload_file.content-type value: application/force-download
# key: upload_file.tmpfile value: /tmp/filekk2ejv


set form [::xo::ns::getform]
set tmpfile [ns_set get $form upload_file.tmpfile]
set filename [ns_set get $form upload_file]
set user_id [ad_conn user_id]

lassign [::xo::media::save_user_file \
	     $user_id \
	     $tmpfile \
	     $filename] object_id filetype content_type o

set json [::util::map2json object_id $object_id filetype $filetype content_type $content_type title [$o set title]]
# xo::ns::printset $form
doc_return 200 text/html "<script>parent.echo.attach(${json});</script>"

