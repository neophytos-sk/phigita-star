accounts::trusted_member_check


ad_page_contract {
    @author Neophytos Demetriou
} {
    first_name:trim,notnull
    last_name:trim,notnull
    email:trim,email,notnull
    msg:trim,notnull
}

set user_id [ad_conn user_id]

#if { [db_0or1row check_exists_p "select 1 from xo__friend_invite_tokens where email=:email and creation_user=:user_id"] } {
#    throw REDIRECT friend-invite-done
#}

set inv_id [db_string get_invitation_id "select nextval('xo__friend_invite_id__seq');"]


set full_name [db_string get_full_name "select first_names || ' ' || last_name from cc_users where user_id=:user_id"]


set time [ns_time]

set token [ns_sha1 INVITE-${email}-${time}]

set peeraddr [ns_conn peeraddr]
set user_id [ad_conn user_id]


set notification_address [ad_parameter NewRegistrationEmailAddress "security" [ad_system_owner]]


set link [ad_parameter -package_id [ad_acs_kernel_id] SystemURL]/accounts/a-${inv_id}-${token}\n\n



if { [regexp -- {(cytanet\.com\.cy)|(cyta\.com\.cy)|(spidernet\.net)|(gmail\.com)|(hotmail\.com)|(forthnet\.gr)|(hol\.gr)|(otenet\.gr)$} ${email}] } {
    set greek_mail_provider 1 
} else {
    set greek_mail_provider 0
}

##############################################################

set invitation_text {
%s has invited you to open a free phigita.net account. The invitation
will expire in two weeks and can only be used to set up one account.

To accept this invitation and register for your account, visit

  %s

If you haven't already heard about phigita.net, it's a new online community of greek internet users that helps you:

- Publish to the web instantly.

- Get answers to your questions.

- Chat with friends on the web.

- Contribute comments to your friends' postings.

- Access your bookmarks from any computer.

phigita.net is still in an early stage of development. But If you set up an
account, you'll be able to keep it even after we make phigita.net more
widely available. We might also ask for your comments and suggestions
periodically and we appreciate your help in making phigita.net even better.

Thanks,

The phigita.net Team

To learn more about phigita.net before registering, visit:
http://www.phigita.net/

(If clicking the URLs in this message does not work, copy and paste them
 into the address bar of your browser).}

set invitation_text ${msg}\n\n~-~-~-~-~-~-~\n\n[_ invitation_text ${invitation_text} el_GR]
set invitation_text [format ${invitation_text} ${full_name} ${link}]

#########################################################


  db_dml do_insert "insert into xo__friend_invite_tokens(
    invite_id,
    first_name,
    last_name,
    email,
    token,
    creation_user,
    creation_ip
  ) values (
    :inv_id,
    :first_name,
    :last_name,
    :email,
    :token,
    :user_id,
    :peeraddr
  );"


set message_subject [format [_ invitation_subject "%s, %s has invited you to open a phigita.net account" el_GR] ${first_name} ${full_name}] 
set message_body ${invitation_text}

if { !${greek_mail_provider} } {
    set message_subject [greek_to_greeklish ${message_subject}]
    set message_body "\[To minima apostalei se greeklish anti ellhnika gia na vevaiouthoume oti tha einai anagnosimo.\]\n\n[greek_to_greeklish ${message_body}]"
}

if { [regexp -- {hotmail\.com$} ${email}] } {
    set message_subject [greek_to_greeklish ${message_subject}]
}


    acs_mail_lite::send \
    -to_addr $email \
    -from_addr $notification_address \
    -bcc $notification_address \
    -subject ${message_subject} \
    -body ${message_body}

throw REDIRECT friend-invite-done
