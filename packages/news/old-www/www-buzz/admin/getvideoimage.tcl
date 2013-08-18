ad_page_contract {
    @author Neophytos Demetriou
} {
    ref_video_id:trim,notnull,multiple
}

set video_list ""
foreach id $ref_video_id {
    lappend video_list http://www.youtube.com/v/${ref_video_id}
}

set video_image_list [::util::map "::util::wgetFile news/images" [::util::map ::xo::buzz::getVideoImageURL $video_list]]

doc_return 200 text/plain $video_image_list

#xo::fun::map filename [::util::map ::xo::buzz::getVideoImageURL $video_list] {file delete -- /web/data/news/images/[ns_sha1 $filename];file delete -- /web/data/news/images/[ns_sha1 $filename]-sample-80x80.jpg}
#doc_return 200 text/plain [::util::map "::util::wgetFile news/images" [::util::map ::xo::buzz::getVideoImageURL $video_list]]