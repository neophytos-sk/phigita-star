
# Declare Tcl commands for building HTML elements. This is an complete 
# set taken from W3C on http://www.w3.org/TR/html4/index/elements.html
#

    #
    # Miscelaneous commands. Not part of html specs
    # but needed for generation of special dom nodes.
    #

    dom createNodeCmd cdataNode   cd
    dom createNodeCmd textNode    t
    dom createNodeCmd commentNode c
    dom createNodeCmd parserNode  x
    dom createNodeCmd piNode      runtime

    #
    # Command generating HTML tags. All these commands have
    # following sytax: <cmd> ?-option value ...? ?script?
    #
    #    -option   name of HTML attribute
    #     value    attribute value
    #     script   tcl script to run in command's context.
    #
    # Example: table -border 1 {...}
    #

    dom createNodeCmd elementNode a
    dom createNodeCmd elementNode abbr
    dom createNodeCmd elementNode acronym
    dom createNodeCmd elementNode address
    dom createNodeCmd elementNode applet
    dom createNodeCmd elementNode area
    dom createNodeCmd elementNode b
    dom createNodeCmd elementNode base
    dom createNodeCmd elementNode basefont
    dom createNodeCmd elementNode bdo
    dom createNodeCmd elementNode big
    dom createNodeCmd elementNode blockquote
    dom createNodeCmd elementNode body
    dom createNodeCmd elementNode br
    dom createNodeCmd elementNode button
    dom createNodeCmd elementNode caption
    dom createNodeCmd elementNode center
    dom createNodeCmd elementNode cite
    dom createNodeCmd elementNode code
    dom createNodeCmd elementNode col
    dom createNodeCmd elementNode colgroup
    dom createNodeCmd elementNode dd
    dom createNodeCmd elementNode del
    dom createNodeCmd elementNode dfn
    dom createNodeCmd elementNode dir
    dom createNodeCmd elementNode div
    dom createNodeCmd elementNode dl
    dom createNodeCmd elementNode dt
    dom createNodeCmd elementNode em
    dom createNodeCmd elementNode fieldset
    dom createNodeCmd elementNode font
    dom createNodeCmd elementNode form
    dom createNodeCmd elementNode frame
    dom createNodeCmd elementNode frameset
    dom createNodeCmd elementNode h1
    dom createNodeCmd elementNode h2 
    dom createNodeCmd elementNode h3 
    dom createNodeCmd elementNode h4 
    dom createNodeCmd elementNode h5 
    dom createNodeCmd elementNode h6
    dom createNodeCmd elementNode head
    dom createNodeCmd elementNode hr
    dom createNodeCmd elementNode html
    dom createNodeCmd elementNode i
    dom createNodeCmd elementNode iframe
    dom createNodeCmd elementNode img
    dom createNodeCmd elementNode input
    dom createNodeCmd elementNode ins
    dom createNodeCmd elementNode isindex
    dom createNodeCmd elementNode kbd
    dom createNodeCmd elementNode label
    dom createNodeCmd elementNode legend
    dom createNodeCmd elementNode li
    dom createNodeCmd elementNode link
    dom createNodeCmd elementNode map
    dom createNodeCmd elementNode menu
    dom createNodeCmd elementNode meta 
    dom createNodeCmd elementNode noframes
    dom createNodeCmd elementNode noscript
    dom createNodeCmd elementNode object 
    dom createNodeCmd elementNode ol
    dom createNodeCmd elementNode optgroup
    dom createNodeCmd elementNode option
    dom createNodeCmd elementNode p
    dom createNodeCmd elementNode param
    dom createNodeCmd elementNode pre
    dom createNodeCmd elementNode q
    dom createNodeCmd elementNode s 
    dom createNodeCmd elementNode samp
    dom createNodeCmd elementNode script
    dom createNodeCmd elementNode select
    dom createNodeCmd elementNode small
    dom createNodeCmd elementNode span
    dom createNodeCmd elementNode strike
    dom createNodeCmd elementNode strong
    dom createNodeCmd elementNode style
    dom createNodeCmd elementNode sub
    dom createNodeCmd elementNode sup
    dom createNodeCmd elementNode table
    dom createNodeCmd elementNode tbody
    dom createNodeCmd elementNode td
    dom createNodeCmd elementNode textarea
    dom createNodeCmd elementNode tfoot
    dom createNodeCmd elementNode th
    dom createNodeCmd elementNode thead
    dom createNodeCmd elementNode title
    dom createNodeCmd elementNode tr
    dom createNodeCmd elementNode tt
    dom createNodeCmd elementNode u
    dom createNodeCmd elementNode ul
    dom createNodeCmd elementNode var

proc nt {text} { t -disableOutputEscaping ${text} }


 ad_proc render {
     args
 } {
     @author Neophytos Demetriou
 } {
     set xmldoc [dom createDocument html]
     set xmlroot [$xmldoc documentElement]
     $xmlroot appendFromScript {uplevel \#[template::adp_level] ${args}}
     return [$xmlroot asHTML]
 }
