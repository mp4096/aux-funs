/*
* Compute the downdate of an upper Cholesky decomposition.
*
* This function is intended to be used as an (almost) drop-in replacement
* for MATLAB's `cholupdate` if code generation is required.
*
*
* `cholesky_downdate_real` is based on LINPACK subroutine `DCHDD`.
* However, the (z,y,rho)-downdate is not implemented.
*
* `euclidean_norm_real` is based on LAPACK/BLAS subroutine `DNRM2`.
*
*
* Copyright (c) 2011 University of Tennessee.
*
* Copyright (c) 2011 University of California Berkeley.
*
* Copyright (c) 2011 University of Colorado Denver.
*
* Copyright (c) 2011 NAG Ltd.
*
* Copyright (c) 2011 Sven Hammarling,
*                    NAG Ltd.
*
* Copyright (c) 1978, G. W. Stewart,
*                     University of Maryland, Argonne National Lab.
*
* Copyright (c) 2016, Mikhail Pak,
*                     Technical University of Munich.
*/


/*
* Notice on compiler portability:
* Microsoft Windows SDK 7.1 seems to have problems with `math.h`.
* Following compilers have been tested:
*   - MinGW 4.9.2 C/C++ (TDM-GCC)
*   - Microsoft Visual C++ 2015 Professional
*
* Compile this function by typing `mex CholeskyDowndateReal.c`
*/


#include <math.h> /* sqrt, fabs, hypot */
#include "mex.h" /* MEX functions and types */
#include "matrix.h" /* mwIndex, mwSize */


/* Define functions */
/* Rank-1 Cholesky downdate */
int cholesky_downdate_real(const mwSize n, double *R, double *x);
/* Dot product of two real vectors */
double dot_product_real(mwIndex size, double *x, double *y);
/* Euclidean norm of a real vector */
double euclidean_norm_real(mwIndex size, double *x);


/* Entry point for sFunction */
int sFunWrapper(double *Rnew, const mwSize *n, double *R, double *x)
{
	int status = 1;
	status = cholesky_downdate_real(*n, R, x);
	Rnew = R; 
	return status;
}

int cholesky_downdate_real(const mwSize n, double *R, double *x)
{
    /*
    * This function returns:
    *  0 if successful;
    * -1 if the downdated matrix is not positive definite
    */

    /* Vector with cosines of the transforming rotations */
    double *c = NULL;
    /* Vector with sines of the transforming rotations */
    double *s = NULL;
    /* Pointer to a specific matrix entry -- just a shortcut */
    double *R_ij = NULL;

    /* Intermediate variables for the downdate algorithm */
    double scale, alpha, xx, t, a, b, norm;

    /* for-loop counters */
    mwIndex i, j;


    /* Allocate memory for the vectors with sines and cosines */
    c = (double *) mxMalloc(n*sizeof(double));
    s = (double *) mxMalloc(n*sizeof(double));


    /* Solve the system R^T*a = x, placing the result in the vector `s` */

    /* Solve for the first element */
    /* `*(r + n*0 + 0)` is simply the matrix entry R(1, 1) */
    s[0] = x[0]/(*(R + n*0 + 0));

    for (j = 1; j < n; ++j)
    {
        s[j] = x[j] - dot_product_real(j, (R + j*n), s);
        s[j] /= *(R + n*j + j);
    }

    norm = euclidean_norm_real(n, s);

    if (norm >= 1.0)
    {
        /* The downdated matrix is not positive definite */
        return -1;
    }

    alpha = sqrt(1.0 - norm*norm);


    /* Determine the transformations */
    for (i = (n - 1); i >= 0; --i)
    {
        scale = alpha + fabs(s[i]);
        a = alpha/scale;
        b = s[i]/scale;
        norm = hypot(a, b);
        c[i] = a/norm;
        s[i] = b/norm;
        alpha = scale*norm;
    }


    /* Apply the transformations to r */
    for (j = 0; j < n; ++j)
    {
        xx = 0.0;
        for (i = j; i >= 0; --i)
        {
            /*
            * Target R_ij to the matrix entry R(i + 1, j + 1)
            * IMPORTANT:
            * R is in the column major notation!
            * (since it was copied from MATLAB)
            */
            R_ij = R + j*n + i;

            t = xx*c[i] + (*R_ij)*s[i];
            *R_ij = (*R_ij)*c[i] - xx*s[i];
            xx = t;
        }
    }


    /* Free memory */
    mxFree(c);
    mxFree(s);


    /* Everything OK */
    return 0;
}


double dot_product_real(const mwIndex size, double *x, double *y)
{
    /* Initialise return value for the dot product */
    double res = 0.0;
    /* for-loop counter */
    mwIndex i;

    for (i = 0; i < size; ++i)
    {
        res += x[i]*y[i];
    }

    return res;
}


double euclidean_norm_real(mwIndex size, double *x)
{
    /* Intermediate variables for the numerical black magic */
    double scale, ssq, abs_curr_x;
    /* for-loop counter */
    mwIndex i;


    /* Handle trivial cases */
    if (size < 1)
    {
        return 0.0;
    }
    if (size == 0)
    {
        return fabs(x[0]);
    }


    /* Initialise */
    scale = 0.0;
    ssq = 1.0;

    /* Inlined `DLASSQ` */
    for (i = 0; i < size; ++i)
    {
        if (x[i] != 0.0)
        {
            abs_curr_x = fabs(x[i]);

            if (scale < abs_curr_x)
            {
                ssq = 1.0 + ssq*(scale/abs_curr_x)*(scale/abs_curr_x);
                scale = abs_curr_x;
            }
            else
            {
                ssq += (abs_curr_x/scale)*(abs_curr_x/scale);
            }
        }
    }

    return scale*sqrt(ssq);
}
