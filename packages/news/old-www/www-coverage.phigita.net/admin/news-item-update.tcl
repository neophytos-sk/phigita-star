ad_page_contract {
    @author Neophytos Demetriou
} {
    url_sha1:trim,notnull
    {train_topic_p:trim,notnull f}
    {train_edition_p:trim,notnull f}
    {permanent_train_p:trim,notnull f}
    classification__tree_sk:trim,notnull
    classification__edition_sk:trim,notnull
    {return_url:trim ".."}
}


set o [::sw::agg::Url new -mixin ::db::Object -pool newsdb -classification__tree_sk $classification__tree_sk -classification__edition_sk $classification__edition_sk -train_topic_p [expr { $train_topic_p ? t : f }] -train_edition_p [expr { $train_edition_p ? t : f }] -permanent_train_p  [expr { $permanent_train_p ? t : f }]]

${o} do self-update "url_sha1=[ns_dbquotevalue ${url_sha1}]"

ad_returnredirect ${return_url}