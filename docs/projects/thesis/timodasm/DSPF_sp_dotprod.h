/* ======================================================================== */
/*  TEXAS INSTRUMENTS, INC.                                                 */
/*                                                                          */
/*  NAME                                                                    */
/*      DSPF_sp_dotprod -- Dot Product of 2 Single Precision float vectors  */
/*                                                                          */
/*  USAGE                                                                   */

/*                                                                          */
/*    This routine is C Callable and can be called as:                      */
/*                                                                          */
/*      float DSPF_sp_dotprod(const float *x, const float *y, const int nx);*/
/*                                                                          */
/*      x     : Pointer to array holding the first floating point vector    */
/*      y     : Pointer to array holding the second floating point vector   */
/*      nx    : Number of values in the x & y vectors                       */
/*                                                                          */
/*                                                                          */
/*  DESCRIPTION                                                             */
/*                                                                          */
/*      This routine calculates the dot product of 2 single precision       */
/*  float vectors.                                                          */
/*                                                                          */
/* ------------------------------------------------------------------------ */
/*            Copyright (c) 2003 Texas Instruments, Incorporated.           */
/*                           All Rights Reserved.                           */
/* ======================================================================== */
#ifndef DSPF_SP_DOTPROD_
#define DSPF_SP_DOTPROD_ 1

float DSPF_sp_dotprod(const float * x, const float * y, const int nx);

#endif
/* ======================================================================== */
/*  End of file: dspf_sp_dotprod.h                                          */
/* ------------------------------------------------------------------------ */
/*          Copyright (C) 2003 Texas Instruments, Incorporated.             */
/*                          All Rights Reserved.                            */
/* ======================================================================== */

