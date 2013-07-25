#
# imports
#
import sys
import numpy as np
import datetime as dt
from pandas import *
import qstkutil.qsdateutil as du
import qstkutil.DataAccess as da
import qstkutil.tsutil as tsu
from pylab import *

start_cash = float64(sys.argv[1])
orders_file = sys.argv[2]
values_file = sys.argv[3]


orders = list(np.sort(np.loadtxt(orders_file,dtype='i,i,i,S100,S100,i',delimiter=',')))

# Build list of symbols and dates
symbols =list(set(map(lambda x: x[3], orders)))
dates = list(set(map(lambda x: dt.datetime(x[0],x[1],x[2]), orders))).sort()


# Set start and end boundary times
syear = orders[0][0]
smonth = orders[0][1]
sday = orders[0][2]

eyear = orders[-1][0]
emonth = orders[-1][1]
eday = orders[-1][2]

tsstart = dt.datetime(syear,smonth,sday,16)
tsend = dt.datetime(eyear,emonth,eday,16)

# 
# Prepare to read the data
#
timeofday = dt.timedelta(hours=16)
timestamps = du.getNYSEdays(tsstart,tsend,timeofday)
dataobj = da.DataAccess('Yahoo')
adjcloses = dataobj.get_data(timestamps, symbols, "close")
#adjcloses = dataobj.get_data(timestamps, symbols, "actual_close")

#
# Completing the Data - Removing the NaN values from the Matrix
#
adjcloses = (adjcloses.fillna()).fillna(method='backfill')


symbols.append('_CASH')
symbols.append('_TOTAL')
vals = zeros(len(symbols))
vals[-2] = start_cash
vals[-1] = start_cash

df_alloc = DataFrame()
prev_day = tsstart - dt.timedelta(days=1)

# Scan orders to update cash
last_i = 0
nr_orders = len(orders)
for day in timestamps:
    for i in range(last_i,nr_orders):    
        order = orders[i]
        order_day = dt.datetime(order[0],order[1],order[2],16)
        if order_day == day:
            last_i = i
            symbol = order[3]
            type = order[4]
            qty = order[5]

            if type=="Buy":
                sign=-1
            else:
                sign=1

            price = adjcloses.ix[day][symbol]
            amount = sign * qty * price 

            index = symbols.index(symbol)
            vals[index] = vals[index] - sign*qty

            # curr_cash = prev_cash+amount
            vals[-2] = vals[-2] + amount

    vals[-1] = vals[-2] + sum(vals[0:-2] * adjcloses.ix[day])
    df_alloc = df_alloc.append(DataFrame(index=[day],columns=symbols,data=[vals]))




df_alloc.to_csv(values_file)

exit()

