namespace eval ::auditing {;}

DB_Class ::auditing::Creation -lmap mk_attribute {
    {Integer   creation_user}
    {String    creation_ip -maxlen 255}
    {Timestamptz creation_date}
} -lmap mk_index {
    {Index     creation_date -on_copy_include_p yes}
}

DB_Class ::auditing::Update -lmap mk_attribute {
    {Integer   modifying_user}
    {String    modifying_ip -maxlen 255}
    {Timestamptz last_update}
} -lmap mk_index {
    {Index     last_update -on_copy_include_p yes}
}

DB_Class ::auditing::Auditing -lmap mk_like {
    ::auditing::Creation
    ::auditing::Update
}

