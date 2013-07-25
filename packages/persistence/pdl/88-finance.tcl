namespace eval ::finance {;}

DB_Class ::finance::Category -lmap mk_like {
    ::content::Object
} -lmap mk_attribute {
    {String title}
    {FKey   parent_id -ref ::finance::Category -refkey id}
}


DB_Class ::finance::Stock_Quote -lmap mk_attribute {
    {String exchange}
    {String symbol -isNullable no}
    {RelKey category_id -ref ::finance::Category -refkey id}
} -lmap mk_like {
    ::content::Object
    ::auditing::Auditing
} -lmap mk_index {
    {Index exchange_symbol -subject "exchange symbol" -isUnique yes}
    {Index category_id}
}