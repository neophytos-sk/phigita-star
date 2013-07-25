adjustOHLC <-
function(x, 
         adjust=c("split","dividend"), 
         use.Adjusted=FALSE, 
         ratio=NULL, symbol.name=deparse(substitute(x))) 
{
  if(is.null(ratio)) {
    if(use.Adjusted) {
      # infer from Yahoo! Ajusted column
      if(!has.Ad(x))
        stop("no Adjusted column in 'x'")
      ratio <- Ad(x)/Cl(x)
    } else {
      # use actual split and/or dividend data
      div    <- getDividends(symbol.name)
      splits <- getSplits(symbol.name)
      ratios <- adjRatios(splits, div, Cl(x))
      if(length(adjust)==1 && adjust == "split") {
        ratio <- ratios[,1]
      } else if(length(adjust)==1 && adjust == "dividend") {
        ratio <- ratios[,2]
      } else ratio <- ratios[,1] * ratios[,2]
    }
  }
  Adjusted <- Cl(x) * ratio
  structure(
    cbind((ratio * (Op(x)-Cl(x)) + Adjusted),
          (ratio * (Hi(x)-Cl(x)) + Adjusted),
          (ratio * (Lo(x)-Cl(x)) + Adjusted),
          Adjusted,
          if(has.Vo(x)) Vo(x) else NULL,
          if(has.Ad(x)) Ad(x) else NULL
         ),
       .Dimnames=list(NULL, colnames(x)))
}




SEXP adjRatios (SEXP split, SEXP div, SEXP close) {

    /* Initialize REAL pointers to function arguments */
    double *real_close = REAL(close);
    double *real_split = REAL(split);
    double *real_div   = REAL(div);
    
    /* Initalize loop and PROTECT counters */
    int i, P = 0;
    /* Initalize object length (NOTE: all arguments are the same length) */
    int N = length(close);

    /* Initalize result R objects */
    SEXP result;    PROTECT(result  = allocVector(VECSXP, 2)); P++;
    SEXP s_ratio;   PROTECT(s_ratio = allocVector(REALSXP,N)); P++;
    SEXP d_ratio;   PROTECT(d_ratio = allocVector(REALSXP,N)); P++;
    
    /* Initialize REAL pointers to R objects and set their last value to '1' */
    double *rs_ratio = REAL(s_ratio);
    double *rd_ratio = REAL(d_ratio);
    rs_ratio[N-1] = 1;
    rd_ratio[N-1] = 1;

    /* Loop over split/div vectors from newest period to oldest */
    for(i = N-1; i > 0; i--) {
        /* Carry newer ratio value backward */
        if(ISNA(real_split[i])) {
            rs_ratio[i-1] = rs_ratio[i];
        /* Update split ratio */
        } else {
            rs_ratio[i-1] = rs_ratio[i] * real_split[i];
        }
        /* Carry newer ratio value backward */
        if(ISNA(real_div[i])) {
            rd_ratio[i-1] = rd_ratio[i];
        } else {
        /* Update dividend ratio */
            rd_ratio[i-1] = rd_ratio[i] *
                (1.0 - real_div[i] / real_close[i-1]);
        }
    }
    
    /* Assign results to list */
    SET_VECTOR_ELT(result, 0, s_ratio);
    SET_VECTOR_ELT(result, 1, d_ratio);

    /* UNPROTECT R objects and return result */
    UNPROTECT(P);
    return(result);
}
