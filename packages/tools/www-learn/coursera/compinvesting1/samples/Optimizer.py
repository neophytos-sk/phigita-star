'''
(c) 2011, 2012 Georgia Tech Research Corporation
This source code is released under the New BSD license.  Please see
http://wiki.quantsoftware.org/index.php?title=QSTK_License
for license details.

Created on April 20, 2012

@author: Sourabh Bajaj
@contact: sourabhbajaj@gmail.com
@summary: Demonstrates the use of the CVXOPT portfolio optimization call.

Modified on November 29, 2012 by Harris Butler.  License details remain unchanged.
'''

import qstkutil.qsdateutil as du
import qstkutil.tsutil as tsu
import qstkutil.DataAccess as da
import datetime as dt

import matplotlib.pyplot as plt
from pylab import *
from math import isnan
from copy import copy

'''Modification- load in numpy so we can use masking features and
   matplotlib's transforms'''
import numpy as np
'''End Modification'''

''' Function gets a 100 sample point frontier for given returns '''
def getFrontier(naData):
    ''' Special case for fTarget = None, just get average returns '''
    (naAvgRets,naStd, b_error) = tsu.OptPort( naData, None )

    naLower = np.zeros(naData.shape[1])
    naUpper = np.ones(naData.shape[1])

    (fMin, fMax) = tsu.getRetRange( naData, naLower, naUpper, naAvgRets, s_type="long")
    
    '''Modification- squeeze fMin/fMax to avoid infeasability on the
    upper and lower limits.  These usually manifest with a CVXOPT
    error, and QSTK responds by telling you the KKT matrix is singular
    By avoiding the absolute edges you can eliminate this error'''
    reduce_amount = 0.0001
    fMin += reduce_amount
    fMax -= reduce_amount
    '''End Modification'''

    fStep = (fMax - fMin) / 100.0

    lfReturn =  [fMin + x * fStep for x in range(101)]
    lfStd = []
    lnaPortfolios = []

    ''' Call the function 100 times for the given range '''
    for fTarget in lfReturn:
        (naWeights, fStd, b_error) = tsu.OptPort( naData, fTarget, naLower, naUpper, s_type = "long")
        #if b_error == False:
        lfStd.append(fStd)
        lnaPortfolios.append( naWeights )
        #lfReturn.pop(lfReturn.index(fTarget))
    return (lfReturn, lfStd, lnaPortfolios, naAvgRets, naStd)



''' ******************************************************* '''
''' ******************** MAIN SCRIPT ********************** '''
''' ******************************************************* '''

'''Modification- don't use SP100 stocks, use the entire SP500 from 
   2008 instead.  This will make the optimization take quite a bit 
   longer but I wanted to show you that you can load in a custom 
   list of stocks from a text file. We will use a method from the
   norgateObj to load in our stocks'''
   
#''' S&P100 '''

#lsSymbols = ['AAPL', 'ABT', 'ACN', 'AEP', 'ALL', 'AMGN', 'AMZN', 'APC', 'AXP', 'BA', 'BAC', 'BAX', 'BHI', 'BK', 'BMY', 'BRK.B', 'CAT', 'C', 'CL', 'CMCSA', 'COF', 'COP', 'COST', 'CPB', 'CSCO', 'CVS', 'CVX', 'DD', 'DELL', 'DIS', 'DOW', 'DVN', 'EBAY', 'EMC', 'EXC', 'F', 'FCX', 'FDX', 'GD', 'GE', 'GILD', 'GOOG', 'GS', 'HAL', 'HD', 'HNZ', 'HON', 'HPQ', 'IBM', 'INTC', 'JNJ', 'JPM', 'KFT', 'KO', 'LLY', 'LMT', 'LOW', 'MA', 'MCD', 'MDT', 'MET', 'MMM', 'MO', 'MON', 'MRK', 'MS', 'MSFT', 'NKE', 'NOV', 'NSC', 'NWSA', 'NYX', 'ORCL', 'OXY', 'PEP', 'PFE', 'PG', 'PM', 'QCOM', 'RF', 'RTN', 'SBUX', 'SLB', 'HSH', 'SO', 'SPG', 'T', 'TGT', 'TWX', 'TXN', 'UNH', 'UPS', 'USB', 'UTX', 'VZ', 'WAG', 'WFC', 'WMB', 'WMT', 'XOM']

''' Create norgate object and query it for stock data '''
norgateObj = da.DataAccess('Yahoo')

'''you can find the file sp5002008.txt in this folder: 
   ~/QSTK/QSData/Yahoo/Lists/  If you want to create your own custom
   list of symbols you can, place the file in this folder and change
   the line below to reflect the filename (without the .txt extension)
   '''
lsSymbols = norgateObj.get_symbols_from_list("sp5002008")
'''End Modification'''

lsAll = norgateObj.get_all_symbols()
intersect = set(lsAll) & set(lsSymbols)

if len(intersect) < len(lsSymbols):
    '''Modification- change warning text to say "List" instead of
    "SP100" since we aren't using SP100 anymore'''
    
    print "Warning: List contains symbols that do not exist: ",

    '''End Modification'''
    print set(lsSymbols) - intersect
    lsSymbols = sort(list( intersect ))

