
/*************************************************************************
k-means++ clusterization

INPUT PARAMETERS:
    XY          -   dataset, array [0..NPoints-1,0..NVars-1].
    NPoints     -   dataset size, NPoints>=K
    NVars       -   number of variables, NVars>=1
    K           -   desired number of clusters, K>=1
    Restarts    -   number of restarts, Restarts>=1

OUTPUT PARAMETERS:
    Info        -   return code:
                    * -3, if task is degenerate (number of distinct points is
                          less than K)
                    * -1, if incorrect NPoints/NFeatures/K/Restarts was passed
                    *  1, if subroutine finished successfully
    C           -   array[0..NVars-1,0..K-1].matrix whose columns store
                    cluster's centers
    XYC         -   array[NPoints], which contains cluster indexes

  -- ALGLIB --
     Copyright 21.03.2009 by Bochkanov Sergey
*************************************************************************/
void kmeansgenerate(/* Real    */ ae_matrix* xy,
     ae_int_t npoints,
     ae_int_t nvars,
     ae_int_t k,
     ae_int_t restarts,
     ae_int_t* info,
     /* Real    */ ae_matrix* c,
     /* Integer */ ae_vector* xyc,
     ae_state *_state)
{
    ae_frame _frame_block;
    ae_int_t i;
    ae_int_t j;
    ae_matrix ct;
    ae_matrix ctbest;
    ae_vector xycbest;
    double e;
    double ebest;
    ae_vector x;
    ae_vector tmp;
    ae_vector d2;
    ae_vector p;
    ae_vector csizes;
    ae_vector cbusy;
    double v;
    ae_int_t cclosest;
    double dclosest;
    ae_vector work;
    ae_bool waschanges;
    ae_bool zerosizeclusters;
    ae_int_t pass;

    ae_frame_make(_state, &_frame_block);
    *info = 0;
    ae_matrix_clear(c);
    ae_vector_clear(xyc);
    ae_matrix_init(&ct, 0, 0, DT_REAL, _state, ae_true);
    ae_matrix_init(&ctbest, 0, 0, DT_REAL, _state, ae_true);
    ae_vector_init(&xycbest, 0, DT_INT, _state, ae_true);
    ae_vector_init(&x, 0, DT_REAL, _state, ae_true);
    ae_vector_init(&tmp, 0, DT_REAL, _state, ae_true);
    ae_vector_init(&d2, 0, DT_REAL, _state, ae_true);
    ae_vector_init(&p, 0, DT_REAL, _state, ae_true);
    ae_vector_init(&csizes, 0, DT_INT, _state, ae_true);
    ae_vector_init(&cbusy, 0, DT_BOOL, _state, ae_true);
    ae_vector_init(&work, 0, DT_REAL, _state, ae_true);

    
    /*
     * Test parameters
     */
    if( ((npoints<k||nvars<1)||k<1)||restarts<1 )
    {
        *info = -1;
        ae_frame_leave(_state);
        return;
    }
    
    /*
     * TODO: special case K=1
     * TODO: special case K=NPoints
     */
    *info = 1;
    
    /*
     * Multiple passes of k-means++ algorithm
     */
    ae_matrix_set_length(&ct, k, nvars, _state);
    ae_matrix_set_length(&ctbest, k, nvars, _state);
    ae_vector_set_length(xyc, npoints, _state);
    ae_vector_set_length(&xycbest, npoints, _state);
    ae_vector_set_length(&d2, npoints, _state);
    ae_vector_set_length(&p, npoints, _state);
    ae_vector_set_length(&tmp, nvars, _state);
    ae_vector_set_length(&csizes, k, _state);
    ae_vector_set_length(&cbusy, k, _state);
    ebest = ae_maxrealnumber;
    for(pass=1; pass<=restarts; pass++)
    {
        
        /*
         * Select initial centers  using k-means++ algorithm
         * 1. Choose first center at random
         * 2. Choose next centers using their distance from centers already chosen
         *
         * Note that for performance reasons centers are stored in ROWS of CT, not
         * in columns. We'll transpose CT in the end and store it in the C.
         */
        i = ae_randominteger(npoints, _state);
        ae_v_move(&ct.ptr.pp_double[0][0], 1, &xy->ptr.pp_double[i][0], 1, ae_v_len(0,nvars-1));
        cbusy.ptr.p_bool[0] = ae_true;
        for(i=1; i<=k-1; i++)
        {
            cbusy.ptr.p_bool[i] = ae_false;
        }
        if( !kmeans_selectcenterpp(xy, npoints, nvars, &ct, &cbusy, k, &d2, &p, &tmp, _state) )
        {
            *info = -3;
            ae_frame_leave(_state);
            return;
        }
        
        /*
         * Update centers:
         * 2. update center positions
         */
        for(i=0; i<=npoints-1; i++)
        {
            xyc->ptr.p_int[i] = -1;
        }
        for(;;)
        {
            
            /*
             * fill XYC with center numbers
             */
            waschanges = ae_false;
            for(i=0; i<=npoints-1; i++)
            {
                cclosest = -1;
                dclosest = ae_maxrealnumber;
                for(j=0; j<=k-1; j++)
                {
                    ae_v_move(&tmp.ptr.p_double[0], 1, &xy->ptr.pp_double[i][0], 1, ae_v_len(0,nvars-1));
                    ae_v_sub(&tmp.ptr.p_double[0], 1, &ct.ptr.pp_double[j][0], 1, ae_v_len(0,nvars-1));
                    v = ae_v_dotproduct(&tmp.ptr.p_double[0], 1, &tmp.ptr.p_double[0], 1, ae_v_len(0,nvars-1));
                    if( ae_fp_less(v,dclosest) )
                    {
                        cclosest = j;
                        dclosest = v;
                    }
                }
                if( xyc->ptr.p_int[i]!=cclosest )
                {
                    waschanges = ae_true;
                }
                xyc->ptr.p_int[i] = cclosest;
            }
            
            /*
             * Update centers
             */
            for(j=0; j<=k-1; j++)
            {
                csizes.ptr.p_int[j] = 0;
            }
            for(i=0; i<=k-1; i++)
            {
                for(j=0; j<=nvars-1; j++)
                {
                    ct.ptr.pp_double[i][j] = 0;
                }
            }
            for(i=0; i<=npoints-1; i++)
            {
                csizes.ptr.p_int[xyc->ptr.p_int[i]] = csizes.ptr.p_int[xyc->ptr.p_int[i]]+1;
                ae_v_add(&ct.ptr.pp_double[xyc->ptr.p_int[i]][0], 1, &xy->ptr.pp_double[i][0], 1, ae_v_len(0,nvars-1));
            }
            zerosizeclusters = ae_false;
            for(i=0; i<=k-1; i++)
            {
                cbusy.ptr.p_bool[i] = csizes.ptr.p_int[i]!=0;
                zerosizeclusters = zerosizeclusters||csizes.ptr.p_int[i]==0;
            }
            if( zerosizeclusters )
            {
                
                /*
                 * Some clusters have zero size - rare, but possible.
                 * We'll choose new centers for such clusters using k-means++ rule
                 * and restart algorithm
                 */
                if( !kmeans_selectcenterpp(xy, npoints, nvars, &ct, &cbusy, k, &d2, &p, &tmp, _state) )
                {
                    *info = -3;
                    ae_frame_leave(_state);
                    return;
                }
                continue;
            }
            for(j=0; j<=k-1; j++)
            {
                v = (double)1/(double)csizes.ptr.p_int[j];
                ae_v_muld(&ct.ptr.pp_double[j][0], 1, ae_v_len(0,nvars-1), v);
            }
            
            /*
             * if nothing has changed during iteration
             */
            if( !waschanges )
            {
                break;
            }
        }
        
        /*
         * 3. Calculate E, compare with best centers found so far
         */
        e = 0;
        for(i=0; i<=npoints-1; i++)
        {
            ae_v_move(&tmp.ptr.p_double[0], 1, &xy->ptr.pp_double[i][0], 1, ae_v_len(0,nvars-1));
            ae_v_sub(&tmp.ptr.p_double[0], 1, &ct.ptr.pp_double[xyc->ptr.p_int[i]][0], 1, ae_v_len(0,nvars-1));
            v = ae_v_dotproduct(&tmp.ptr.p_double[0], 1, &tmp.ptr.p_double[0], 1, ae_v_len(0,nvars-1));
            e = e+v;
        }
        if( ae_fp_less(e,ebest) )
        {
            
            /*
             * store partition.
             */
            ebest = e;
            copymatrix(&ct, 0, k-1, 0, nvars-1, &ctbest, 0, k-1, 0, nvars-1, _state);
            for(i=0; i<=npoints-1; i++)
            {
                xycbest.ptr.p_int[i] = xyc->ptr.p_int[i];
            }
        }
    }
    
    /*
     * Copy and transpose
     */
    ae_matrix_set_length(c, nvars-1+1, k-1+1, _state);
    copyandtranspose(&ctbest, 0, k-1, 0, nvars-1, c, 0, nvars-1, 0, k-1, _state);
    for(i=0; i<=npoints-1; i++)
    {
        xyc->ptr.p_int[i] = xycbest.ptr.p_int[i];
    }
    ae_frame_leave(_state);
}


