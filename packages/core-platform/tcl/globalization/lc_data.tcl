#/packages/lang/tcl/localization-data-init.tcl
ad_library {

    Database required for localization routines
    Currently only supports five locales (US, UK, France, Spain and Germany).
    Add new entries to support additional locales.

    @creation-date 10 September 2000
    @author Jeff Davis (davis@xarg.net)
    @cvs-id $Id: localization-data-init.tcl,v 1.5 2003/01/24 13:03:59 peterm Exp $
}


# UK
nsv_set locale en_GB,abday {{Sun} {Mon} {Tue} {Wed} {Thu} {Fri} {Sat}}
nsv_set locale en_GB,abmon {{Jan} {Feb} {Mar} {Apr} {May} {Jun} {Jul} {Aug} {Sep} {Oct} {Nov} {Dec}}
nsv_set locale en_GB,am_str ""
nsv_set locale en_GB,currency_symbol "£"
nsv_set locale en_GB,day {{Sunday} {Monday} {Tuesday} {Wednesday} {Thursday} {Friday} {Saturday}}
nsv_set locale en_GB,firstdayofweek 0
nsv_set locale en_GB,decimal_point "."
nsv_set locale en_GB,d_fmt "%d/%m/%y"
nsv_set locale en_GB,d_t_fmt "%a %d %B %Y %H:%M %Z"
nsv_set locale en_GB,dlong_fmt "%d %B %Y"
nsv_set locale en_GB,dlongweekday_fmt "%A %d %B %Y"
nsv_set locale en_GB,frac_digits 2
nsv_set locale en_GB,grouping {3 3 }
nsv_set locale en_GB,int_curr_symbol "GBP "
nsv_set locale en_GB,int_frac_digits 2
nsv_set locale en_GB,mon_decimal_point "."
nsv_set locale en_GB,mon_grouping {3 3 }
nsv_set locale en_GB,mon {{January} {February} {March} {April} {May} {June} {July} {August} {September} {October} {November} {December}}
nsv_set locale en_GB,mon_thousands_sep ","
nsv_set locale en_GB,n_cs_precedes 1
nsv_set locale en_GB,negative_sign "-"
nsv_set locale en_GB,n_sep_by_space 0
nsv_set locale en_GB,n_sign_posn             1
nsv_set locale en_GB,p_cs_precedes 1
nsv_set locale en_GB,pm_str ""
nsv_set locale en_GB,positive_sign ""
nsv_set locale en_GB,p_sep_by_space 0
nsv_set locale en_GB,p_sign_posn 1
nsv_set locale en_GB,t_fmt_ampm ""
nsv_set locale en_GB,t_fmt "%H:%M"
nsv_set locale en_GB,thousands_sep ","
nsv_set locale en_GB,formbuilder_time_format "HH12:MI AM"

# el_GR
nsv_set locale el_GR,abday {{Sun} {Mon} {Tue} {Wed} {Thu} {Fri} {Sat}}
nsv_set locale el_GR,abmon {{Jan} {Feb} {Mar} {Apr} {May} {Jun} {Jul} {Aug} {Sep} {Oct} {Nov} {Dec}}
nsv_set locale el_GR,am_str ""
nsv_set locale el_GR,currency_symbol "£"
nsv_set locale el_GR,day {{Sunday} {Monday} {Tuesday} {Wednesday} {Thursday} {Friday} {Saturday}}
nsv_set locale el_GR,firstdayofweek 0
nsv_set locale el_GR,decimal_point "."
nsv_set locale el_GR,d_fmt "%d/%m/%y"
nsv_set locale el_GR,d_t_fmt "%a %d %B %Y %H:%M %Z"
nsv_set locale el_GR,dlong_fmt "%d %B %Y"
nsv_set locale el_GR,dlongweekday_fmt "%A %d %B %Y"
nsv_set locale el_GR,frac_digits 2
nsv_set locale el_GR,grouping {3 3 }
nsv_set locale el_GR,int_curr_symbol "GBP "
nsv_set locale el_GR,int_frac_digits 2
nsv_set locale el_GR,mon_decimal_point "."
nsv_set locale el_GR,mon_grouping {3 3 }
nsv_set locale el_GR,mon {{January} {February} {March} {April} {May} {June} {July} {August} {September} {October} {November} {December}}
nsv_set locale el_GR,mon_thousands_sep ","
nsv_set locale el_GR,n_cs_precedes 1
nsv_set locale el_GR,negative_sign "-"
nsv_set locale el_GR,n_sep_by_space 0
nsv_set locale el_GR,n_sign_posn             1
nsv_set locale el_GR,p_cs_precedes 1
nsv_set locale el_GR,pm_str ""
nsv_set locale el_GR,positive_sign ""
nsv_set locale el_GR,p_sep_by_space 0
nsv_set locale el_GR,p_sign_posn 1
nsv_set locale el_GR,t_fmt_ampm ""
nsv_set locale el_GR,t_fmt "%H:%M"
nsv_set locale el_GR,thousands_sep ","
nsv_set locale el_GR,formbuilder_time_format "HH12:MI AM"

