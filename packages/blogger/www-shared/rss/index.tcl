require_html_procs

ad_page_contract {
    @author Neophytos Demetriou
} {
    ctx_uid
}

db_1row get_user_info "select first_names || ' ' || last_name as full_name,screen_name,user_id from cc_users where user_id=:ctx_uid"


set itemlist [Blog_Item retrieve \
		  -pathexp [list User ${ctx_uid}] \
		  -output "id, title, substr(body,0,255) as description, EXTRACT(EPOCH FROM date_trunc('second',entry_date)) as pubdate" \
		  -criteria "shared_p = 't'" \
		  -limit 10 \
		  -order "entry_date desc"]

namespace eval rss {
    dom createNodeCmd element channel
    dom createNodeCmd element item
    dom createNodeCmd element title
    dom createNodeCmd element link
    dom createNodeCmd element language
    dom createNodeCmd element docs
    dom createNodeCmd element description
    dom createNodeCmd element copyright
    dom createNodeCmd element pubDate
    dom createNodeCmd element webMaster
    dom createNodeCmd element guid
    dom createNodeCmd element image
    dom createNodeCmd element width
    dom createNodeCmd element height
    dom createNodeCmd element url
    dom createNodeCmd element description
}



set blog_url [ad_url]/~[::util::coalesce ${screen_name} ${user_id}]/blog/
dom createDocument rss docId
set root [${docId} documentElement]
${root} setAttribute version "2.0"
set stylepi [${docId} createProcessingInstruction "xml-stylesheet" "type=\"text/css\" href=\"http://www.phigita.net/css/rss.css\""]
set xpathRoot [${root} selectNode /]
${xpathRoot} insertBefore ${stylepi} ${root}
${root} appendFromScript {
    rss::channel {
	rss::title { 
	    t "${full_name} (~[::util::coalesce ${screen_name} ${user_id}]) > Blog"
	}
	rss::description { t "" }
	rss::link { 
	    t ${blog_url}
	}
	rss::language {
	    t el
	}
	rss::docs { t "This file is an RSS 2.0 file. It is intended to be viewed in a Newsreader or syndicated to another site." }
	foreach item ${itemlist} {
	    set item_url ${blog_url}[${item} set id]
	    rss::item {
		rss::title {
		    t [${item} set title]
		}
		rss::link {
		    t ${item_url}
		}
		rss::description {
		    set description [${item} set description]
		    set description [string map {\r { } \n { } :: {} * {} _ {} -- {}} ${description}]
		    set description [string range ${description} 0 [expr [string wordstart ${description} end] - 1]]
		    set description "[regsub -all -- {\s+} ${description} { }]\[...\]"
		    t ${description}
		}
		rss::pubDate {
		    t "[clock format [${item} set pubdate] -format "%a, %d %b %Y %H:%M:%S"] GMT"
		}
		rss::guid -isPermaLink true {
		    t ${item_url}
		}
	    }
	}
    }
}

doc_return 200 text/xml "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n[${docId} asXML]"