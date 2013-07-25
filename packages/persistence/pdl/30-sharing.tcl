
namespace eval ::sharing {;}
DB_Class ::sharing::Flag -lmap mk_attribute {
    {Boolean shared_p -isNullable no}
} -lmap mk_index {
    {Index shared_p -on_copy_include_p yes}
}
DB_Class ::sharing::Flag_with_Start_Date -lmap mk_attribute {
    {Timestamptz sharing_start_date -isNullable yes}
} -lmap mk_like {
    ::sharing::Flag
}
DB_Class ::sharing::Flag_with_Start_and_End_Date -lmap mk_attribute {
    {Timestamptz sharing_end_date -isNullable yes}
} -lmap mk_like {
    ::sharing::Flag_with_Start_Date
}