''''Read in historical data'''
'''Modification- change year to 2008'''
lYear = 2008
'''End Modification'''
dtEnd = dt.datetime(lYear+1,1,1)
dtStart = dtEnd - dt.timedelta(days=365)
dtTest = dtEnd + dt.timedelta(days=365)
timeofday=dt.timedelta(hours=16)

ldtTimestamps = du.getNYSEdays( dtStart, dtEnd, timeofday )
ldtTimestampTest = du.getNYSEdays( dtEnd, dtTest, timeofday )

dmClose = norgateObj.get_data(ldtTimestamps, lsSymbols, "close")
dmTest = norgateObj.get_data(ldtTimestampTest, lsSymbols, "close")

naData = dmClose.values.copy()
naDataTest = dmTest.values.copy()

tsu.fillforward(naData)
tsu.fillbackward(naData)
tsu.returnize0(naData)

tsu.fillforward(naDataTest)
tsu.fillbackward(naDataTest)
tsu.returnize0(naDataTest)

'''Modification- make the code more robust by masking and removing
   any remaining NaNs that somehow slipped through.  This can
   sometimes happen if you have an entire column of NaNs which means
   there is no information to fill forward or back with. '''
naData = np.ma.masked_invalid(naData)
naData = np.ma.mask_cols(naData)
naDataMask = np.ma.getmask(naData)

naDataTest = np.ma.masked_invalid(naDataTest)
naDataTest = np.ma.mask_cols(naDataTest)
naDataTestMask = np.ma.getmask(naDataTest)

removeCols = []
for column in reversed(range(naDataMask.shape[1])):
    if naDataMask[0,column] or naDataTestMask[0,column]:
        print "Stock " + lsSymbols[column] + " is missing data"
        if type(lsSymbols)=='list':
            del lsSymbols[column]
        else:
            lsSymbols = np.delete(lsSymbols, column)
        removeCols.append(column)

removeCols = list(set(removeCols))
naData = np.delete(naData, removeCols, 1)
naDataTest = np.delete(naDataTest, removeCols, 1)
'''End Modification'''

''' Get efficient frontiers '''
(lfReturn, lfStd, lnaPortfolios, naAvgRets, naStd) = getFrontier( naData)
(lfReturnTest, lfStdTest, unused, unused, unused) = getFrontier( naDataTest)

plt.clf()
fig = plt.figure()
'''Modification- make plot a sub plot so we can reposition it and get
   the legend out of the way- this modification continues everytime
   you see the object "ax" '''
ax = plt.subplot(111)

''' Plot efficient frontiers '''
ax.plot(lfStd,lfReturn, 'b')
ax.plot(lfStdTest,lfReturnTest, 'r')

''' Plot where efficient frontier WOULD be the following year '''
lfRetTest = []
lfStdTest = []
naRetsTest = naDataTest
for naPortWeights in lnaPortfolios:
    naPortRets =  np.dot( naRetsTest, naPortWeights)
    lfStdTest.append( np.std(naPortRets) )
    lfRetTest.append( np.average(naPortRets) )

ax.plot(lfStdTest,lfRetTest,'k')

'''Modification- add the arrows but keep them from taking up too
   much space and get rid of arrow heads because who needs them?'''
''' plot some arrows showing transition of efficient frontier '''
for i in range(0,101,10):
    arrow( lfStd[i],lfReturn[i], lfStdTest[i]-lfStd[i], lfRetTest[i]-lfReturn[i], color='k', width=0.00005, head_width=0.0)
'''End Modification'''

''' Plot indifidual stock risk/return as green + '''
for i, fReturn in enumerate(naAvgRets):
    ax.plot( naStd[i], fReturn, 'g+' )

'''Modification- put the legend outside the graph so it isn't covering
   stuff up, also update some of the text and names'''
# Shink current axis's height by 10% on the bottom
box = ax.get_position()
ax.set_position([box.x0, box.y0 + box.height * 0.2,
                 box.width, box.height * 0.8])

# Put a legend below current axis
ax.legend( ['2008 Frontier', '2009 Frontier', 'Performance of \'08 Frontier in \'09'], loc='upper center', bbox_to_anchor=(0.5, -0.15), fancybox=True, shadow=True, ncol=2)

plt.title('Efficient Frontier For S&P 500 stocks in ' + str(lYear))
plt.ylabel('Expected Return')
plt.xlabel('StDev')

savefig('OptimizerPlot.pdf',format='pdf')
'''End Modification'''

'''Modification- save the symbols, weights, and target returns for
   examination'''
import csv
if type(lsSymbols)=='list':
    Symbols = lsSymbols
else:
    Symbols = lsSymbols.tolist()
Symbols.append('Target Return')
WeightsAndTargetReturns = np.append(lnaPortfolios, np.array(lfReturn).reshape(len(lfReturn),1), axis=1)
outFile = open("OptimizerOutput.csv",'w')
wr = csv.writer(outFile)
wr.writerow(Symbols)
wr.writerows(WeightsAndTargetReturns)
outFile.close()
'''End Modificaion'''








