# derived_attribute id creates a table with the given attributes
# and a third one that is the application of the fn for the given
# attributes.
# {derived_attribute id --datatype sha1_hex --fn_args {reversedomain url} --fn sha1_hex --fn_alternative serial_int --pk }

namespace eval ::newsdb::news_item_t {

    namespace ensemble create -subcommands {get insert from_path to_path}

    variable ks "newsdb"
    variable cf "news_item"

    # pk is expected to have no spaces before and after the attribute name
    # i.e. the value is used as such (i.e. no trim) to figure out the main axis
    # in the ORM procs (insert, get, and so forth)

    variable metadata
    array set metadata [list ks $ks cf $cf]
    array set metadata {
        pk {urlsha1}
        comment_pk {
            creates the following index:
            {by_urlsha1 {urlsha1} "all"}
        }
        attributes {
            urlsha1
            contentsha1
            site
            date
            langclass

            url
            title
            body
            first_sync
            last_sync
            is_revision_p
            is_copy_p

            timestamp
            date
            sort_date

            domain
            reversedomain
        }
        indexes {
            {by_domain                   {reversedomain}            "summary"}
            {by_langclass                {langclass}                "summary"}
            {by_contentsha1              {contentsha1}              "summary"}
            {by_sort_date                {sort_date}                "summary"}
        }
        aggregates {
        }
    }

}

proc ::newsdb::news_item_t::to_path {id} {
    variable ks
    variable cf
    variable metadata

    set axis by_$metadata(pk)
    set target "${ks}/${cf}.${axis}"
    if {1} {
        # if datatype of primary key attribute exceeds a certain threshold
        # then we map the primary key attribute to row keys
        append target "/${id}/+/__data__"
    } else {
        # otherwise, map the primary key attribute to column names
        append target "/__data__/+/${id}"
    }
}

proc ::newsdb::news_item_t::from_path {path} {
    set column_key [lassign [split ${path} {/}] _ks _cf row_key __delimiter__]
    if {1} {
        return ${row_key}
    } else {
        return ${column_key}
    }
}


proc ::newsdb::news_item_t::get {id {dataVar ""}} {
    variable ks
    variable cf
    variable metadata

    set varname {}
    if { $dataVar ne {} } {

        upvar $dataVar _

        # get/get_column only gets the data 
        # (as opposed to just the filename)
        # if a non-empty dataVar argument is given 

        set varname {_}
    }

    set path [to_path ${id}]
    set filename [::persistence::get $path {*}${varname}]

    return $filename

}

proc ::newsdb::news_item_t::insert {itemVar} {

    variable ks
    variable cf
    variable metadata

    upvar $itemVar item

    set data [array get item]

    set pk $metadata(pk)
    set target [to_path $item($pk)]

    ::persistence::insert $target $data

    foreach index_item $metadata(indexes) {
        lassign $index_item axis attributes __tags__

        set row_key [list]
        foreach attname $attributes {
            lappend row_key $item($attname)
        }

        set src "${ks}/${cf}.${axis}/${row_key}/+/$item($pk)"
        ::persistence::insert_link $src $target

     }

}



# by_const_and_date
# by_urlsha1_and_const
# by_urlsha1_and_contentsha1
# by_langclass
foreach {ks spec} {

    web_cache_db {
        web_page {
            by_domain
        }
    }

    newsdb {
        news_item {
            by_urlsha1
            by_domain
            by_langclass
            by_contentsha1
            by_sort_date
        }

        content_item {
            by_contentsha1_and_const
        }

        error_item {
            by_urlsha1_and_timestamp
        }

        index {
            contentsha1_to_label
            contentsha1_to_urlsha1
            urlsha1_to_date_sk
        }

        classifier {
            model
        }

        train_item {
            default
        }
    }

    crawldb {
        sync_info {
            by_urlsha1_and_const
        }
        round_stats {
            by_timestamp_and_const
        }
        feed_stats {
            by_feed_and_const
            by_feed_and_period
        }
    }

} {

    ::persistence::define_ks $ks

    foreach {column_family axis_list} ${spec} {
        foreach axis $axis_list {
            ::persistence::define_cf $ks ${column_family}.${axis}
        }
    }
}

#    train_item/el
#    train_item/el/edition
#    train_item/el/topic
#    train_item/el/priority
#    train_item/el/type

