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
Returns the Event Matrix which is a pandas Datamatrix
Event matrix has the following structure :
    |IBM |GOOG|XOM |MSFT| GS | JP |
(d1)|nan |nan | 1  |nan |nan | 1  |
(d2)|nan | 1  |nan |nan |nan |nan |
(d3)| 1  |nan | 1  |nan | 1  |nan |
(d4)|nan |  1 |nan | 1  |nan |nan |
...................................
...................................
Also, d1 = start date
nan = no information about any event.
1 = status bit(positively confirms the event occurence)
"""

# Get the data from the data store
storename = "Yahoo" # get data from our daily prices source
# Available field names: open, close, high, low, close, actual_close, volume
closefield = "actual_close"
volumefield = "volume"
window = 10

def findEvents(symbols, startday,endday, marketSymbol,verbose=False):

	# Reading the Data for the list of Symbols.	
	timeofday=dt.timedelta(hours=16)
	timestamps = du.getNYSEdays(startday,endday,timeofday)

	dataobj = da.DataAccess('Yahoo')
	if verbose:
            print __name__ + " reading data"

	# Reading the Data
	actual_close = dataobj.get_data(timestamps, symbols, closefield)
	
	# Completing the Data - Removing the NaN values from the Matrix
	actual_close = (actual_close.fillna(method='ffill')).fillna(method='backfill')
	
	np_eventmat = copy.deepcopy(actual_close)
	for sym in symbols:
		for time in timestamps:
			np_eventmat[sym][time]=np.NAN

	if verbose:
            print __name__ + " finding events"

	# Generating the Event Matrix
	# Event described is : Market falls more than 3% plus the stock falls 5% more than the Market
	# Suppose : The market fell 3%, then the stock should fall more than 8% to mark the event.
	# And if the market falls 5%, then the stock should fall more than 10% to mark the event.

	for symbol in symbols:
		
	    for i in range(1,len(actual_close[symbol])):
	        if actual_close[symbol][i-1]>=7 and actual_close[symbol][i] < 7 : # When the actual close of the stock price drops below $5.00
             		np_eventmat[symbol][i] = 1.0  #overwriting by the bit, marking the event
			
	return np_eventmat


#################################################
################ MAIN CODE ######################
#################################################


# symbols = np.loadtxt('SP500port.csv',dtype='S10',comments='#', skiprows=1)
dataobj = da.DataAccess('Yahoo')
symbols = dataobj.get_symbols_from_list("sp5002012")
#symbols = dataobj.get_symbols_from_list("sp5002008")
symbols.append('SPY')

#symbols =['BFRE','ATCS','RSERF','GDNEF','LAST','ATTUF','JBFCF','CYVA','SPF','XPO','EHECF','TEMO','AOLS','CSNT','REMI','GLRP','AIFLY','BEE','DJRT','CHSTF','AICAF']
# You might get a message about some files being missing, don't worry about it.

startday = dt.datetime(2008,1,1)
endday = dt.datetime(2009,12,31)
eventMatrix = findEvents(symbols,startday,endday,marketSymbol='SPY',verbose=True)

eventProfiler = ep.EventProfiler(eventMatrix,startday,endday,lookback_days=20,lookforward_days=20,verbose=True)

eventProfiler.study(filename="MyEventStudy-HW2.pdf",plotErrorBars=True,plotMarketNeutral=True,plotEvents=False,marketSymbol='SPY')


