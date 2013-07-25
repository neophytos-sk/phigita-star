Class create ACS_Class -superclass Class -parameter {
  {abstract_p f} pretty_name pretty_plural table_name id_column 
  package_name name_method {type_extension_table ""} {dynamic_p f} tree_sortkey}

Class create ACS_Object 


ACS_Class forums_forum \
    -pretty_name "Forums Forum" -pretty_plural "Forums Forums" \
    -table_name "forums_forums" -id_column "forum_id" \
    -package_name "forums_forum" -name_method "forums_forum__name" \
    -tree_sortkey "0000000000111000"

ACS_Class person \
    -pretty_name "#acs-kernel.Person#" -pretty_plural "#acs-kernel.People#" \
    -table_name "persons" -id_column "person_id" \
    -package_name "person" -name_method "person__name" \
    -tree_sortkey "000000000000001100000000" \
    -attributes {
      Attribute person_id -type "integer not null" 
      Attribute first_names -type "character varying(100) not null" 
      Attribute last_name -type "character varying(100) not null" 
    }


