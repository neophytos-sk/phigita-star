#source [acs_root_dir]/www/test-bookshelf-123/amazon-procs.tcl
set isbn  0875848893
::amazon::get_book_info -array info $isbn
set image_url [::amazon::get_image_url $isbn]
doc_return 200 text/html [subst {
    <ul>
    <li>Author: $info(book_author) 
    <li>Title: $info(book_title)
    <li>Image: <img src="$image_url" />
    </ul>
}]