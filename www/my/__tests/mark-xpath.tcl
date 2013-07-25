#source [acs_root_dir]/packages/kernel/tcl/03-functional/functional-procs.tcl


#ns_schedule_proc -once 0 get_all_biblionet_books 129893 50000
doc_return 200 text/plain ok

#doc_return 200 text/plain [get_all_biblionet_books 110495 110505]
# set book_id 105146
#set book_id 110453

set book_id 126190
doc_return 200 text/plain [get_biblionet_book $book_id]

# doc_return 200 text/plain [dump-html $docid3]
# doc_return 200 text/html "<img src=http://books.phigita.net/cover/b${ean13}><pre><code>[join [array get book_details_2] <br>]</code></pre>"
# doc_return 200 text/plain [[$docid documentElement] selectNodes {namespace::*[name()='']}]

