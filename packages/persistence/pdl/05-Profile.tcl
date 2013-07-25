if {0} {
    DB_Class Basic_Info -lmap mk_attribute {
	{RelKey user_id -ref User -refkey id}
	{String about_me}
	{ValueList gender -values {f m} -labels {"Female" "Male"}}
	{ValueList tshirt_size -values {s m l xl 2xl} -labels {"Small" "Medium" "Large" "X-Large" "2X-Large"}}
	{String city}
	{String country_code -length 2}
	{String phone_number}
    } -lmap mk_index {
	{Index user_id}
    }
}
