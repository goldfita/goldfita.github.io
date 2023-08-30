* ======================================================================= *
*  TEXAS INSTRUMENTS, INC.                                                *
*                                                                         *
*  NAME                                                                   *
*      DSPF_sp_dotprod -- Dot Product of 2 Single Precision float vector  *
*                                                                         *
*   USAGE                                                                 *  
*                                                                         *  
*     This routine is C Callable and can be called as:                    *  
*                                                                         *  
*       float DSPF_sp_dotprod(const float *x, const float *y,             *
*                             const int nx);                              *  
*                                                                         *  
*       x     : Pointer to array holding the first floating point vector  *  
*       y     : Pointer to array holding the second floating point vector *  
*       nx    : Number of values in the x & y vectors                     *  
*                                                                         *  
*                                                                         *  
*   DESCRIPTION                                                           *  
*                                                                         *  
*       This routine calculates the dot product of 2 single precision     *  
*   float vectors.                                                        *  
*                                                                         *  
*   TECHNIQUES                                                            *  
*                                                                         *  
*       1.  LDDW instructions are used to load two SP floating point      *  
*           values at a time for the x and y arrays.                      *  
*       2.  The loop is unrolled once and software pipelined.             *  
*           However, by conditionally adding to the dot product           *  
*           odd numbered array sizes are also permitted.                  *  
*       3.  Since the ADDSP and MPYSP instructions take 4 cycles,         *  
*           A8, B8, A0, and B0 multiplex different variables to save      *  
*           on register usage.                                            *  
*           This multiple assignment is possible since the variables      *  
*           are always read just once on the first cycle that they        *  
*           are available.                                                *  
*       4.  The loop is primed to reduce the prolog by 4 cycles           *  
*           (14 words) with no increase in cycle time.                    *  
*       5.  The load counter is used as the loop counter which            *  
*           requires a 3 cycle (6 word) epilog to finish the              *  
*           calculations. This does not increase the cycle time.          *  
*                                                                         *  
*   ASSUMPTIONS                                                           *  
*                                                                         *  
*       1.  The x and y arrays must be double word aligned.               *  
*       2.  A memory pad of 4 bytes is required at the end of each        *  
*           array if the number of inputs is odd.                         *  
*       3.  The value of nx must be > 0.                                  *  
*                                                                         *  
*   C CODE                                                                *  
*       This is the C equivalent for the assembly code.  Note that        *  
*       the assembly code is hand optimized and restrictions may          *  
*       apply.                                                            *  
*                                                                         *  
*     float DSPF_sp_dotprod(const float *x, const float *y, const int nx) *  
*       {                                                                 *  
*          int i;                                                         *  
*          float sum = 0;                                                 *  
*                                                                         *  
*          for (i=0; i < nx; i++)                                         *  
*          {                                                              *  
*             sum += x[i]* y[i];                                          *  
*          }                                                              *  
*          return sum;                                                    *  
*       }                                                                 *  
*                                                                         *  
*   NOTES                                                                 *  
*                                                                         *  
*   1. Endian: This code is LITTLE ENDIAN.                                *  
*   2. Interruptibility: This code is interrupt tolerant but not          *  
*      interruptible.                                                     *  
*                                                                         *  
*   CYCLES                                                                *  
*                                                                         *  
*      nx/2 + 25                                                          *  
*      eg. for nx = 512, cycles = 281                                     *  
*                                                                         *  
*   CODESIZE                                                              *  
*      256 bytes                                                          *  
* ----------------------------------------------------------------------- *
*            Copyright (c) 2003 Texas Instruments, Incorporated.          *
*                           All Rights Reserved.                          *
* ======================================================================= *

                .global _DSPF_sp_dotprod

_DSPF_sp_dotprod:

* =============== SYMBOLIC REGISTER ASSIGNMENT ============================*

                .asg A6,            A_cntarg
                .asg A1,            A_cnt
                .asg B2,            B_cntodd
                .asg A4,            A_x
                .asg B4,            B_x
                .asg A7,            A_x1
                .asg A6,            A_x0
                .asg B7,            B_x1
                .asg B6,            B_x0
                .asg A8,            sum0
                .asg B8,            sum1
                .asg A5,            prod0
                .asg B5,            prod1
                .asg A0,            A_sum10
                .asg B0,            B_sum10
                .asg A5,            A_finalh
                .asg B5,            B_finalh
                .asg A4,            A_return
                
**************************** Prolog Begins**********************************
              MV             A_cntarg,  A_cnt                  
||            AND            A_cntarg,  1,    B_cntodd ; is cnt even or odd?

     
              ZERO  .L2     prod1                   ; prod1 = 0
||[A_cnt]     LDDW  .D1     *A_x++,      A_x1:A_x0  ; load x1:x0 from memory
||[A_cnt]     LDDW  .D2     *B_x++,      B_x1:B_x0  ; load y1:y0 from memory
||[A_cnt]     B     .S2     LOOP                    ; branch to loop
||[B_cntodd]  SUB   .S1     A_cnt,       1,    A_cnt        
||[!B_cntodd] SUB   .L1     A_cnt,       2,    A_cnt        

              ZERO  .L1     sum0                    ; sum0 = 0
