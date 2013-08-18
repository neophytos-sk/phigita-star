### BOOKS

set image_host [get_cdn_url "/cover/"]

val -id book_offset -cache_timeout "1800" {expr {int(4000*rand())}}

datastore \
    -id bookdata \
    -cache "RANDOM_BOOK" \
    -cache_timeout "1800" \
    -pool bookdb \
    -singleton true \
    -select {
	ean13 
	image_p 
	title 
	authorlist
	author
	categories
	year 
	pages
	{'http://books.phigita.net/isbn/' || ean13 AS url}
    } \
    -from_class "::Book" \
    -where [list "image_p"] \
    -order "ean13" \
    -offset @{book_offset} \
    -limit 1 \
    -extend {
	set authorlist [::util::coalesce $authorlist [list $author]]
	set subject [string trim [lindex [split [lindex $categories 0] {|}] 0]]
	set subject_for_url [string map {{ } {_}} $subject]
    }




css {
    #book a {text-decoration:none;}
    #book .title {font-weight:bold;color:#468;}
    #book a:hover {text-decoration:underline;}
    #book .subject {font-size:small;color:#864;font-weight:bold;}
    .book_details {font-size:x-small;color:#888;}
    .cover {float:left; margin:10px 5px;}
}

p

div -id book {
    div -style "border:1px solid rgb(215,215,165);overflow:hidden;padding:5px 5px 10px;" {
	div -style "padding:3px;color:#8B814C;font-size:14px;font-weight:bold;" {
	    t "Random Book" 
	}
	div -style "padding:3px;" {
	    t "Weigh and Consider."
	}

	dataview {
	    tpl -with "bookdata" {
		div -class "cover" {
		    a -href "@{url}" {
			img -class "cover" -src "${image_host}s@{ean13}-x80.jpg" -height "80"
		    }
		}
		div -id "book" {
		    a -class "subject" -href "http://books.phigita.net/subject/@{subject_for_url}" {
			t @{subject}
		    }
		    br
		    a -class "title" -href "@{url}" { t @{title} }
		    tpl -if "@{authorlist} ne {}" {
			tpl -for "authorlist" {
			    br
			    span -class "author" {
				t @{_}
			    }
			}
		    }
		    tpl -if "@{year} ne {}" {
			br
			span { t @{year} }
		    }
		    tpl -if "@{pages} ne {}" {
			span {
			    t " - @{pages} pages"
			}
		    }
		}
	    }
	}
	i -class clearfix
	a -class "btn btn-link btn-mini" -href "http://books.phigita.net/" { t "More Books" }

    }
}