# US
nsv_set locale en_US,abday {{Sun} {Mon} {Tue} {Wed} {Thu} {Fri} {Sat}}
nsv_set locale en_US,abmon {{Jan} {Feb} {Mar} {Apr} {May} {Jun} {Jul} {Aug} {Sep} {Oct} {Nov} {Dec}}
nsv_set locale en_US,am_str "AM"
nsv_set locale en_US,currency_symbol "$"
nsv_set locale en_US,day {{Sunday} {Monday} {Tuesday} {Wednesday} {Thursday} {Friday} {Saturday}}
nsv_set locale en_US,firstdayofweek 0
nsv_set locale en_US,decimal_point "."
nsv_set locale en_US,d_fmt "%m/%d/%y"
nsv_set locale en_US,d_t_fmt "%a %B %d, %Y %r %Z"
nsv_set locale en_US,dlong_fmt "%B %d, %Y"
nsv_set locale en_US,dlongweekday_fmt "%A %B %d, %Y"
nsv_set locale en_US,frac_digits 2
nsv_set locale en_US,grouping {3 3 }
nsv_set locale en_US,int_curr_symbol "USD "
nsv_set locale en_US,int_frac_digits 2
nsv_set locale en_US,mon_decimal_point "."
nsv_set locale en_US,mon_grouping {3 3 }
nsv_set locale en_US,mon {{January} {February} {March} {April} {May} {June} {July} {August} {September} {October} {November} {December}}
nsv_set locale en_US,mon_thousands_sep ","
nsv_set locale en_US,n_cs_precedes 1
nsv_set locale en_US,negative_sign "-"
nsv_set locale en_US,n_sep_by_space 0
nsv_set locale en_US,n_sign_posn             1
nsv_set locale en_US,p_cs_precedes 1
nsv_set locale en_US,pm_str "PM"
nsv_set locale en_US,positive_sign ""
nsv_set locale en_US,p_sep_by_space 0
nsv_set locale en_US,p_sign_posn 1
nsv_set locale en_US,t_fmt_ampm "%I:%M:%S %p"
nsv_set locale en_US,t_fmt "%r"
nsv_set locale en_US,thousands_sep ","
nsv_set locale en_US,formbuilder_time_format "HH12:MI AM"

