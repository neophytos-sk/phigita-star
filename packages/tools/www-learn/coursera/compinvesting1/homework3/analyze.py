#
# imports
#
import sys
import numpy as np
import datetime as dt
import qstkutil.qsdateutil as du
import qstkutil.DataAccess as da
import qstkutil.tsutil as tsu
import matplotlib.pyplot as plt
from pylab import *
import pandas

[_,values_file,benchmark] = sys.argv
symbols = [benchmark]
#values = np.loadtxt(values_file,dtype='S100,i,i,i,i,i,i',delimiter=',',skiprows=1)
values = np.genfromtxt(values_file,delimiter=',',skiprows=1, converters={0: lambda s: str(s)})


# Set start and end boundary times
t = map(int,values[0][0].split(' ')[0].split('-'))
startday = dt.datetime(t[0],t[1],t[2],16)
t = map(int,values[-1][0].split(' ')[0].split('-'))
endday = dt.datetime(t[0],t[1],t[2],16)

#
# Prepare to read data
#
timeofday = dt.timedelta(hours=16)
timestamps = du.getNYSEdays(startday,endday,timeofday)
dataobj = da.DataAccess('Yahoo')
close = dataobj.get_data(timestamps,symbols,"actual_close")


#
# Copy, prep, and compute daily returns
#

fund_rets = [float64(row[-1]) for row in values]
tsu.returnize0(fund_rets)


fund_annual_return = fund_rets[-1]/fund_rets[0] - 1.0
fund_stdev_daily_ret = np.std(fund_rets)
fund_avg_daily_ret = np.average(fund_rets)
fund_sharpe_ratio = sqrt(len(timestamps)*(fund_avg_daily_ret/fund_stdev_daily_ret))

benchmark_rets = close.values.copy()
tsu.fillforward(benchmark_rets)
tsu.returnize0(benchmark_rets)

benchmark_annual_return = close.ix[endday]/close.ix[startday] - 1
benchmark_stdev_daily_ret = np.std(benchmark_rets) 
benchmark_avg_daily_ret = np.average(benchmark_rets)
benchmark_sharpe_ratio = sqrt(len(timestamps))*(benchmark_avg_daily_ret/benchmark_stdev_daily_ret)

print "Fund Annual Ret: ", fund_annual_return
print "Fund Avg Daily Ret: ", fund_avg_daily_ret
print "Fund STDEV Daily Ret: ", fund_stdev_daily_ret
print "Fund Sharpe Ratio: ", fund_sharpe_ratio

print "Benchmark Annual Ret: ", benchmark_annual_return
print "Benchmark Avg Daily Ret: ", benchmark_avg_daily_ret
print "Benchmark STDEV Daily Ret: ", benchmark_stdev_daily_ret
print "Benchmark Sharpe Ratio: ", benchmark_sharpe_ratio

#
# Plot the fund values
#

start_cash = values[0][-1]
mult = start_cash / close.values[0]
plt.clf()
plt.plot(close.index, close.values * mult, label = benchmark)
plt.plot(close.index, [row[-1] for row in values], label = 'my_fund')
plt.legend()
plt.ylabel('Fund Value')
plt.xlabel('Date')
locs,labels = plt.xticks()
plt.setp(labels,rotation=30)
savefig('fund-chart.pdf',format='pdf')
