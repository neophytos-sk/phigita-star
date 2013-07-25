# /packages/calendar/tcl/calendar-community-core-procs.tcl

ad_library {

    added functions to community-core-procs

    @author Gary Jin (gjin@arsdigita.com)
    @creation-date Jan 10, 2001
    @cvs-id $Id: calendar-community-core-procs.tcl,v 1.1.1.1 2001/04/23 23:09:38 donb Exp $

}

ad_proc cc_group_to_name { group_id } {
    
    Returns the group name given a group_id
} {
    return [db_string group_name_select {
             select acs_group.name(:group_id)
             from   dual
    } -default ""]

}



ad_proc cc_is_party_group_p { party_id } {

    returns 't' if the given party_id is a group
    requires acs_object_util package
    should roll this into pl/sql

} {

    db_1row get_group_result {
	select    acs_object_util.get_object_type(:party_id)
	as        result
	from      dual
    }
    

    if {[string equal $result "group"]} {
	return 1
    } else {
	return 0
    }
}

ad_proc cc_is_party_user_p { party_id } {

    given and party_id, return 't' if it is a user
    requires acs_object_util package
    should roll this into pl/sql

} {
    
    db_1row get_group_result {
	select    acs_object_util.get_object_type(:party_id)
	as        result
	from      dual
    }

    if {[string equal $result "user"]} {
	return 1
    } else {
	return 0
    }

}



#-----------------------------------------------
# should probably move this proc into acs-procs 
# since it is pretty useful when you want to get a 

ad_proc cc_member_of_groups { member_id } {

    Given a party_id, this procs returns a ns_set of
    party_id and party_name that the given member_id is a member of.
    The party_id is the key and party_name is the value
    
} {
    
    # create the ns_set
    set set_id [ns_set new party_set]
    
    # would  have called acs_group.member_p procs
    # but its not implemented yet!!!
    # so we query group_member_index table with the given
    # member_id looking for the group_id
    
    set sql "
    select   group_id 
    from     group_member_index
    where    member_id = :member_id
    "
    
    db_foreach get_all_party_ids $sql {
	# construct the set

	ns_set put $set_id $group_id [cc_group_to_name $group_id]

    }

    return $set_id

}






