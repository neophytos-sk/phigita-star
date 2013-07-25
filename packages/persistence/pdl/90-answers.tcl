# kind = 0 - open question
# kind = 1 - poll 
# => attributes in extra: 
#    * required_p (default: true)
#    * presentation_type (default: 0)
#      - 0 Multiple Choice (Radio Buttons, single answer allowed)
#      - 1 Multiple Choice (Drop Down, single answer allowed)
#      - 2 Multiple Choice (Checkbox, multiple answers allowed)
#      - 3 Essay Answer (TextArea)
#      - 4 One Line Answer (Text Field)
#      - 5 Date
#      - 6 File Attachment
# kind = 2 - survey (many poll questions)

DB_Class ::Question -lmap mk_attribute {
    {OID id}
    {String subject -maxlen "255"}
    {String body}
    {Timestamptz creation_date}
    {Integer creation_user}
    {String creation_ip -maxlen "255"}
    {Boolean anonymous_p}
    {Integer cnt_answers -isNullable no -default 0}
    {Timestamptz last_answer -isNullable yes}
    {Integer last_answer_user_id -isNullable yes}

    {Integer kind -isNullable no -default 0}
    {Boolean public_p -isNullable no -default 't'}

    {TclDict extra -isNullable yes}

} -lmap mk_index {
    {Index kind}
}

DB_Class Answer -lmap mk_attribute {
 
    {OID id}
    {Integer parent_id}
    {String body}
    {Timestamptz creation_date}
    {Integer creation_user}
    {String creation_ip -maxlen 255}
 
} -lmap mk_index {
 
    {Index parent_id}
 
} -lmap mk_aggregator {

    { Aggregator=Ad-hoc answers_agg1 -targetClass ::Question \
	  -preserve_pathexp_p yes \
          -maps_to {
              pathexp
	      {creation_user last_answer_user_id}
              {parent_id id}
          } -proc onInsertSync {o1} {

              my instvar targetClass
              set o2 [my getImageOf ${o1}]

              set sql [subst {
                  UPDATE [${o2} info.db.table] set
                      cnt_answers = cnt_answers + 1
                     ,last_answer=CURRENT_TIMESTAMP
		     ,last_answer_user_id=[${o2} quoted last_answer_user_id]
                  WHERE
		     id=[${o2} quoted id]
              }]
              set pool [${o2} info.db.pool]
              set conn [DB_Connection new -pool ${pool}]
              ns_log notice ${sql}
              ${conn} do ${sql}

          } -proc onDeleteSync {o1} {

              set o3 [::Answer new \
                          -mixin ::db::Object \
                          -pathexp [${o1} set pathexp]]

              set o2 [my getImageOf ${o1}]
              set sql [subst {
                  UPDATE [${o2} info.db.table] set
		  cnt_answers = cnt_answers - 1
                  ,last_comment=(select max(creation_date) from [${o3} info.db.table] where parent_id=[${o1} quoted parent_id])
                  WHERE
				 id=[${o2} quoted id]
			     }]
		       set pool [${o2} info.db.pool]
		       set conn [DB_Connection new -pool ${pool}]
		       ns_log notice ${sql}
		       ${conn} do ${sql}
		   } -proc onUpdateSync {o1} {
              # do nothing
		   }}}



# Poll
# Poll_Choice
# Poll_Answer

# cnt_participants
# an integer array for aggregating the count per choice
DB_Class Poll -lmap mk_attribute {
    {RelKey id -ref ::Question -refkey id}
    {String subject -maxlen "255"}
    {String body -isNullable yes}
    {Boolean anonymous_p -isNullable no -default 't'}
    {Integer presentation_type -isNullable no -default 0}
    {String choices}
} -lmap mk_like {
    ::auditing::Auditing
}

DB_Class Poll_Choice -lmap mk_attribute {
    {RelKey parent_id -ref ::Question -refkey id}
    {String label -isNullable no}
    {Integer sort_order -isNullable no}
} -lmap mk_like {
    ::content::Object
    ::auditing::Auditing
}

DB_Class Poll_Answer -lmap mk_attribute {

    {RelKey parent_id -ref ::Poll -refkey id}
    {String body -isNullable yes}

    {Integer choice -isNullable yes}
    {Boolean private_p -isNullable no -default 't'}
    {Boolean live_p -isNullable no -default 't'}

} -lmap mk_like {
    ::content::Object
    ::auditing::Auditing 
} -lmap mk_index {
 
    {Index parent_id}
    {Index private_p}
    {Index live_p}
}

DB_Class Poll_User_Answer -lmap mk_attribute {

    {RelKey question_id -ref ::Poll -refkey id}
    {String question_subject -maxlen "255"}
    {String question_body -isNullable yes}
    {TclDict question_extra -isNullable no}
    {String answer_body -isNullable yes}
    {Integer answer_choice -isNullable no}
    {Boolean answer_private_p -isNullable no -default 't'}
    {Boolean live_p -isNullable no -default 't'}

} -lmap mk_like {
    ::content::Object
    ::auditing::Auditing
} -lmap mk_index {
    {Index question_id}
    {Index live_p}
}