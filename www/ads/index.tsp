tmpl::simple -title "Create your ad" {
    br
    t "Destination URL - The web address you want your ad to link to."
    br
    input -type text -name url -size 50
    br
    t "Title - You have 25 characters, including spaces, to capture's people's interest."
    br
    input -type text -name title -size 30 -maxlength 35
    br
    t "Body - In 135 characters or less, describe the benefits of your product or service."
    br
    textarea -rows 4 -cols 30
    br
    t "Image - Be sure it is related to the content of your ad."
    br
    input -type file -name image
}