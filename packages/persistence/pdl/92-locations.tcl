DB_Class ::Location -prefix "public" -dbname "locations" -is_final_if_no_scope "1"

if {0}  {
    id          | bigint                | not null
    country     | character(2)          | not null
    region      | character(2)          | 
    city        | character varying(75) | 
    postal_code | character varying(15) | 
    latitude    | numeric(6,4)          | not null
    longitude   | numeric(7,4)          | 
    metro_code  | integer               | 
    area_code   | integer               | 
}
