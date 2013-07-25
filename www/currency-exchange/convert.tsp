array set currencyToCountry {
    EUR Euro
    USD {United States}
    GBP {United Kingdom}
    CYP Cyprus
    CAD Canada
    AUD Australia    
    JPY Japan
    INR India
    NZD {New Zealand}    
    CHF Switzerland
    ZAR {South Africa}
}

set comment {

    set iso4217 ${iso4217}
    set country [string tolower ${country}]
    set currencyToCountry(${iso4217}) ${country}
foreach {iso3166 iso4217 country}


    ad EUR Andorra
    ae AED "United Arab Emirates"
    af AFA Afghanistan
    ag XCD "Antigua and Barbuda"
    ai XCD Anguilla
    al ALL Albania
    am AMD Armenia
    an ANG "Netherlands Antilles"
    ao AON Angola
    aq USD Antartica
    ar ARS Argentina
    as USD "American Samoa"
    at EUR Austria
    aw AWG Aruba
    ax EUR "Åland Islands"
    az AZM Azerbaijan
    ba BAM "Bosnia and Herzegovina"
    bb BBD Barbados
    bd BDT Bangladesh
    be EUR Belgium
    bf XOF "Burkina Faso"
    bg BGL Bulgaria
    bh BHD Bahrain
    bi BIF Burundi
    bj XOF Benin
    bm BMD Bermuda
    bn BND Brunei
    bo BOB Bolivia
    br BRL Brazil
    bs BSD Bahamas
    bt BTN Bhutan
    bv NOK BV
    bw BWP Botswana
    by BYR Belarus
    bz BZD Belize
    cc AUD "Cocos (Keeling) Islands"
    cd XAF "Democratic Republic of The Congo"
    cf XAF "Central African Republic"
    cg XAF Congo
    ci XOF "Côte d'Ivoire"
    ck NZD "Cook Islands"
    cl CLP Chile
    cm XAF Cameroon
    cn CNY China
    co COP Colombia
    cr CRC "Costa Rica"
    cs CSK "Czechoslovakia"
    cu CUP Cuba
    cv CVE "Cape Verde"
    cx AUD "Christmas island"
    cy CYP Cyprus
    cz CSK "Czech Republic"
    de EUR Germany
    dj DJF Djibouti
    dk DKK Denmark
    dm XCD Dominica
    do DOP "Dominican Republic"
    dz DZD Algeria
    ec ECS Ecuador
    ee EEK Estonia
    eg EGP Egypt
    eh MAD "Western Sahara"
    er ERN Eritrea
    es EUR Spain
    et ETB Ethiopia
    fi EUR Finland
    fj FJD Fiji
    fk FKP "Falkland Islands"
    fm USD Micronesia
    fo DKK "Faroe islands"
    fr EUR France
    fx EUR "France metropolitan"
    ga XAF Gabon
    gd XCD Grenada
    ge GEL Georgia
    gf EUR "French Guiana"
    gh GHC Ghana
    gi GIP Gibraltar
    gl DKK Greenland
    gm GMD Gambia
    gn GNF Guinea
    gp EUR Guadeloupe
    gq XAF "Equatorial Guinea"
    gr EUR Greece
    gs GBP "South Georgia"
    gt GTQ Guatemala
    gu USD Guam
    gw GWP Guinea-Bissau
    gy GYD Guyana
    hk HKD "Hong Kong"
    hm AUD "Heard and McDonald Islands"
    hn HNL Honduras
    hr HRK Croatia
    ht HTG Haiti
    hu HUF Hungary
    id IDR Indonesia
    ie EUR Ireland
    il ILS Israel
    io USD "British Indian Ocean Territory"
    iq IQD Iraq
    ir IRR Iran
    is ISK Iceland
    it EUR Italy
    jm JMD Jamaica
    jo JOD Jordan
    ke KES Kenya
    kg KGS Kyrgyzstan
    kh KHR Cambodia
    ki AUD Kiribati
    km KMF Comoros
    kn XCD "Saint Kitts and Nevis"
    kp KPW "North Korea"
    kr KRW "South Korea"
    kw KWD Kuwait
    ky KYD "Cayman Islands"
    kz KZT Kazakhstan
    la LAK Laos
    lb LBP Lebanon
    lc XCD "Saint Lucia"
    li CHF Liechtenstein
    lk LKR "Sri Lanka"
    lr LRD Liberia
    ls LSL Lesotho
    lt LTL Lithuania
    lu EUR Luxembourg
    lv LVL Latvia
    ly LYD Libya
    ma MAD Morocco
    mc EUR Monaco
    md MDL Moldova
    mg MGF Madagascar
    mh USD "Marshall Islands"
    mk MKD Macedonia
    ml XOF Mali
    mm MMK Myanmar
    mn MNT Mongolia
    mo MOP Macau
    mp USD "Northern Mariana Islands"
    mq EUR Martinique
    mr MRO Mauritania
    ms XCD Montserrat
    mt MTL Malta
    mu MUR Mauritius
    mv MVR Maldives
    mw MWK Malawi
    mx MXP Mexico
    my MYR Malaysia
    mz MZM Mozambique
    na NAD Namibia
    nc XPF "New Caledonia"
    ne XOF Niger
    nf AUD "Norfolk Island"
    ng NGN Nigeria
    ni NIO Nicaragua
    nl EUR Netherlands
    no NOK Norway
    np NPR Nepal
    nr AUD Nauru
    nu NZD Niue
    om OMR Oman
    pa PAB Panama
    pe PEN Peru
    pf CFP "French Polynesia"
    pg PGK "Papua New Guinea"
    ph PHP Philippines
    pk PKR Pakistan
    pl PLZ Poland
    pm EUR "St. Pierre and Miquelon"
    pn NZD Pitcairn
    pr USD "Puerto Rico"
    ps ILS Palestinian Territories
    pt EUR Portugal
    pw USD Palau
    py PYG Paraguay
    qa QAR Qatar
    re EUR Reunion
    ro ROL Romania
    rw RWF Rwanda
    sa SAR "Saudi Arabia"
    sb SBD "Solomon Islands"
    sc SCR Seychelles
    sd SDD Sudan
    se SEK Sweden
    sg SGD Singapore
    sh SHP "St. Helena"
    si SIT Slovenia
    sj NOK "Svalbard and Jan Mayen Islands"
    sl SLL "Sierra Leone"
    sm EUR "San Marino"
    sn XOF Senegal
    so SOS Somalia
    sr SRG Suriname
    st STD "Sao Tome and Principe"
    sv SVC "El Salvador"
    sy SYP Syria
    sz SZL Swaziland
    tc USD "Turks and Caicos Islands"
    td XAF Chad
    tf EUR "French Southern Territories"
    tg XOF Togo
    th THB Thailand
    tj TJS Tajikistan
    tk NZD Tokelau
    tl IDR "East Timor"
    tm TMM Turkmenistan
    tn TND Tunisia
    to TOP Tonga
    tp TPE "East Timor"
    tr TRL Turkey
    tt TTD "Trinidad and Tobago"
    tv AUD Tuvalu
    tw TWD Taiwan
    tz TZS Tanzania
    ua UAH Ukraine
    ug UGS Uganda
    uk GBP "United Kingdom"
    um USD "United States minor outlying islands"
    us USD "United States"
    uy UYP Uruguay
    uz UZS Uzbekistan
    va EUR Vatican
    vc XCD "Saint Vincent and the Grenadines"
    ve VEB Venezuela
    vg USD "British Virgin Islands"
    vi USD "U.S. Virgin Islands"
    vn VND Vietnam
    vu VUV Vanuatu
    wf XPF "Wallis and Futuna islands"
    ws WST Samoa
    ye YER Yemen
    yt EUR Mayotte
    yu YUN Yugoslavia
    zm ZMK Zambia
    zr XAF "Democratic Republic of The Congo"
    zw ZWD Zimbabwe
}


