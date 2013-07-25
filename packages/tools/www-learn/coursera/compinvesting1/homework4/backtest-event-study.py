'''
(c) 2011, 2012 Georgia Tech Research Corporation
This source code is released under the New BSD license.  Please see
http://wiki.quantsoftware.org/index.php?title=QSTK_License
for license details.

Created on March, 5, 2012

@author: Sourabh Bajaj
@contact: sourabhbajaj90@gmail.com
@summary: Event Profiler Tutorial
'''


import pandas 
from qstkutil import DataAccess as da
import numpy as np
import math
import copy
import qstkutil.qsdateutil as du
import datetime as dt
import qstkutil.DataAccess as da
import qstkutil.tsutil as tsu
import qstkstudy.EventProfiler as ep

"""
Accepts a list of symbols along with start and end date
Returns orders to be executed
"""

# Get the data from the data store
storename = "Yahoo" # get data from our daily prices source
# Available field names: open, close, high, low, close, actual_close, volume
closefield = "actual_close"

def generateTrades(symbols, startday,endday, nr_shares):

	# Reading the Data for the list of Symbols.	
	timeofday=dt.timedelta(hours=16)
	timestamps = du.getNYSEdays(startday,endday,timeofday)

	dataobj = da.DataAccess('Yahoo')

	# Reading the Data
	actual_close = dataobj.get_data(timestamps, symbols, closefield)
	
	# Completing the Data - Removing the NaN values from the Matrix
	actual_close = (actual_close.fillna(method='ffill')).fillna(method='backfill')
	

        last_day = timestamps[-1]

	for symbol in symbols:
	    for i in range(1,len(actual_close[symbol])):
	        if actual_close[symbol][i-1]>=10 and actual_close[symbol][i] < 10 : # When the actual close of the stock price drops below $5.00
                    enter_day = timestamps[i]
                    if (i+5<len(timestamps)):
                        exit_day=timestamps[i+5]
                    else:
                        exit_day=last_day

		    print str(enter_day.year) + ',' + str(enter_day.month) + ',' + str(enter_day.day) + ',' + symbol + ',' + 'Buy' + ',' + str(nr_shares)
		    print str(exit_day.year) + ',' + str(exit_day.month) + ',' + str(exit_day.day) + ',' + symbol + ',' + 'Sell' + ',' + str(nr_shares)

#################################################
################ MAIN CODE ######################
#################################################


# symbols = np.loadtxt('SP500port.csv',dtype='S10',comments='#', skiprows=1)
dataobj = da.DataAccess('Yahoo')
symbols = dataobj.get_symbols_from_list("sp5002012")

# You might get a message about some files being missing, don't worry about it.

startday = dt.datetime(2008,1,1)
endday = dt.datetime(2009,12,31)
generateTrades(symbols,startday,endday,100)



