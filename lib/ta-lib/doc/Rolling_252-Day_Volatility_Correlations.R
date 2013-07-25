
require(quantmod)

# pull SPX data from Yahoo Finance
getSymbols("^GSPC",from="1970-01-01")

# volatility horizons
GSPC$v2 <- runSD(ROC(Cl(GSPC)),2)
GSPC$v5 <- runSD(ROC(Cl(GSPC)),5)
GSPC$v10 <- runSD(ROC(Cl(GSPC)),10)
GSPC$v21 <- runSD(ROC(Cl(GSPC)),21)
GSPC$v63 <- runSD(ROC(Cl(GSPC)),63)
GSPC$v252 <- runSD(ROC(Cl(GSPC)),252)

# volatility horizon lags
GSPC$l2 <- lag(GSPC$v2,-2)
GSPC$l5 <- lag(GSPC$v5,-5)
GSPC$l10 <- lag(GSPC$v10,-10)
GSPC$l21 <- lag(GSPC$v21,-21)
GSPC$l63 <- lag(GSPC$v63,-63)
GSPC$l252 <- lag(GSPC$v252,-252)

# volatility correlation table
cor(GSPC[,7:18],use="pair")[1:6,7:12]

# remove missing observations
GSPC <- na.omit(GSPC)

# rolling 1-year volatility correlations
GSPC$c2 <- runCor(GSPC$v2,GSPC$l2,252)
GSPC$c5 <- runCor(GSPC$v5,GSPC$l5,252)
GSPC$c10 <- runCor(GSPC$v10,GSPC$l10,252)
GSPC$c21 <- runCor(GSPC$v21,GSPC$l21,252)
GSPC$c63 <- runCor(GSPC$v63,GSPC$l63,252)
GSPC$c252 <- runCor(GSPC$v252,GSPC$l252,252)

# plot rolling 1-year volatility correlations
plot.zoo(GSPC[,grep("c",colnames(GSPC))],n=1,
 main="Rolling 252-Day Volitility Correlations")