# France
nsv_set locale fr_FR,abday {{dim} {lun} {mar} {mer} {jeu} {ven} {sam}}
nsv_set locale fr_FR,abmon {{jan} {fιv} {mar} {avr} {mai} {jun} {jui} {aoϋ} {sep} {oct} {nov} {dιc}}
nsv_set locale fr_FR,am_str ""
nsv_set locale fr_FR,currency_symbol "F"
nsv_set locale fr_FR,day {{dimanche} {lundi} {mardi} {mercredi} {jeudi} {vendredi} {samedi}}
nsv_set locale fr_FR,firstdayofweek 1
nsv_set locale fr_FR,decimal_point ","
nsv_set locale fr_FR,d_fmt "%d.%m.%Y"
nsv_set locale fr_FR,d_t_fmt "%a %d %B %Y %H:%M %Z"
nsv_set locale fr_FR,dlong_fmt "%d %B %Y"
nsv_set locale fr_FR,dlongweekday_fmt "%A %d %B %Y"
nsv_set locale fr_FR,frac_digits 2
nsv_set locale fr_FR,grouping {-1 -1 }
nsv_set locale fr_FR,int_curr_symbol "FRF "
nsv_set locale fr_FR,int_frac_digits 2
nsv_set locale fr_FR,mon_decimal_point ","
nsv_set locale fr_FR,mon_grouping {3 3 }
nsv_set locale fr_FR,mon {{janvier} {fιvrier} {mars} {avril} {mai} {juin} {juillet} {aoϋt} {septembre} {octobre} {novembre} {dιcembre}}
nsv_set locale fr_FR,mon_thousands_sep " "
nsv_set locale fr_FR,n_cs_precedes 0
nsv_set locale fr_FR,negative_sign "-"
nsv_set locale fr_FR,n_sep_by_space 1
nsv_set locale fr_FR,n_sign_posn               1
nsv_set locale fr_FR,p_cs_precedes 0
nsv_set locale fr_FR,pm_str ""
nsv_set locale fr_FR,positive_sign ""
nsv_set locale fr_FR,p_sep_by_space 1
nsv_set locale fr_FR,p_sign_posn 1
nsv_set locale fr_FR,t_fmt_ampm ""
nsv_set locale fr_FR,t_fmt "%H:%M"
nsv_set locale fr_FR,thousands_sep "."
nsv_set locale fr_FR,formbuilder_time_format "HH24:MI"

# Germany
nsv_set locale de_DE,abday {{Son} {Mon} {Die} {Mit} {Don} {Fre} {Sam}}
nsv_set locale de_DE,abmon {{Jan} {Feb} {Mδr} {Apr} {Mai} {Jun} {Jul} {Aug} {Sep} {Okt} {Nov} {Dez}}
nsv_set locale de_DE,am_str ""
nsv_set locale de_DE,currency_symbol "DM"
nsv_set locale de_DE,day {{Sonntag} {Montag} {Dienstag} {Mittwoch} {Donnerstag} {Freitag} {Samstag}}
nsv_set locale de_DE,firstdayofweek 1
nsv_set locale de_DE,decimal_point ","
nsv_set locale de_DE,d_fmt "%d.%m.%Y"
nsv_set locale de_DE,d_t_fmt "%a %d %B %Y %H:%M %Z"
nsv_set locale de_DE,dlong_fmt "%d %B %Y"
nsv_set locale de_DE,dlongweekday_fmt "%A %d %B %Y"
nsv_set locale de_DE,frac_digits 2
nsv_set locale de_DE,grouping {3 3 }
nsv_set locale de_DE,int_curr_symbol "DEM "
nsv_set locale de_DE,int_frac_digits 2
nsv_set locale de_DE,mon_decimal_point ","
nsv_set locale de_DE,mon_grouping {3 3 }
nsv_set locale de_DE,mon {{Januar} {Februar} {Mδrz} {April} {Mai} {Juni} {Juli} {August} {September} {Oktober} {November} {Dezember}}
nsv_set locale de_DE,mon_thousands_sep "."
nsv_set locale de_DE,n_cs_precedes 1
nsv_set locale de_DE,negative_sign "-"
nsv_set locale de_DE,n_sep_by_space 0
nsv_set locale de_DE,n_sign_posn               1
nsv_set locale de_DE,p_cs_precedes 1
nsv_set locale de_DE,pm_str ""
nsv_set locale de_DE,positive_sign ""
nsv_set locale de_DE,p_sep_by_space 0
nsv_set locale de_DE,p_sign_posn 1
nsv_set locale de_DE,t_fmt_ampm ""
nsv_set locale de_DE,t_fmt "%H:%M"
nsv_set locale de_DE,thousands_sep "."
nsv_set locale de_DE,formbuilder_time_format "HH24:MI"

