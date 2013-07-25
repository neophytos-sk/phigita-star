#source [acs_root_dir]/packages/kernel/tcl/xo/fun/functional-procs.tcl

package require TclCurl

Object ::Ttext

::Ttext proc tidy {
		   {-input_xml_p 0}
		   {-output_xml_p 0}
		   {-output_xhtml_p 0}
		   {-input_encoding utf8}
		   {-output_encoding utf8}
		   {-tcl_output_encoding utf-8}
		   s
} {
    
    return [::htmltidy::tidy \
		--force-output y \
		--show-warnings n \
		--show-errors 0 \
		--input-xml ${input_xml_p} \
		--output-xml ${output_xml_p} \
		--output-xhtml ${output_xhtml_p} \
		--quiet y \
		--tidy-mark 0 \
		--wrap 0 \
		--indent no \
		--escape-cdata y \
		--input-encoding ${input_encoding} \
		--output-encoding ${output_encoding} \
		--ascii-chars n \
		--ncr y \
		--hide-comments y \
		--assume-xml-procins y \
		--numeric-entities y \
		--drop-empty-paras 0 \
		--fix-bad-comments y \
		--fix-uri n \
		[encoding convertfrom ${tcl_output_encoding} ${s}]]
}




proc dump-html {node} {
	set result ""
	set nodeType [$node nodeType]
	switch -- $nodeType {
		TEXT_NODE -
		CDATA_SECTION_NODE -
		COMMENT_NODE -
		PROCESSING_INSTRUCTION_NODE {
			set result [$node toXPath]=>[$node nodeValue]
		}
		DOCUMENT_NODE -
		ELEMENT_NODE {
			set extra ""
			if { $nodeType eq {ELEMENT_NODE} } {
			    set extra [$node toXPath]
			}
			foreach child [$node childNodes] {
				lappend result ${extra}=>[dump-html $child]
			}
			set result [join $result \n\n]
		}
	}

	return $result
}

proc parse-html {xpath_list node} {
    set result ""
    foreach {varName xpath} $xpath_list {
	lappend result [list $varName [string trim [$node selectNodes $xpath]]]
    }
    return [join $result]
}




