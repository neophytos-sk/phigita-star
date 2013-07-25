tmpl::master -title "Currency Converter" {
    form -name ucc -action convert -method get {
	table -cellspacing 10 {
	    tr {
		td {
		    b { t "Amount: " }
		    br
		    input -type "text" -name "amount" -value "1" -size 10
		} 
		td {
		    b { t "From: " }
		    br
		    select -name "from" -size 5 {
			option -value "EUR" -selected "" { t {EUR - Euro} }
			option -value "USD" { t {USD - United States Dollars } }
			option -value "GBP" { t {GBP - United Kingdom Pounds} }
			option -value "CYP" { t {CYP - Cyprus Pounds } }
			option -value "JPY" { t {JPY - Japan Yen } }
			option -value "CAD" { t {CAD - Canada Dollars } }
			option -value "AUD" { t {AUD - Australia Dollars } }
			option -value "INR" { t {INR - India Rupees } }
			option -value "NZD" { t {NZD - New Zealand Dollars } }
			option -value "CHF" { t {CHF - Switzerland Francs } }
			option -value "ZAR" { t {ZAR - South Africa Rand } }
		    }
		}
	set comment {
	    option -value "EUR" { t {-- Top 85 Currencies: -- } }

	    option -value "AFA" { t {Afghanistan Afghanis - AFA } }
	    option -value "ALL" { t {Albania Leke - ALL } }
	    option -value "DZD" { t {Algeria Dinars - DZD } }
	    option -value "USD" { t {America (United States) Dollars - USD } }
	    option -value "ARS" { t {Argentina Pesos - ARS } }
	    option -value "AUD" { t {Australia Dollars - AUD } }

	    option -value "ATS" { t {Austria Schillings - ATS* } }
	    option -value "BSD" { t {Bahamas Dollars - BSD } }
	    option -value "BHD" { t {Bahrain Dinars - BHD } }
	    option -value "BDT" { t {Bangladesh Taka - BDT } }
	    option -value "BBD" { t {Barbados Dollars - BBD } }
	    option -value "BEF" { t {Belgium Francs - BEF* } }

	    option -value "BMD" { t {Bermuda Dollars - BMD } }
	    option -value "BRL" { t {Brazil Reais - BRL } }
	    option -value "BGN" { t {Bulgaria Leva - BGN } }
	    option -value "CAD" { t {Canada Dollars - CAD } }
	    option -value "XOF" { t {CFA BCEAO Francs - XOF } }
	    option -value "XAF" { t {CFA BEAC Francs - XAF } }

	    option -value "CLP" { t {Chile Pesos - CLP } }
	    option -value "CNY" { t {China Yuan Renminbi - CNY } }
	    option -value "CNY" { t {RMB (China Yuan Renminbi) - CNY } }
	    option -value "COP" { t {Colombia Pesos - COP } }
	    option -value "XPF" { t {CFP Francs - XPF } }
	    option -value "CRC" { t {Costa Rica Colones - CRC } }

	    option -value "HRK" { t {Croatia Kuna - HRK } }
	    option -value "CZK" { t {Czech Republic Koruny - CZK } }
	    option -value "DKK" { t {Denmark Kroner - DKK } }
	    option -value "DEM" { t {Deutsche (Germany) Marks - DEM* } }
	    option -value "DOP" { t {Dominican Republic Pesos - DOP } }

	    option -value "NLG" { t {Dutch (Netherlands) Guilders - NLG* } }
	    option -value "XCD" { t {Eastern Caribbean Dollars - XCD } }
	    option -value "EGP" { t {Egypt Pounds - EGP } }
	    option -value "EEK" { t {Estonia Krooni - EEK } }
	    option -value "EUR" { t {Euro - EUR } }
	    option -value "FJD" { t {Fiji Dollars - FJD } }

	    option -value "FIM" { t {Finland Markkaa - FIM* } }
	    option -value "FRF" { t {France Francs - FRF* } }
	    option -value "DEM" { t {Germany Deutsche Marks - DEM* } }
	    option -value "XAU" { t {Gold Ounces - XAU } }
	    option -value "GRD" { t {Greece Drachmae - GRD* } }
	    option -value "NLG" { t {Holland (Netherlands) Guilders - NLG* } }

	    option -value "HKD" { t {Hong Kong Dollars - HKD } }
	    option -value "HUF" { t {Hungary Forint - HUF } }
	    option -value "ISK" { t {Iceland Kronur - ISK } }
	    option -value "XDR" { t {IMF Special Drawing Right - XDR } }
	    option -value "INR" { t {India Rupees - INR } }
	    option -value "IDR" { t {Indonesia Rupiahs - IDR } }

	    option -value "IRR" { t {Iran Rials - IRR } }
	    option -value "IQD" { t {Iraq Dinars - IQD } }
	    option -value "IEP" { t {Ireland Pounds - IEP* } }
	    option -value "ILS" { t {Israel New Shekels - ILS } }
	    option -value "ITL" { t {Italy Lire - ITL* } }
	    option -value "JMD" { t {Jamaica Dollars - JMD } }

	    option -value "JPY" { t {Japan Yen - JPY } }
	    option -value "JOD" { t {Jordan Din } }
	}
		td {
		    b { t "To: " }
		    br
		    select -name "to" -size 5 {

			option -value "EUR" { t {EUR - Euro} }
			option -value "USD" { t {USD - United States Dollars } }
			option -value "GBP" { t {GBP - United Kingdom Pounds} }
			option -value "CYP" -selected "" { t {CYP - Cyprus Pounds } }
			option -value "JPY" { t {JPY - Japan Yen } }
			option -value "CAD" { t {CAD - Canada Dollars } }
			option -value "AUD" { t {AUD - Australia Dollars } }


			option -value "INR" { t {INR - India Rupees } }
			option -value "NZD" { t {NZD - New Zealand Dollars } }
			option -value "CHF" { t {CHF - Switzerland Francs } }
			option -value "ZAR" { t {ZAR - South Africa Rand } }
		    }
		}
	set comment {
	    option -value "EUR" { t {-- Top 85 Currencies: -- } }

	    option -value "AFA" { t {Afghanistan Afghanis - AFA } }
	    option -value "ALL" { t {Albania Leke - ALL } }
	    option -value "DZD" { t {Algeria Dinars - DZD } }
	    option -value "USD" { t {America (United States) Dollars - USD } }
	    option -value "ARS" { t {Argentina Pesos - ARS } }
	    option -value "AUD" { t {Australia Dollars - AUD } }

	    option -value "ATS" { t {Austria Schillings - ATS* } }
	    option -value "BSD" { t {Bahamas Dollars - BSD } }
	    option -value "BHD" { t {Bahrain Dinars - BHD } }
	    option -value "BDT" { t {Bangladesh Taka - BDT } }
	    option -value "BBD" { t {Barbados Dollars - BBD } }
	    option -value "BEF" { t {Belgium Francs - BEF* } }

	    option -value "BMD" { t {Bermuda Dollars - BMD } }
	    option -value "BRL" { t {Brazil Reais - BRL } }
	    option -value "BGN" { t {Bulgaria Leva - BGN } }
	    option -value "CAD" { t {Canada Dollars - CAD } }
	    option -value "XOF" { t {CFA BCEAO Francs - XOF } }
	    option -value "XAF" { t {CFA BEAC Francs - XAF } }

	    option -value "CLP" { t {Chile Pesos - CLP } }
	    option -value "CNY" { t {China Yuan Renminbi - CNY } }
	    option -value "CNY" { t {RMB (China Yuan Renminbi) - CNY } }
	    option -value "COP" { t {Colombia Pesos - COP } }
	    option -value "XPF" { t {CFP Francs - XPF } }
	    option -value "CRC" { t {Costa Rica Colones - CRC } }

	    option -value "HRK" { t {Croatia Kuna - HRK } }
	    option -value "CZK" { t {Czech Republic Koruny - CZK } }
	    option -value "DKK" { t {Denmark Kroner - DKK } }
	    option -value "DEM" { t {Deutsche (Germany) Marks - DEM* } }
	    option -value "DOP" { t {Dominican Republic Pesos - DOP } }

	    option -value "NLG" { t {Dutch (Netherlands) Guilders - NLG* } }
	    option -value "XCD" { t {Eastern Caribbean Dollars - XCD } }
	    option -value "EGP" { t {Egypt Pounds - EGP } }
	    option -value "EEK" { t {Estonia Krooni - EEK } }
	    option -value "EUR" { t {Euro - EUR } }
	    option -value "FJD" { t {Fiji Dollars - FJD } }

	    option -value "FIM" { t {Finland Markkaa - FIM* } }
	    option -value "FRF" { t {France Francs - FRF* } }
	    option -value "DEM" { t {Germany Deutsche Marks - DEM* } }
	    option -value "XAU" { t {Gold Ounces - XAU } }
	    option -value "GRD" { t {Greece Drachmae - GRD* } }
	    option -value "NLG" { t {Holland (Netherlands) Guilders - NLG* } }

	    option -value "HKD" { t {Hong Kong Dollars - HKD } }
	    option -value "HUF" { t {Hungary Forint - HUF } }
	    option -value "ISK" { t {Iceland Kronur - ISK } }
	    option -value "XDR" { t {IMF Special Drawing Right - XDR } }
	    option -value "INR" { t {India Rupees - INR } }
	    option -value "IDR" { t {Indonesia Rupiahs - IDR } }

	    option -value "IRR" { t {Iran Rials - IRR } }
	    option -value "IQD" { t {Iraq Dinars - IQD } }
	    option -value "IEP" { t {Ireland Pounds - IEP* } }
	    option -value "ILS" { t {Israel New Shekels - ILS } }
	    option -value "ITL" { t {Italy Lire - ITL* } }
	    option -value "JMD" { t {Jamaica Dollars - JMD } }

	    option -value "JPY" { t {Japan Yen - JPY } }
	    option -value "JOD" { t {Jordan Din } }
	}
	    }
	    tr {
		td -colspan 3 -align center {
		    br
		    input -type submit -style "width:300;font-family:Arial,Helvetica; font-size:9pt; color:#000000; font-weight:bold;" -value "Perform Currency Conversion"
		}
	    }
	}
    }
}