# Spain
nsv_set locale es_ES,abday {{dom} {lun} {mar} {miι} {jue} {vie} {sαb}}
nsv_set locale es_ES,abmon {{ene} {feb} {mar} {abr} {may} {jun} {jul} {ago} {sep} {oct} {nov} {dic}}
nsv_set locale es_ES,am_str ""
nsv_set locale es_ES,currency_symbol "Pts"
nsv_set locale es_ES,day {{domingo} {lunes} {martes} {miιrcoles} {jueves} {viernes} {sαbado}}
nsv_set locale es_ES,firstdayofweek 1
nsv_set locale es_ES,decimal_point ","
nsv_set locale es_ES,d_fmt "%d/%m/%y"
nsv_set locale es_ES,d_t_fmt "%a %d %B %Y %H:%M %Z"
nsv_set locale es_ES,dlong_fmt "%d %B %Y"
nsv_set locale es_ES,dlongweekday_fmt "%A %d %B %Y"
nsv_set locale es_ES,frac_digits 0
nsv_set locale es_ES,grouping {-1 -1 }
nsv_set locale es_ES,int_curr_symbol "ESP "
nsv_set locale es_ES,int_frac_digits 0
nsv_set locale es_ES,mon_decimal_point ","
nsv_set locale es_ES,mon {{enero} {febrero} {marzo} {abril} {mayo} {junio} {julio} {agosto} {septiembre} {octubre} {noviembre} {diciembre}}
nsv_set locale es_ES,mon_grouping {3 3 }
nsv_set locale es_ES,mon_thousands_sep "."
nsv_set locale es_ES,n_cs_precedes 1
nsv_set locale es_ES,negative_sign "-"
nsv_set locale es_ES,n_sep_by_space 1
nsv_set locale es_ES,n_sign_posn          1
nsv_set locale es_ES,p_cs_precedes 1
nsv_set locale es_ES,pm_str ""
nsv_set locale es_ES,positive_sign ""
nsv_set locale es_ES,p_sep_by_space 1
nsv_set locale es_ES,p_sign_posn 1
nsv_set locale es_ES,t_fmt_ampm ""
nsv_set locale es_ES,t_fmt "%H:%M"
nsv_set locale es_ES,thousands_sep ""
nsv_set locale es_ES,formbuilder_time_format "HH24:MI"

# Danish
nsv_set locale da_DK,abday {{sψn} {man} {tir} {ons} {tor} {fre} {lψr}}
nsv_set locale da_DK,abmon {{jan} {feb} {mar} {apr} {maj} {jun} {jul} {aug} {sep} {okt} {nov} {dec}}
nsv_set locale da_DK,am_str ""
nsv_set locale da_DK,currency_symbol "kr"
nsv_set locale da_DK,day {{sψndag} {mandag} {tirsdag} {onsdag} {torsdag} {fredag} {lψrdag}}
nsv_set locale da_DK,firstdayofweek 1
nsv_set locale da_DK,decimal_point ","
nsv_set locale da_DK,d_fmt "%e/%m-%y"
nsv_set locale da_DK,d_t_fmt "%a %e. %B %Y %r %Z"
nsv_set locale da_DK,dlong_fmt "%e. %B %Y"
nsv_set locale da_DK,dlongweekday_fmt "%A den %e. %B %Y"
nsv_set locale da_DK,frac_digits 2
nsv_set locale da_DK,grouping {3 3 }
nsv_set locale da_DK,int_curr_symbol "DKK "
nsv_set locale da_DK,int_frac_digits 2
nsv_set locale da_DK,mon_decimal_point ","
nsv_set locale da_DK,mon_grouping {3 3 }
nsv_set locale da_DK,mon {{januar} {februar} {marts} {april} {maj} {juni} {juli} {august} {september} {oktober} {november} {december}}
nsv_set locale da_DK,mon_thousands_sep "."
nsv_set locale da_DK,n_cs_precedes 1
nsv_set locale da_DK,negative_sign "-"
nsv_set locale da_DK,n_sep_by_space 0
nsv_set locale da_DK,n_sign_posn             1
nsv_set locale da_DK,p_cs_precedes 1
nsv_set locale da_DK,pm_str ""
nsv_set locale da_DK,positive_sign ""
nsv_set locale da_DK,p_sep_by_space 0
nsv_set locale da_DK,p_sign_posn 1
nsv_set locale da_DK,t_fmt_ampm ""
nsv_set locale da_DK,t_fmt "%H:%M"
nsv_set locale da_DK,thousands_sep "."
nsv_set locale da_DK,formbuilder_time_format "HH24:MI"