proc get_biblionet_book {book_id cookieVar} { 

    upvar $cookieVar cookie

    ### Get Cookie 

    set urlHandle [curl::init]

    global __books__counter
    incr __books__counter

    if { $cookie eq {} || ($__books__counter % 100) == 0 } {
	set url http://www.biblionet.gr/frameu.asp 
	$urlHandle configure -url $url -headervar header -bodyvar body
	while { [catch "$urlHandle perform" errmsg] } {
	    ns_log notice "url=$url errmsg=$errmsg"
	    after 3000
	}
	set cookie $header(Set-Cookie)
    }


    
    #source [acs_root_dir]/packages/kernel/tcl/xo/30-xo-comm-procs.tcl
    #set o [::xo::comm::CurlHandle new -url ${url}]
    #$o perform
    #set cookie [$o get_header Set-Cookie]
    #doc_return 200 text/plain $cookie

    ### Get Instance of Page-Type-1

    set url2 http://www.biblionet.gr/srh/showbook.asp?bookid=${book_id}
    $urlHandle configure -url $url2 -cookie $cookie -headervar header2 -bodyvar body2
    while { [catch "$urlHandle perform" errmsg] } {
	ns_log notice "url2=$url2 errmsg=$errmsg"
	after 3000
    }

    set body2 [::Ttext tidy $body2]

    set xpath_list {
	title          returnstring(/html/body/table/tbody/tr[2]/td[2]/font/text())
	author         returnstring(/html/body/table/tbody/tr[2]/td[2]/text())
	publisher      returnstring(/html/body/table/tbody/tr[3]/td[2]/b/font/text()[1])
	year           returnstring(/html/body/table/tbody/tr[3]/td[2]/b/font/text()[2])
	pages          returnstring(/html/body/table/tbody/tr[3]/td[2]/b/font/text()[3])
	isbn10         returnstring(/html/body/table/tbody/tr[3]/td[2]/b/font/text()[4])
	isbn13         returnstring(/html/body/table/tbody/tr[3]/td[2]/b/font/text()[5])
	price          returnstring(/html/body/table/tbody/tr[3]/td[2]/b/font/nobr/text())
	category_1     returnstring(/html/body/table/tbody/tr[4]/td[2]/div[1]/font/a/text())
	description    returnstring(/html/body/table/tbody/tr[5]/td[2]/div/p)
	image_url      values(/html/body/table/tbody/tr[2]/td[3]/img[starts-with(@src,'/images/covers/')]/@src)
    }

    set docid [dom parse -html $body2]
    array set book [parse-html $xpath_list $docid]
    if { ![string match $book(isbn13) "*ISBN-13*"] } {
	set book(isbn13) $book(isbn10)
    }

    #$docid normalize -forXPath
    #$docid selectNodesNamespaces {"" "http://www.w3.org/1999/xhtml"}

    #doc_return 200 text/plain [$docid asHTML]
    #doc_return 200 text/plain [dump-html $docid]
    #doc_return 200 text/plain [parse-html $xpath_list $docid]
    #return




    ### Get Instance of Page-Type-2

    set format_str_3 http://www.biblionet.gr/srh/search.asp?title=&titlesKind=&person=&PerKind=0&Com=&ComText=&from=&untill=&subject=&series=&low=&high=&PagesFrom=&PagesTo=&avail_stat=&srhMethod=22&fuzzy=off&submit1=%CE%91%CE%BD%CE%B1%CE%B6%CE%AE%CF%84%CE%B7%CF%83%CE%B7&isbn=

    set url3 ${format_str_3}[lindex [split $book(isbn10)] 1]

    $urlHandle configure -url $url3 -cookie $cookie -headervar header -bodyvar body3
    while { [catch "$urlHandle perform" errmsg] } {
	ns_log notice "url3=$url3 errmsg=$errmsg"
	after 3000
    }

    set body3 [::Ttext tidy $body3]
    set docid3 [dom parse -html $body3]

    set xpath_list_2 {
	title                 returnstring(/html/body/table[2]/tr/td[2]/p/a[1]/text())
	author                returnstring(/html/body/table[2]/tr/td[2]/p/b/text())
	authorlist            values(/html/body/table[2]/tr/td[2]/p/a[starts-with(@href,'showauthor')]/text())
	authorlist_href       values(/html/body/table[2]/tr/td[2]/p/a[starts-with(@href,'showauthor')]/@href)
	publisher             returnstring(/html/body/table[2]/tr/td[2]/p/a[starts-with(@href,'showcom.asp?comid=')]/text())
	zzz_1                 values(/html/body/table[2]/tr/td[2]/p/i/text())
	price_text            returnstring(/html/body/table[2]/tr/td[2]/p/nobr/text())
	categories            values(/html/body/table[2]/tr/td[2]/p/a[starts-with(@href,'/tc/index.asp')]/text())
	categories_href       values(/html/body/table[2]/tr/td[2]/p/a[starts-with(@href,'/tc/index.asp')]/@href)
	zzz_2                 values(/html/body/table[2]/tr/td[2]/p/text())
    }

    $urlHandle cleanup

    set cover_image_path /web/data/books/cover/
    if { $book(image_url) ne {} } {
	set cover_image_url http://www.biblionet.gr$book(image_url)
	set ean13 [string map {- {}} [lindex [split [string trim $book(isbn13)]] 1]]
	set image_file ${cover_image_path}/b${ean13}.jpg
	if { ![file exists ${image_file}] } {
	    ns_log notice "image_url=$cover_image_url image_file=$image_file" 
	    if { [catch "curl::transfer -url $cover_image_url -file ${image_file}" errmsg] } {
		ns_log notice "get_biblionet_book: errmsg=$errmsg"
	    }
	}
	set image_p t
    } else {
	set image_p f
    }

    array set book_details_2 [parse-html $xpath_list_2 $docid3]

    set line ""
    lappend line [::util::doublequote ${book_id}]
    lappend line [::util::doublequote ${image_p}]

    set book_details_2(authorlist_href) [string map {{showauthor.asp?personsid=} {}} $book_details_2(authorlist_href)]
    set book_details_2(categories_href) [string map {{/tc/index.asp?subid=} {}} $book_details_2(categories_href)]

    lappend line [::util::doublequote [linterleave $book_details_2(authorlist_href) $book_details_2(authorlist)]]
    lappend line [::util::doublequote [linterleave $book_details_2(categories_href) $book_details_2(categories)]]
    unset book_details_2(authorlist)
    unset book_details_2(authorlist_href)
    unset book_details_2(categories)
    unset book_details_2(categories_href)
    unset book(image_url)

    foreach key [lsort [array names book]] {
	lappend line [::util::doublequote $book(${key})]
    }
    foreach key [lsort [array names book_details_2]] {
	lappend line [::util::doublequote ${key}=[string trim $book_details_2(${key})]]
    }


    return [join ${line} {,}]
}


proc get_all_biblionet_books {m n} {
    set cookie ""
    ns_log notice "get_all_biblionet_books m=$m n=$n"
    set fp [open [web_root_dir]/data/backup/biblionet.txt-${m}-${n} w]
    set result ""
    for { set i $n } { $i >= $m } { incr i -1 } {
	if { $i % 100 == 0 } { ns_log notice "get_all_books i=$i" }
	#lappend result [get_biblionet_book $i]
	puts $fp [get_biblionet_book $i cookie]
    }
    close $fp
    ns_log notice "get_all_biblionet_books end"
    return [join $result \n]
}



### 110452
### 129893



#ns_schedule_proc -once 0 get_all_biblionet_books 129893 50000
#doc_return 200 text/plain ok

#doc_return 200 text/plain [get_all_biblionet_books 110495 110505]
# set book_id 105146
#set book_id 110453

#set book_id 126190
#doc_return 200 text/plain [get_biblionet_book $book_id]

# doc_return 200 text/plain [dump-html $docid3]
# doc_return 200 text/html "<img src=http://books.phigita.net/cover/b${ean13}><pre><code>[join [array get book_details_2] <br>]</code></pre>"
# doc_return 200 text/plain [[$docid documentElement] selectNodes {namespace::*[name()='']}]

