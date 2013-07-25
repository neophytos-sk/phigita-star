tmpl::master -docStyleId doc3 -docStyleClass z-t2 -title "Finance" {
    div -id "bd" {
	div -id "z-main" {
	    div -class "z-b" {
		div -class "z-gc" {
		    div -class "z-u first" {
			div -style "background:#E5ECF9;line-height:30px;" { t "Market Summary" }
			div -style "float:right;width:300px;height:250px;background:#f0f0f0;text-align:center;" { t "CHARTS" }
			t "blah blah"
		    }
		    div -class z-u {
			div -style "background:#E5ECF9;line-height:30px;" { t "In the Buzz" }
			div -style "height:250px;background:#f0f0f0;text-align:center;margin:auto;" { t "QWERTY" }
		    }
		}
	    }
	    div -class "z-b" {
		div -class "z-gc" {
		    div -class "z-u first" {
			div -style "background:#E5ECF9;line-height:30px;" { t "XYZ" }
		    }
		    div -class "z-u" {
			div {
			    div -style "background:#E5ECF9;line-height:30px;" { t "Currencies" }
			    div { t "EUR / USD" }
			    div { t "USD / JPY" }
			    div { t "GBP / USD" }
			    div { t "CAD / USD" }
			    div -style "background:#f0f0f0;" {
				form -action cc {
				    table {
					tbody {
					    tr {
						td -align right {
						    t "Convert "
						    input -name amount -type text -value "1" -size 5 -maxlength 12 -autocomplete off
						}
						td {
						    set labels {
							{EUR - Euro} 
							{USD - United States Dollar}
							{JPY - Japanese Yen}
							{GBP - British Pound}
							{CAD - Canadian Dollar}
							{AUD - Australian Dollar}
							{CHF - Swiss Franc}
							{RUB - Russian Ruble}
							{CNY - Chinese Yuan}
							{ZAR - South African Rand}
							{MXN - Mexican Peso}
						    }
						    set values {EUR USD JPY GBP CAD AUD CHF RUB CNY ZAR MXN}
						    t -disableOutputEscaping " [ns_htmlselect -labels ${labels} from ${values} EUR] "
						}
					    }
					    tr {
						td -align right {
						    t " into "
						}
						td {
						    t -disableOutputEscaping " [ns_htmlselect -labels ${labels} to ${values} USD] "
						}
					    }
					    tr {
						td -colspan 2 -align right {
						    button -type submit { t Convert }
						}
					    }
					}
				    }
				}
			    }
			}
			div -class z-g {
			    div -style "width:48.1%;float:left;" {
				div -class pl {
				    h3 { t Portals }
				    div { a -href "http://www.bloomberg.com/" { t "Bloomberg" } }
				    div { a -href "http://www.cnbc.com/" { t "CNBC" } }
				    div { a -href "http://money.cnn.com/" { t "CNN Money" } }
				    div { a -href "http://www.fool.com/" { t "Fool.com" } }
				    div { a -href "http://www.ft.com/" { t "FT" } }
				    div { a -href "http://www.marketwatch.com/" { t "MarketWatch" } }
				    div { a -href "http://moneycentral.msn.com/" { t "MSN Money" } }
				    div { a -href "http://finance.google.com/" { t "Google Finance" } }
				    div { a -href "http://online.wsj.com/" { t "WSJ" } }
				    div { a -href "http://finance.yahoo.com/" { t "Yahoo! Finance" } }
				}
				div -class pl {
				    h3 { t " Greece & Cyprus " }
				    div { a -href "http://www.bankingnews.gr/" { t "BankingNews" } }
				    div { a -href "http://www.stockwatch.com.cy/" { t "StockWatch" } }
				    div { a -href "http://www.deiktes.com/" { t "Deiktes" } }
				    div { a -href "http://www.moneynet.com.cy/" { t "MoneyNet" } }
				    div { a -href "http://www.nomisma.com.cy/" { t "Nomisma" } }
				    div { a -href "http://www.xak.com/" { t "XAK" } }
				}
				div -class pl {
				    h3 { t "GOV" }
				    div { a -href "http://www.recovery.gov" { t "Recovery (US)" } }
				    div { a -href "http://www.gge.gr/" { t "GGE (GR)" } }
				    div { a -href "http://www.mnec.gr/" -title "Ministry of Economy and Finance" { t "MNEC (GR)" } }
				    div { a -href "http://www.bankofgreece.gr/" -title "Bank of Greece" { t "BOG (GR)" } }
				    div { a -href "http://www.mcit.gov.cy/" -title "Ministry of Commerce, Industry, and Tourism" { t "MCIT (CY)" } }
				    div { a -href "http://www.mof.gov.cy/" -title "Ministry of Finance" { t "MOF (CY)" } }
				    div { a -href "http://www.centralbank.gov.cy/" -title "Central Bank of Cyprus" { t "CBOC (CY)" } }
				}
				div -class pl {
				    h3 { t "ORG" }
				    div { a -href "http://www.ccci.org.cy/" -title "Cyprus Chamber of Commerce and Industry" { t "CCCI (CY)" } }
				    div { a -href "http://www.ncci.org.cy/" -title "Cyprus Chamber of Commerce and Industry" { t "NCCI (CY)" } }
				    div { a -href "http://www.cgba.org.cy/" -title "Cyprus-Greece Business Association" { t "CGBA (CY)" } }
				}
			    }
			    div -style "width:48.1%; float:left;" {
				div -class pl {
				    h3 { t "Stock Exchanges" }
				    div { a -href "http://www.nasdaq.com/" { t "NASDAQ" } }
				    div { a -href "http://www.nyse.com/" -title "New York Stock Exchange" { t "NYSE" } }
				    div { a -href "http://www.amex.com/" -title "American Stock Exchange" { t "AMEX" } }
				    div { a -href "http://www.londonstockexchange.com/" -title "London Stock Exchange" { t "LSE (UK)" } }
				    div { a -href "http://www.tsx.com/" { t "TSX" } }
				    div { a -href "http://www.cse.com.cy/" { t "CSE (CY)" } }
				    div { a -href "http://www.cse.com.cy/" { t "ASE (GR)" } }
				}
				div -class pl {
				    h3 { t "Future Exchanges" }
				    div { a -href "http://www.cme.com/" -title "Chicago Merchantile Exchange" { t "CME" } }
				    div { a -href "http://www.cboe.com/" -title "Chicago Board Options Exchange" { t "CBOE" } }
				    div { a -href "http://www.nymex.com/" { t "NYMEX" } }
				    div { a -href "http://www.nybot.com/" -title "New York Board of Trade" { t "NYBOT" } }
				    div { a -href "http://www.lme.co.uk/" -title "London Metal Exchange" { t "LME (UK)" } }
				    div { a -href "http://www.onechicago.com/" { t "OneChicago" } }
				    div { a -href "http://www.tocom.or.jp/" -title "Tokyo Commodity Exchange" { t "TOCOM (JP)" } }
				    div { a -href "http://www.wce.ca/" -title "Winnipeg Commodity Exchange" { t "WCE (CA)" } }
				    div { a -href "http://www.eurexchange.com/" { t "Eurex (EU)" } }
				    div { a -href "http://www.kcbt.com/" -title "Kansas City Board of Trade" { t "KCBT" } }
				    div { a -href "http://www.mgex.com/" -title "Minneapolis Grain Exchange" { t "MGEX" } }
				}
				div -class pl {
				    h3 { t "Option Exchanges" }
				    div { a -href "http://www.cboe.com/" { t "CBOE" } }
				    div { a -href "http://www.ise.com/" -title "International Securities Exchange" { t "ISE" } }
				    div { a -href "http://www.phlx.com/" -title "Philadelphia Stock Exchange" { t "PHLX" } }
				    div { a -href "http://www.bostonoptions.com/" -title "Boston Options Exchange" { t "BostonOptions" } }
				    div { a -href "http://www.amex.com/" -title "American Stock Exchange" { t "AMEX" } }
				    div { a -href "http://www.888options.com/" -title "Options Industry Council" { t "OIC" } }
				    div { a -href "http://www.m-x.com/" -title "Montreal Exchange" { t "MX (CA)" } }
					
				}
			    }
			}
		    }
		}
	    }
	}
	div -class "z-b" {
	    t test-left
	}
    }
}