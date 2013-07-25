val -id "copyright_year" -cache_timeout 3600 { clock format [clock seconds] -format %Y }

css -src "/www/resources/bootstrap/css/phigita.bootstrap.css"

css {
    #footer .info {color: #666;}
}


master -src "/templates/blank-master.inc" {

    div -class "container" {
	a -href "http://www.phigita.net/" {
	    img -width 135 -height 40 -src //www.phigita.net/graphics/logo-v2.png
	}
	p
	slave
	hr
	div -id "footer" {
	    small { nt "Copyright &copy; 2000-@{copyright_year} <strong>phigita</strong>. All rights reserved." }
	}
    }

}