/*************************************************************************
Select center for a new cluster using k-means++ rule
*************************************************************************/
static ae_bool kmeans_selectcenterpp(/* Real    */ ae_matrix* xy,
     ae_int_t npoints,
     ae_int_t nvars,
     /* Real    */ ae_matrix* centers,
     /* Boolean */ ae_vector* busycenters,
     ae_int_t ccnt,
     /* Real    */ ae_vector* d2,
     /* Real    */ ae_vector* p,
     /* Real    */ ae_vector* tmp,
     ae_state *_state)
{
    ae_frame _frame_block;
    ae_vector _busycenters;
    ae_int_t i;
    ae_int_t j;
    ae_int_t cc;
    double v;
    double s;
    ae_bool result;

    ae_frame_make(_state, &_frame_block);
    ae_vector_init_copy(&_busycenters, busycenters, _state, ae_true);
    busycenters = &_busycenters;

    result = ae_true;
    for(cc=0; cc<=ccnt-1; cc++)
    {
        if( !busycenters->ptr.p_bool[cc] )
        {
            
            /*
             * fill D2
             */
            for(i=0; i<=npoints-1; i++)
            {
                d2->ptr.p_double[i] = ae_maxrealnumber;
                for(j=0; j<=ccnt-1; j++)
                {
                    if( busycenters->ptr.p_bool[j] )
                    {
                        ae_v_move(&tmp->ptr.p_double[0], 1, &xy->ptr.pp_double[i][0], 1, ae_v_len(0,nvars-1));
                        ae_v_sub(&tmp->ptr.p_double[0], 1, &centers->ptr.pp_double[j][0], 1, ae_v_len(0,nvars-1));
                        v = ae_v_dotproduct(&tmp->ptr.p_double[0], 1, &tmp->ptr.p_double[0], 1, ae_v_len(0,nvars-1));
                        if( ae_fp_less(v,d2->ptr.p_double[i]) )
                        {
                            d2->ptr.p_double[i] = v;
                        }
                    }
                }
            }
            
            /*
             * calculate P (non-cumulative)
             */
            s = 0;
            for(i=0; i<=npoints-1; i++)
            {
                s = s+d2->ptr.p_double[i];
            }
            if( ae_fp_eq(s,0) )
            {
                result = ae_false;
                ae_frame_leave(_state);
                return result;
            }
            s = 1/s;
            ae_v_moved(&p->ptr.p_double[0], 1, &d2->ptr.p_double[0], 1, ae_v_len(0,npoints-1), s);
            
            /*
             * choose one of points with probability P
             * random number within (0,1) is generated and
             * inverse empirical CDF is used to randomly choose a point.
             */
            s = 0;
            v = ae_randomreal(_state);
            for(i=0; i<=npoints-1; i++)
            {
                s = s+p->ptr.p_double[i];
                if( ae_fp_less_eq(v,s)||i==npoints-1 )
                {
                    ae_v_move(&centers->ptr.pp_double[cc][0], 1, &xy->ptr.pp_double[i][0], 1, ae_v_len(0,nvars-1));
                    busycenters->ptr.p_bool[cc] = ae_true;
                    break;
                }
            }
        }
    }
    ae_frame_leave(_state);
    return result;
}