||            ZERO  .L2     sum1                    ; sum1 = 0
||[A_cnt] LDDW      .D1     *A_x++,      A_x1:A_x0  ; load x1:x0 from memory
||[A_cnt] LDDW      .D2     *B_x++,      B_x1:B_x0  ; load y1:y0 from memory
||[A_cnt] B         .S2     LOOP                    ; branch to loop
||[A_cnt] SUB       .S1     A_cnt,       2,    A_cnt        

  [A_cnt] LDDW   .D1        *A_x++,      A_x1:A_x0  ; load x1:x0 from memory
||[A_cnt] LDDW   .D2        *B_x++,      B_x1:B_x0  ; load y1:y0 from memory
||[A_cnt] B      .S2        LOOP                    ; branch to loop
||[A_cnt] SUB    .S1        A_cnt,         2,  A_cnt        
||        ZERO   .L1        prod0                   ; prod0 = 0
         
  [A_cnt] LDDW   .D1        *A_x++,      A_x1:A_x0  ; load x1:x0 from memory
||[A_cnt] LDDW   .D2        *B_x++,      B_x1:B_x0  ; load y1:y0 from memory
||[A_cnt] B      .S1        LOOP                    ; branch to loop
||[A_cnt] SUB    .L1        A_cnt,         2,  A_cnt        

  [A_cnt] LDDW   .D1        *A_x++,      A_x1:A_x0  ; load x1:x0 from memory
||[A_cnt] LDDW   .D2        *B_x++,      B_x1:B_x0  ; load y1:y0 from memory
||[A_cnt] B      .S2        LOOP                    ; branch to loop
||[A_cnt] SUB    .S1        A_cnt,         2,  A_cnt        

****** Loop Begins *****************************
LOOP:

  [A_cnt] LDDW   .D1        *A_x++,      A_x1:A_x0  ; if(lcntr) load x1:x0 from memory
||[A_cnt] LDDW   .D2        *B_x++,      B_x1:B_x0  ; if(lcntr) load y1:y0 from memory
||     MPYSP     .M1X       A_x0,        B_x0, prod0; prod0 = x0 * y0
||     MPYSP     .M2X       A_x1,        B_x1, prod1; prod1 = x1 * y1
||     ADDSP     .L1        prod0,       sum0, sum0 ; sum0 = prod0 + sum0
||     ADDSP     .L2        prod1,       sum1, sum1 ; sum1 = prod1 + sum1
||[A_cnt] B      .S2        LOOP                    ; if(lcntr) branch to loop
||[A_cnt] SUB    .S1        A_cnt,       2,    A_cnt; if(lcntr) lcntr -= 2

********************** Epilog Begins ****************      
 
       ADDSP  .L1     prod0,         sum0,       sum0; sum0 = prod0 + sum0
||     ADDSP  .L2     prod1,         sum1,       sum1; sum1 = prod1 + sum1

       ADDSP  .L1     prod0,         sum0,       sum0; sum0 = prod0 + sum0
||     ADDSP  .L2     prod1,         sum1,       sum1; sum1 = prod1 + sum1

       ADDSP  .L1     prod0,         sum0,       sum0; sum0 = prod0 + sum0
||[!B_cntodd]ADDSP  .L2     prod1,   sum1,       B9  ; sum1 = prod1 + sum1
||[B_cntodd] MV     .D2     sum1,                B9                  

*********************** Epilog Ends  ****************
      
       ADDSP  .L1X    sum0,         sum1,    A_sum10  ; Asum10=sum0 + sum1
||     B      .S1     NO_INTS                  ; To block interrupts       

       ADDSP  .L2X    sum0,         sum1,    B_sum10  ; Bsum10=sum0 + sum1

       ADDSP  .L1X    sum0,         sum1,    A_sum10  ; Asum10=sum0 + sum1

       ADDSP  .L2X    sum0,         B9,      B_sum10  ; Bsum10=sum0 + sum1

       NOP                                            ; wait for Bsum10

       ADDSP  .L1X    A_sum10,      B_sum10, A_finalh ; A_finalh=Asum10+Bsum10

NO_INTS:

       NOP                                            ; wait for next Bsum10

       ADDSP  .L2X    A_sum10,      B_sum10, B_finalh ; B_finalh=Asum10+Bsum10

       NOP                                            ; wait for B_finalh

       B      .S2     B3                              ; return from function

       NOP                                            ; wait for B_finalh

       ADDSP  .L1X    A_finalh,     B_finalh, A_return; return A_return

       NOP            3                               ; A_return and branch

                .end

* ======================================================================== *
*  End of file: sp_dotprod.asm                                             *
* ------------------------------------------------------------------------ *
*          Copyright (C) 2003 Texas Instruments, Incorporated.             *
*                          All Rights Reserved.                            *
* ======================================================================== *