# FI
nsv_set locale fi_FI,abday {{su} {ma} {ti} {ke} {to} {pe} {la}}
nsv_set locale fi_FI,abmon {{tammi} {helmi} {maalis} {huhti} {touko} {kesδ}{heinδ} {elo} {syys} {loka} {marras} {joulu}}
nsv_set locale fi_FI,am_str ""
nsv_set locale fi_FI,currency_symbol "E"
nsv_set locale fi_FI,day {{sunnuntai} {maanantai} {tiistai} {keskiviikko} {torstai} {perjantai} {lauantai}}
nsv_set locale fi_FI,firstdayofweek 1
nsv_set locale fi_FI,decimal_point ","
nsv_set locale fi_FI,d_fmt "%d.%m.%Y"
nsv_set locale fi_FI,d_t_fmt "%a, %d. %Bta %Y %H:%M %Z"
nsv_set locale fi_FI,frac_digits 2
nsv_set locale fi_FI,grouping {3 3 }
nsv_set locale fi_FI,int_curr_symbol "EUR "
nsv_set locale fi_FI,int_frac_digits 2
nsv_set locale fi_FI,mon_decimal_point ","
nsv_set locale fi_FI,mon_grouping {3 3 }
nsv_set locale fi_FI,mon {{tammikuu} {helmikuu} {maaliskuu} {huhtikuu} {toukokuu} {kesδkuu} {heinδkuu} {elokuu} {syyskuu} {lokakuu} {marraskuu} {joulukuu}}
nsv_set locale fi_FI,mon_thousands_sep " "
nsv_set locale fi_FI,n_cs_precedes 1
nsv_set locale fi_FI,negative_sign "-"
nsv_set locale fi_FI,n_sep_by_space 0
nsv_set locale fi_FI,n_sign_posn             1
nsv_set locale fi_FI,p_cs_precedes 1
nsv_set locale fi_FI,pm_str ""
nsv_set locale fi_FI,positive_sign ""
nsv_set locale fi_FI,p_sep_by_space 0
nsv_set locale fi_FI,p_sign_posn 1
nsv_set locale fi_FI,t_fmt_ampm ""
nsv_set locale fi_FI,t_fmt "%H:%M"
nsv_set locale fi_FI,thousands_sep " "
nsv_set locale fi_FI,dlong_fmt "%d. %Bta %Y"
nsv_set locale fi_FI,dlongweekday_fmt "%A, %d. %Bta %Y"
nsv_set locale fi_FI,formbuilder_time_format "HH24:MI"

# Monetary amounts
nsv_set locale money:000  {($num$sym)}
nsv_set locale money:001  {($num $sym)}
nsv_set locale money:002  {($num$sym)} 
nsv_set locale money:010  {$sign$num$sym}
nsv_set locale money:011  {$sign$num $sym}
nsv_set locale money:012  {$sign$num $sym} 
nsv_set locale money:020  {$num$sym$sign}
nsv_set locale money:021  {$num $sym$sign}
nsv_set locale money:022  {$num$sym $sign}
nsv_set locale money:030  {$num$sign$sym}
nsv_set locale money:031  {$num $sign$sym}
nsv_set locale money:032  {$num$sign $sym}
nsv_set locale money:040  {$num$sym$sign}
nsv_set locale money:041  {$num $sym$sign}
nsv_set locale money:042  {$num$sym $sign}
nsv_set locale money:100  {($sym$num)}
nsv_set locale money:101  {($sym$num)}
nsv_set locale money:102  {($sym$num)}
nsv_set locale money:110  {$sign$sym$num}
nsv_set locale money:111  {$sign$sym$num}
nsv_set locale money:112  {$sign$sym$num} 
nsv_set locale money:120  {$sym$num$sign}
nsv_set locale money:121  {$sym$num$sign}
nsv_set locale money:122  {$sym$num$sign} 
nsv_set locale money:130  {$sign$sym$num}
nsv_set locale money:131  {$sign$sym$num}
nsv_set locale money:132  {$sign$sym$num} 
nsv_set locale money:140  {$sym$sign$num}
nsv_set locale money:141  {$sym$sign$num}
nsv_set locale money:142  {$sym$sign$num} 
