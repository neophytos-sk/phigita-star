namespace eval ::calendar {;}

DB_Class ::calendar::Folder -lmap mk_attribute {

    {String folder_name -isNullable no}
    {Integer tz_id -isNullable no}

    {HStore extra -isNullable yes}

} -lmap mk_like {

    ::content::Object
    ::auditing::Auditing

}

DB_Class ::calendar::Event -lmap mk_attribute {

    {String event_name -isNullable no}

    {Timestamp event_start_dt -isNullable no -default null}
    {Timestamp event_end_dt -isNullable yes -default null}
    {Boolean all_day_event_p -isNullable no -default 'f'}
    {Boolean recurring_p -isNullable no -default 'f'}

    {String event_location}
    {String event_description -isNullable yes}

    {HStore extra -isNullable yes}
    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}

    {Integer folder_id -isNullable yes}

} -lmap mk_like {

    ::content::Object
    ::auditing::Auditing

} -lmap mk_index {

    {Index ts_vector}
    {Index folder_id}
    {Index event_start_end_dt -subject "event_start_dt event_end_dt"}

}


DB_Class ::calendar::Task -lmap mk_attribute {

    {String task_title -isNullable no}

    {Timestamp task_due_dt -isNullable yes -default null}
    {Boolean has_due_dt_p -isNullable no -default 'f'}
    {Boolean any_time_task_p -isNullable no -default 'f'}
    {Boolean done_p -isNullable no -default 'f'}

    {String task_description -isNullable yes}

    {HStore extra -isNullable yes}
    {TSearch2_Vector ts_vector -isNullable no -default ''::tsvector}

    {Integer folder_id -isNullable yes}

} -lmap mk_like {

    ::content::Object
    ::auditing::Auditing

} -lmap mk_index {

    {Index ts_vector}
    {Index folder_id}
    {Index task_due_dt}
    {Index done_p}

}