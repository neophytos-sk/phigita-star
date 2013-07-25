set setId [::xo::ns::headers]
doc_return 200 text/plain [::xo::ns::printset $setId]