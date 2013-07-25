# QuantLib/Examples/CDS/CDS.cpp

set libdir [acs_root_dir]/packages/tools/lib/
#source [file join $libdir critcl-ext/tcl/module-critcl-ext.tcl]

package require critcl
::critcl::config force 1
::critcl::config keepsrc 1
::critcl::config language c++

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/src/tmp/QuantLib-1.0.1/ql/.libs/
#::real_exec "export LD_LIBRARY_PATH=/usr/local/src/tmp/QuantLib-1.0.1/ql/.libs/"

::critcl::clibraries -lQuantLib -lstdc++ 

#::critcl::config I /usr/local/src/tmp/QuantLib-1.0.1/
#::critcl::config I /usr/local/include/
::critcl::config I /opt/QuantLib-1.0.1/include/

critcl::ccode {
    #include <ql/quantlib.hpp>
    #include <boost/timer.hpp>
    #include <iostream>
    #include <iomanip>

    using namespace std;
    using namespace QuantLib;
}

critcl::cproc quantlib_test_1 {} double {

        /*********************
         ***  MARKET DATA  ***
         *********************/

        Calendar calendar = TARGET();
        Date todaysDate(15, May, 2007);
        // must be a business day
        todaysDate = calendar.adjust(todaysDate);

        Settings::instance().evaluationDate() = todaysDate;

        // dummy curve
        boost::shared_ptr<Quote> flatRate(new SimpleQuote(0.01));
        Handle<YieldTermStructure> tsCurve(
              boost::shared_ptr<FlatForward>(
                      new FlatForward(todaysDate, Handle<Quote>(flatRate),
                                      Actual365Fixed())));

        /*
          In Lehmans Brothers "guide to exotic credit derivatives"
          p. 32 there's a simple case, zero flat curve with a flat CDS
          curve with constant market spreads of 150 bp and RR = 50%
          corresponds to a flat 3% hazard rate. The implied 1-year
          survival probability is 97.04% and the 2-years is 94.18%
        */

        // market
        Real recovery_rate = 0.5;
        Real quoted_spreads[] = { 0.0150, 0.0150, 0.0150, 0.0150 };
        vector<Period> tenors;
        tenors.push_back(3*Months);
        tenors.push_back(6*Months);
        tenors.push_back(1*Years);
        tenors.push_back(2*Years);
        vector<Date> maturities;
        for (Size i=0; i<4; i++) {
            maturities.push_back(calendar.adjust(todaysDate + tenors[i],
                                                 Following));
        }

        std::vector<boost::shared_ptr<DefaultProbabilityHelper> > instruments;
        for (Size i=0; i<4; i++) {
            instruments.push_back(boost::shared_ptr<DefaultProbabilityHelper>(
                new SpreadCdsHelper(
                              Handle<Quote>(boost::shared_ptr<Quote>(
                                         new SimpleQuote(quoted_spreads[i]))),
                              tenors[i],
                              0,
                              calendar,
                              Quarterly,
                              Following,
                              DateGeneration::TwentiethIMM,
                              Actual365Fixed(),
                              recovery_rate,
                              tsCurve)));
        }

   // Bootstrap hazard rates
        boost::shared_ptr<PiecewiseDefaultCurve<HazardRate, BackwardFlat> >
           hazardRateStructure(
               new PiecewiseDefaultCurve<HazardRate, BackwardFlat>(
                                                           todaysDate,
                                                           instruments,
                                                           Actual365Fixed()));
        vector<pair<Date, Real> > hr_curve_data = hazardRateStructure->nodes();


	// Tcl_

	return hr_curve_data[0].second;
}

doc_return 200 text/plain "ok\n\nCalibrated hazard rate values (hr_curve_data\[0\].second): [quantlib_test_1]"