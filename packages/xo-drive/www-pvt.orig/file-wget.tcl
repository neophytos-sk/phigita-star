ad_page_contract {
    @author Neophytos Demetriou
} {
    url:trim,notnull
}
set tmpname [ns_tmpnam]
exec -- /bin/sh -c "/usr/bin/wget -O $tmpname $url || exit 0" 2> /dev/null

ns_returnfile 200 image/jpeg $tmpname
