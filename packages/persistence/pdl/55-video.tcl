DB_Class Video -lmap mk_attribute {

    {String url -isNullable no}
    {String provider -isNullable no}

    {String thumbnail_url}
    {String thumbnail_sha1 -isNullable no}
    {Integer thumbnail_width}
    {Integer thumbnail_height}


    {String title -isNullable no}
    {String description -isNullable yes}

    {String ref_video_id -isNullable no}
    {String provider -isNullable no}

    {Integer duration -isNullable no -default 0}
    {String tags -isNullable yes}

    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}

    {String extra -isNullable yes}
    {Boolean redirect_p -isNullable no -default 'f'}

    {Integer cnt_references -default 1}
    {Timestamptz creation_date}
    {Timestamptz last_update}

} -lmap mk_index {

    {Index     creation_date -on_copy_include_p yes}
    {Index     last_update -on_copy_include_p yes}
    {Index     cnt_references -on_copy_include_p yes}
    {Index     ref_video_id -on_copy_include_p yes -isUnique yes}

} 