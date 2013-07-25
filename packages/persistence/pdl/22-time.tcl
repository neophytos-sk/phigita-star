DB_Class Timezone -lmap mk_attribute {
    {String country_code -maxlen 2 -isNullable no}
    {String tz -isNullable no}
    {String coordinates -isNullable no}
} -lmap mk_index {
    {Index tz -isUnique yes}
    {Index country_code}
}