ad_page_contract {
    @author Neophytos Demetriou
} {
    amount:trim,notnull
    {from:trim EUR}
    {to:trim CYP}
}

if {![string is double ${amount}]} {
    ad_return_complaint 200 "The amount entered is not valid."
    return
}
if {![info exists currencyToCountry(${from})]} {
    rp_returnnotfound
}
if {![info exists currencyToCountry(${to})]} {
    rp_returnnotfound
}

namespace eval ::CurrencyExchangeService {
    set endpoint http://services.xmethods.net:80/soap
    SOAP::create getRate -proxy ${endpoint} \
        -params {country1 string country2 string} \
            -action urn:xmethods-CurrencyExchange\#getRate \
            -encoding http://schemas.xmlsoap.org/soap/encoding/ \
            -uri urn:xmethods-CurrencyExchange
}

set fromCountry $currencyToCountry(${from})
set toCountry $currencyToCountry(${to})
#set fromCountry euro
#set toCountry cyprus


set timeout 3600 ;# 1800
set soap_p false
if { [set rate [::memoize::cache get RATE:${from}-${to}]] eq {} } {
    set soap_p true
    set rate [::CurrencyExchangeService::getRate ${fromCountry} ${toCountry}]
    ::memoize::cache set RATE:${from}-${to} ${rate} ${timeout}
    ::memoize::cache set RATE:${to}-${from} [expr {1/${rate}}] ${timeout}
}

tmpl::master {

    div -style "width: 600" {
	center {
	    b {
		font -size 5 {
		    t "${amount} ${from} = [format "%.2f" [expr {${amount}*${rate}}]] ${to}"
		}
	    }
	}
	p
	blockquote {
	    small {
		b { t "Disclaimer:" }
		t {
		    This service is for informational purposes only and is not intended to provide specific advice. It is provided to you solely for your own personal, non-commercial use.
		}
	    }
	}
    }
}