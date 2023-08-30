* ======================================================================= *
*  TEXAS INSTRUMENTS, INC.                                                *
*                                                                         *
*  NAME                                                                   *
*      DSPF_sp_ifftSPxSP -- Single Precision floating point mixed radix   *
*      inverse FFT with complex input                                     *
*                                                                         *
*   USAGE                                                                 *  
*           This routine is C-callable and can be called as:              *  
*                                                                         *  
*           void DSPF_sp_ifftSPxSP(                                       *  
*               int n, float* ptr_x, float * ptr_w, float * ptr_y,        *  
*               unsigned char* brev, int n_min, int offset, int n_max);   *  
*                                                                         *  
*       n   : Length of ifft in complex samples, power of 2 such that     *  
*              n >=8 and n <= 16384.                                      *  
*     ptr_x : Pointer to complex data input (normal order)                *  
*     ptr_w : Pointer to complex twiddle factor (see below)               *  
*     ptr_y : Pointer to complex output data (normal order)               *  
*     brev  : Pointer to bit reverse table containing 64 entries          *  
*     n_min : Smallest ifft butterfly used in computation                 *  
*             used for decomposing ifft into subiffts, see notes          *  
*     offset: Index in complex samples of sub-ifft from start of          *  
*                    main ifft                                            *  
*     n_max : Size of main ifft in complex samples                        *  
*                                                                         *  
*   DESCRIPTION                                                           *  
*                                                                         *  
*          The benchmark performs a mixed radix forwards ifft using       *  
*          a special sequence of coefficients generated in the following  *  
*          way:                                                           *  
*                                                                         *  
*          /*generate vector of twiddle factors for optimized algorithm*/ *  
*           void tw_gen(float* w, int N)                                  *  
*           {                                                             *  
*             int j, k;                                                   *  
*             double x_t, y_t, theta1, theta2, theta3;                    *  
*             const double PI = 3.141592654;                              *  
*                                                                         *  
*             for (j=1, k=0; j <= N>>2; j = j<<2)                         *  
*             {                                                           *  
*                 for (i=0; i < N>>2; i+=j)                               *  
*                 {                                                       *  
*                     theta1 = 2*PI*i/N;                                  *  
*                     x_t = cos(theta1);                                  *  
*                     y_t = sin(theta1);                                  *  
*                     w[k]   =  (float)x_t;                               *  
*                     w[k+1] =  (float)y_t;                               *  
*                                                                         *  
*                     theta2 = 4*PI*i/N;                                  *  
*                     x_t = cos(theta2);                                  *  
*                     y_t = sin(theta2);                                  *  
*                     w[k+2] =  (float)x_t;                               *  
*                     w[k+3] =  (float)y_t;                               *  
*                                                                         *  
*                     theta3 = 6*PI*i/N;                                  *  
*                     x_t = cos(theta3);                                  *  
*                     y_t = sin(theta3);                                  *  
*                     w[k+4] =  (float)x_t;                               *  
*                     w[k+5] =  (float)y_t;                               *  
*                     k+=6;                                               *  
*                 }                                                       *  
*             }                                                           *  
*           }                                                             *  
*         This redundant set of twiddle factors is size 2*N float samples.*  
*         The function is accurate to about 130dB of signal to noise ratio*  
*         to the IDFT function below:                                     *  
*                                                                         *  
*           void idft(int n, float x[], float y[])                        *  
*           {                                                             *  
*             int k,i, index;                                             *  
*             const float PI = 3.14159654;                                *  
*             float* p_x;                                                 *  
*             float arg, fx_0, fx_1, fy_0, fy_1, co, si;                  *  
*                                                                         *  
*             for(k = 0; k<n; k++)                                        *  
*             {                                                           *  
*               p_x = x;                                                  *  
*               fy_0 = 0;                                                 *  
*               fy_1 = 0;                                                 *  
*               for(i=0; i<n; i++)                                        *  
*               {                                                         *  
*                 fx_0 = p_x[0];                                          *  
*                 fx_1 = p_x[1];                                          *  
*                 p_x += 2;                                               *  
*                 index = (i*k) % n;                                      *  
*                 arg = 2*PI*index/n;                                     *  
*                 co = cos(arg);                                          *  
*                 si = sin(arg);                                          *  
*                 fy_0 += ((fx_0* co) - (fx_1 * si));                     *  
*                 fy_1 += ((fx_1* co) + (fx_0 * si));                     *  
*               }                                                         *  
*               y[2*k] = fy_0/n;                                          *  
*               y[2*k+1] = fy_1/n;                                        *  
*             }                                                           *  
*          }                                                              *  
*                                                                         *  
*          The function takes the table and input data and calculates the *  
*          ifft producing the frequency domain data in the Y array. the   *  
*          output is scaled by a scaling factor of 1/N.                   *  
*                                                                         *  
*          As the ifft allows every input point to effect every output    *  
*          point in a cache based system such as the c6711, this causes   *  
*          cache thrashing. This is mitigated by allowing the main ifft   *  
*          of size N to be divided into several steps, allowing as much   *  
*          data reuse as possible.                                        *  
*                                                                         *  
*          For example the following function:                            *  
*                                                                         *  
*          DSPF_sp_ifftSPxSP(1024, &x[0],&w[0],y,brev,4,  0,1024)         *  
*                                                                         *  
*          is equvalent to:                                               *  
*                                                                         *  
*          DSPF_sp_ifftSPxSP(1024,&x[2*0],&w[0],y,brev,256,0,1024)        *  
*          DSPF_sp_ifftSPxSP(256,&x[2*0],&w[2*768],y,brev,4,0,1024)       *  
*          DSPF_sp_ifftSPxSP(256,&x[2*256],&w[2*768],y,brev,4,256,1024)   *  
*          DSPF_sp_ifftSPxSP(256,&x[2*512],&w[2*768],y,brev,4,512,1024)   *  
*          DSPF_sp_ifftSPxSP(256,&x[2*768],&w[2*768],y,brev,4,768,1024)   *  
*                                                                         *  
*          Notice how the 1st ifft function is called on the entire 1K    *  
*          data set it covers the 1st pass of the ifft until the butterfly*  
*          size is 256. The following 4 iffts do 256 pt iffts 25% of the  *  
*          size. These continue down to the end when the buttefly is of   *  
*          size 4. They use an index to the main twiddle factor array of  *  
*          0.75*2*N. This is because the twiddle factor array is composed *  
*          of successively decimated versions of the main array.          *  
*                                                                         *  
*          N not equal to a power of 4 can be used, i.e. 512. In this case*  
*          to decompose the ifft the following would be needed :          *  
*                                                                         *  
*          DSPF_sp_ifftSPxSP(512, &x[0],&w[0],y,brev,2,  0,512)           *  
*                                                                         *  
*          is equvalent to:                                               *  
*                                                                         *  
*          DSPF_sp_ifftSPxSP(512, &x[2*0],  &w[0] ,   y,brev,128,  0,512) *  
*          DSPF_sp_ifftSPxSP(128, &x[2*0],  &w[2*384],y,brev,4,    0,512) *  
*          DSPF_sp_ifftSPxSP(128, &x[2*128],&w[2*384],y,brev,4,  128,512) *  
*          DSPF_sp_ifftSPxSP(128, &x[2*256],&w[2*384],y,brev,4,  256,512) *  
*          DSPF_sp_ifftSPxSP(128, &x[2*384],&w[2*384],y,brev,4,  384,512) *  
*                                                                         *  
*          The twiddle factor array is composed of log4(N) sets of twiddle*  
*          factors, (3/4)*N, (3/16)*N, (3/64)*N, etc.  The index into this*  
*          array for each stage of the ifft is calculated by summing these*  
*          indices up appropriately.                                      *  
*          For multiple iffts they can share the same table by calling the*  
*          small iffts from further down in the twiddle factor array. In  *  
*          the same way as the decomposition works for more data reuse.   *  
*                                                                         *  
*          Thus, the above decomposition can be summarized for a general N*  
*          radix "rad" as follows:                                        *  
*          DSPF_sp_ifftSPxSP(N,  &x[0],      &w[0],      y,brev,          *  
*                        N/4,0,   N)                                      *  
*          DSPF_sp_ifftSPxSP(N/4,&x[0],      &w[2*3*N/4],y,brev,rad,      *  
*                       0,   N)                                           *  
*          DSPF_sp_ifftSPxSP(N/4,&x[2*N/4],  &w[2*3*N/4],y,brev,rad,      *  
*                        N/4, N)                                          *  
*          DSPF_sp_ifftSPxSP(N/4,&x[2*N/2],  &w[2*3*N/4],y,brev,rad,      *  
*                        N/2, N)                                          *  
*          DSPF_sp_ifftSPxSP(N/4,&x[2*3*N/4],&w[2*3*N/4],y,brev,rad,      *  
*                        3*N/4,N)                                         *  
*                                                                         *  
*          As discussed previously, N can be either a power of 4 or 2.    *  
*          If N is a power of 4, then rad = 4, and if N is a power of 2   *  
*          and not a power of 4, then rad = 2. "rad" is used to control   *  
*          how many stages of decomposition are performed. It is also     *  
*          used to determine whether a radix-4 or radix-2 decomposition   *  
*          should be performed at the last stage. Hence when "rad" is set *  
*          to "N/4" the first stage of the transform alone is performed   *  
*          and the code exits. To complete the FFT, four other calls are  *  
*          required to perform N/4 size FFTs.In fact, the ordering of     *  
*          these 4 FFTs amongst themselves does not matter and hence from *  
*          a cache perspective, it helps to go through the remaining 4    *  
*          FFTs in exactly the opposite order to the first. This is       *  
*          illustrated as follows:                                        *  
*                                                                         *  
*          DSPF_sp_ifftSPxSP(N,&x[0],&w[0],y,brev,N/4,0,N)                *  
*          DSPF_sp_ifftSPxSP(N/4,&x[3*N/2],&w[3*N/2],y,brev,rad,3*N/4,N)  *  
*          DSPF_sp_ifftSPxSP(N/4,&x[N],&w[3*N/2],y,brev,rad,N/2,N)        *  
*          DSPF_sp_ifftSPxSP(N/4,&x[N/2],&w[3*N/2],y,brev,rad,N/4,N)      *  
*          DSPF_sp_ifftSPxSP(N/4,&x[0],&w[3*N/2],y,brev,rad,0,N)          *  
*          In addition this function can be used to minimize call         *  
*      overhead, by completing the FFT with one function call             *  
*      invocation as shown below:                                         *  
*          DSPF_sp_ifftSPxSP(N,&x[0],&w[0],y,brev,rad,0,N)                *  
*                                                                         *  
*   TECHNIQUES                                                            *  
*          1. A special sequence of coeffs. used as generated above       *  
*          produces the ifft. This collapses the inner 2 loops in the     *  
*          taditional Burrus and Parks implementation Fortran Code.       *  
*                                                                         *  
*          2. The revised FFT uses a redundant sequence of twiddle factors*  
*          to allow a linear access through the data. This linear access  *  
*          enables data and instruction level parallelism.                *  
*                                                                         *  
*          3.The data produced by the DSPF_DSPF_sp_ifftSPxSP ifft is in   *  
*        normal form,the whole data array is written into a new output    *  
*        buffer.                                                          *  
*                                                                         *  
*          4. The DSPF_sp_ifftSPxSP butterfly is bit reversed, i.e. the   *  
*         inner 2 points of the butterfly are crossed over, this has      *  
*         the effect of making the data come out in bit reversed rather   *  
*         than DSPF_sp_ifftSPxSP digit reversed order. This simplifies    *  
*         the last pass of the loop. ia simple table is used to do the    *  
*         bit reversal out of place.                                      *  
*                                                                         *  
*              unsigned char brev[64] = {                                 *  
*                    0x0, 0x20, 0x10, 0x30, 0x8, 0x28, 0x18, 0x38,        *  
*                    0x4, 0x24, 0x14, 0x34, 0xc, 0x2c, 0x1c, 0x3c,        *  
*                    0x2, 0x22, 0x12, 0x32, 0xa, 0x2a, 0x1a, 0x3a,        *  
*                    0x6, 0x26, 0x16, 0x36, 0xe, 0x2e, 0x1e, 0x3e,        *  
*                    0x1, 0x21, 0x11, 0x31, 0x9, 0x29, 0x19, 0x39,        *  
*                    0x5, 0x25, 0x15, 0x35, 0xd, 0x2d, 0x1d, 0x3d,        *  
*                    0x3, 0x23, 0x13, 0x33, 0xb, 0x2b, 0x1b, 0x3b,        *  
*                    0x7, 0x27, 0x17, 0x37, 0xf, 0x2f, 0x1f, 0x3f         *  
*              };                                                         *  
*                                                                         *  
*   ASSUMPTIONS                                                           *  
*                                                                         *  
*          1. N must be a power of 2 and N >= 8,  N <= 16384 points.      *  
*                                                                         *  
*          2. Complex time data x and twiddle facotrs w are aligned on    *  
*          double word boundares. Real values are stored in even word     *  
*          positions and imaginary values in odd positions.               *  
*                                                                         *  
*          3. All data is in single precision floating point format. The  *  
*          complex frequency data will be returned in linear order.       *  
*                                                                         *  
*          4. x must be padded with 16 words at the end.                  *  
*   C CODE                                                                *  
*           This is the C equivalent of the assembly code without         *  
*           restrictions. Note that the assembly code is hand optimized   *  
*           and restrictions may apply.                                   *  
*                                                                         *  
*                                                                         *  
*   void DSPF_sp_ifftSPxSP(int n, float ptr_x[], float ptr_w[],           *
*                          float ptr_y[],                                 *  
*           unsigned char brev[], int n_min, int offset, int n_max)       *  
*   {                                                                     *  
*       int  i, j, k, l1, l2, h2, predj;                                  *  
*       int  tw_offset, stride, fft_jmp;                                  *  
*                                                                         *  
*       float x0, x1, x2, x3,x4,x5,x6,x7;                                 *  
*       float xt0, yt0, xt1, yt1, xt2, yt2, yt3;                          *  
*       float yt4, yt5, yt6, yt7;                                         *  
*       float si1,si2,si3,co1,co2,co3;                                    *  
*       float xh0,xh1,xh20,xh21,xl0,xl1,xl20,xl21;                        *  
*       float x_0, x_1, x_l1, x_l1p1, x_h2 , x_h2p1, x_l2, x_l2p1;        *  
*       float xl0_0, xl1_0, xl0_1, xl1_1;                                 *  
*       float xh0_0, xh1_0, xh0_1, xh1_1;                                 *  
*       float*x,*w;                                                       *  
*       int   k0, k1, j0, j1, l0, radix;                                  *  
*       float* y0, * ptr_x0, * ptr_x2;                                    *  
*                                                                         *  
*       radix = n_min;                                                    *  
*                                                                         *  
*       stride = n; /* n is the number of complex samples*/               *  
*       tw_offset = 0;                                                    *  
*       while (stride > radix)                                            *  
*       {                                                                 *  
*           j = 0;                                                        *  
*           fft_jmp = stride + (stride>>1);                               *  
*           h2 = stride>>1;                                               *  
*           l1 = stride;                                                  *  
*           l2 = stride + (stride>>1);                                    *  
*           x = ptr_x;                                                    *  
*           w = ptr_w + tw_offset;                                        *  
*                                                                         *  
*           for (i = 0; i < n; i += 4)                                    *  
*           {                                                             *  
*               co1 = w[j];                                               *  
*               si1 = w[j+1];                                             *  
*               co2 = w[j+2];                                             *  
*               si2 = w[j+3];                                             *  
*               co3 = w[j+4];                                             *  
*               si3 = w[j+5];                                             *  
*                                                                         *  
*               x_0    = x[0];                                            *  
*               x_1    = x[1];                                            *  
*               x_h2   = x[h2];                                           *  
*               x_h2p1 = x[h2+1];                                         *  
*               x_l1   = x[l1];                                           *  
*               x_l1p1 = x[l1+1];                                         *  
*               x_l2   = x[l2];                                           *  
*               x_l2p1 = x[l2+1];                                         *  
*                                                                         *  
*               xh0  = x_0    + x_l1;                                     *  
*               xh1  = x_1    + x_l1p1;                                   *  
*               xl0  = x_0    - x_l1;                                     *  
*               xl1  = x_1    - x_l1p1;                                   *  
*                                                                         *  
*               xh20 = x_h2   + x_l2;                                     *  
*               xh21 = x_h2p1 + x_l2p1;                                   *  
*               xl20 = x_h2   - x_l2;                                     *  
*               xl21 = x_h2p1 - x_l2p1;                                   *  
*                                                                         *  
*               ptr_x0 = x;                                               *  
*               ptr_x0[0] = xh0 + xh20;                                   *  
*               ptr_x0[1] = xh1 + xh21;                                   *  
*                                                                         *  
*               ptr_x2 = ptr_x0;                                          *  
*               x += 2;                                                   *  
*               j += 6;                                                   *  
*               predj = (j - fft_jmp);                                    *  
*               if (!predj) x += fft_jmp;                                 *  
*               if (!predj) j = 0;                                        *  
*                                                                         *  
*               xt0 = xh0 - xh20;                                         *  
*               yt0 = xh1 - xh21;                                         *  
*               xt1 = xl0 - xl21;                                         *  
*               yt2 = xl1 - xl20;                                         *  
*               xt2 = xl0 + xl21;                                         *  
*               yt1 = xl1 + xl20;                                         *  
*                                                                         *  
*               ptr_x2[l1  ] = xt1* co1 - yt1 * si1;                      *  
*               ptr_x2[l1+1] = yt1* co1 + xt1 * si1;                      *  
*               ptr_x2[h2  ] = xt0* co2 - yt0 * si2;                      *  
*               ptr_x2[h2+1] = yt0* co2 + xt0 * si2;                      *  
*               ptr_x2[l2  ] = xt2* co3 - yt2 * si3;                      *  
*               ptr_x2[l2+1] = yt2* co3 + xt2 * si3;                      *  
*           }                                                             *  
*               tw_offset += fft_jmp;                                     *  
*               stride = stride>>2;                                       *  
*         }/* end while*/                                                 *  
*                                                                         *  
*         j = offset>>2;                                                  *  
*                                                                         *  
*         ptr_x0 = ptr_x;                                                 *  
*         y0 = ptr_y;                                                     *  
*         /*l0 = _norm(n_max) - 17;    get size of fft*/                  *  
*         l0=0;                                                           *  
*         for(k=30;k>=0;k--)                                              *  
*             if( (n_max & (1 << k)) == 0 )                               *  
*                 l0++;                                                   *  
*             else                                                        *  
*                 break;                                                  *  
*         l0=l0-17;                                                       *  
*         if (radix <= 4) for (i = 0; i < n; i += 4)                      *  
*         {                                                               *  
*             /* reversal computation*/                                   *  
*                                                                         *  
*             j0 = (j     ) & 0x3F;                                       *  
*             j1 = (j >> 6);                                              *  
*             k0 = brev[j0];                                              *  
*             k1 = brev[j1];                                              *  
*             k = (k0 << 6) +  k1;                                        *  
*             k = k >> l0;                                                *  
*             j++;        /* multiple of 4 index*/                        *  
*                                                                         *  
*             x0   = ptr_x0[0];  x1 = ptr_x0[1];                          *  
*             x2   = ptr_x0[2];  x3 = ptr_x0[3];                          *  
*             x4   = ptr_x0[4];  x5 = ptr_x0[5];                          *  
*             x6   = ptr_x0[6];  x7 = ptr_x0[7];                          *  
*             ptr_x0 += 8;                                                *  
*                                                                         *  
*             xh0_0  = x0 + x4;                                           *  
*             xh1_0  = x1 + x5;                                           *  
*             xh0_1  = x2 + x6;                                           *  
*             xh1_1  = x3 + x7;                                           *  
*                                                                         *  
*             if (radix == 2)                                             *  
*         {                                                               *  
*                 xh0_0 = x0;                                             *  
*                 xh1_0 = x1;                                             *  
*                 xh0_1 = x2;                                             *  
*                 xh1_1 = x3;                                             *  
*             }                                                           *  
*                                                                         *  
*             yt0  = xh0_0 + xh0_1;                                       *  
*             yt1  = xh1_0 + xh1_1;                                       *  
*             yt4  = xh0_0 - xh0_1;                                       *  
*             yt5  = xh1_0 - xh1_1;                                       *  
*                                                                         *  
*             xl0_0  = x0 - x4;                                           *  
*             xl1_0  = x1 - x5;                                           *  
*             xl0_1  = x2 - x6;                                           *  
*             xl1_1  = x7 - x3;                                           *  
*                                                                         *  
*             if (radix == 2)                                             *  
*         {                                                               *  
*                 xl0_0 = x4;                                             *  
*                 xl1_0 = x5;                                             *  
*                 xl1_1 = x6;                                             *  
*                 xl0_1 = x7;                                             *  
*             }                                                           *  
*                                                                         *  
*             yt2  = xl0_0 + xl1_1;                                       *  
*             yt3  = xl1_0 + xl0_1;                                       *  
*             yt6  = xl0_0 - xl1_1;                                       *  
*             yt7  = xl1_0 - xl0_1;                                       *  
*                                                                         *  
*             y0[k] = yt0/n_max; y0[k+1] = yt1/n_max;                     *  
*             k += n_max>>1;                                              *  
*             y0[k] = yt2/n_max; y0[k+1] = yt3/n_max;                     *  
*             k += n_max>>1;                                              *  
*             y0[k] = yt4/n_max; y0[k+1] = yt5/n_max;                     *  
*             k += n_max>>1;                                              *  
*             y0[k] = yt6/n_max; y0[k+1] = yt7/n_max;                     *  
*        }                                                                *  
*    }                                                                    *  
*                                                                         *  
*     NOTES                                                               *  
*                                                                         *  
*          1. The special sequence of twiddle factors w can be generated  *  
*         using the tw_fftSPxSP_C67 function provided in the              *  
*         dsplib\support\fft\tw_fftSPxSP_C67.c file or by running         *  
*         tw_fftSPxSP_C67.exe in dsplib\bin.                              *  
*                                                                         *  
*      2. The brev table required for this function is provided in the    *  
*         file dsplib\support\fft\brev_table.h.                           *  
*                                                                         *  
*      3. Endian: Configuration is LITTLE ENDIAN.                         *  
*                                                                         *  
*          4. Interruptibility: An interruptible window of 1 cycle is     *  
*         available between the 2 outer loops.                            *  
*                                                                         *  
*   CYCLES                                                                *  
*         cycles = 3* ceil(log4(N)-1) * N + 21*ceil(log4(N)-1) + 2*N + 44 *  
*         e.g. N = 1024,  cycles = 14464                                  *  
*         e.g. N = 512,   cycles = 7296                                   *  
*         e.g. N = 256,   cycles = 2923                                   *  
*         e.g. N = 128,   cycles = 1515                                   *  
*         e.g. N = 64,    cycles = 598                                    *  
*                                                                         *  
*   CODESIZE                                                              *  
*          1472 bytes                                                     *  
* ----------------------------------------------------------------------- *
*            Copyright (c) 2003 Texas Instruments, Incorporated.          *
*                           All Rights Reserved.                          *
* ======================================================================= *


                .global _DSPF_sp_ifftSPxSP

_DSPF_sp_ifftSPxSP:

       SUBAW  .D2    B15,     24      , B15   ; save stack space
       STW    .D2T2  B10,     *B15[1]         ; save b10
   
       MV     .S1X   B15,     A5              ; copy stack pointer
||     STW    .D2T1  A10,     *B15[6]         ; save a10

       STW    .D2T2  B11,     *B15[2]         ; save b11
||     STW    .D1T1  A11,     *A5[7]          ; save a11

       STW    .D2T2  B12,     *B15[3]         ; save b12
||     STW    .D1T1  A11,     *A5[8]          ; save a11

       STW    .D2T2  B13,     *B15[4]         ; save b13
||     STW    .D1T1  A12,     *A5[9]          ; save a12

       STW    .D2T2  B14,     *B15[5]         ; save b14
||     STW    .D1T1  A13,     *A5[10]         ; save a13
||     MVC    .S2    CSR,     B11             ; get csr

       STW    .D2T1  A14,     *B15[11]        ; store a14
||     STW    .D1T2  B3,      *A5[12]         ; store b3
||     MV     .S1X   B4,      A14             ; move to a_x
||     AND    .L2    B11,     -2,       B12   ; disable interrupt bit

       STW    .D2T1  A15,     *B15[13]        ; save a15
||     STW    .D1T2  B8,      *A5[15]         ; store n_min or radix
||     MV     .S2X   A6,      B14             ; move to b_w2
||     SHR    .S1    A4,      1,        A0    ; get al1

       STW    .D2T2  B4,      *B15[16]        ; store ptr_x
||     STW    .D1T1  A4,      *A5[17]         ; store N
||     SHR    .S2X   A0,      1,        B3    ; get bh2

       STW    .D2T2  B6,      *B15[18]        ; store ptr_y
||     STW    .D1T1  A8,      *A5[19]         ; store brev
||     ADD    .S1X   A0,      B3,       A3    ; get al2
||     MVC    .S2    B12,     CSR             ; disable interrupt

       STW    .D2T1  A10,     *B15[20]        ; store offset
||     STW    .D1T2  B10,     *A5[21]         ; store n_max
||     MVC    .S2    IRP,     B10             ; get irp for storing
||     MV     .S1X   B11,     A11             ; get csr for storing

       STW    .D2T2  B10,     *B15[14]        ; store irp
||     STW    .D1T1  A11,     *A5[22]         ; store original csr        
||     ZERO   .S1    A1                       ; j=0
||     MVC    .S2X   A4,      IRP             ; store counter(N) in irp
; end of initialisation        

OUT_LOOP:      
************************ INNER LOOP PROLOG**********************************
                                           
       MV     .S1    A14,     A2              ; move a_x to a_y
||     MV     .S2X   A14,     B2              ; move a_x to b_x
               
       LDDW   .D2T1  *B2,     A7:A6           ; load x1:x0
||     LDDW   .D1T2  *A14[A3],B7:B6           ; load xl2p1:xl2
||     MV     .S2    B2,      B0              ; move a_x to b_y 

       LDDW   .D1T1  *A14[A0],A5:A4           ; load xl1p1:xl1
||     LDDW   .D2T2  *B2[B3], B5:B4           ; load xh2p1:xh2

       NOP                                
        
       ADD    .S1    A1,      3,        A1    ; j=j+3
 
       SUB    .S1    A1,      A3,       A1    ; j=j-fftlmp(al2)
||     ADD    .S2    B14,     0,        B3    ; get initial b_w2
        
  [!A1]ADDAD  .D1    A14,     A3,       A14   ; a_x=a_x+fftjmp(al2)
||     STW    .D2T1  A14,     *B15[23]        ; store current a_x
   
       ADDSP  .L1    A6,      A4,       A4    ; axh0=xl1+x0
||     ADDSP  .L2    B4,      B6,       B4    ; bxh20=xh2+xl2

       ADDSP  .L1    A7,      A5,       A5    ; axh1=x1+xl1p1
||     ADDSP  .L2    B5,      B7,       B5    ; bxh21=xh2p1+xl2p1
||     MV     .S2    B3,      B1              ; save b_w in b1

********************** PIPED LOOP KERNEL ***********************************
LOOP:  
       SUBSP  .L1    A6,      A4,       A6    ; (1)axl0=x0-xl1
||     SUBSP  .L2    B5,      B7,       B6    ; bxl21=xh2p1-xl2p1
||     SHR    .S2X   A0,      1,        B3    ; bh2=al1/2
||     MV     .S1X   B3,      A6              ; move b_w to a_w
||     MPYSP  .M1    A11,     A9,       A12   ; prod4=xt1*si1
||     MPYSP  .M2    B9,      B11,      B12   ; prod12=si3*xt2
||     ADD    .D1    A14,     8,        A14   ; a_x=a_x+8

       SUBSP  .L1    A7,      A5,       A7    ; (2)axl1=x1-xl1p1
||     SUBSP  .L2    B4,      B6,       B7    ; bxl20=xh2-xl2
||     MV     .S2X   A14,     B2              ; move a_x to b_x
||     ADD    .S1X   A0,      B3,       A3    ; al2=al1+bh2
||     STW    .D2T2  B13,     *B0[1]          ; store xh1pxh21
||[A1] ADD    .D1    A1,      A3,       A1    ; j=j+fftjmp(al2)

       LDDW   .D1T2  *A6[1],  B3:B2           ; (3)load si2:co2
||     STW    .D2T1  A13,     *B0             ; store xh0pxh20
||     SUBSP  .L1X   A12,     B12,      A13   ; sum3=prod5-prod6
||     ADDSP  .L2X   B8,      A8,       B13   ; sum4=prod8+prod7
||     MVC    .S2    IRP,     B8              ; get loop counter to b1

       SUBSP  .L1X   A4,      B4,       A7    ; (4)xt0=axh0-bxh20
||     SUBSP  .L2X   A5,      B5,       B7    ; yt0=axh1-bxh21
||     LDDW   .D1T1  *A6,     A9:A8           ; load si1:co1
||     LDDW   .D2T2  *B1[2],  B9:B8           ; load si3:co3
||     SHL    .S1    A0,      1,        A15   ; al=al1*2
||     SUB    .S2    B8,      4,        B1    ; b1=b1-4

       LDDW   .D2T1  *B2,     A7:A6           ; (5)load x1:x0
||     LDDW   .D1T2  *A14[A3],B7:B6           ; load xl2p1:xl2
||     ADDSP  .L2X   A6,      B6,       B11   ; xt2=axl0+bxl21
||     SUBSP  .L1X   A6,      B6,       A11   ; xt1=axl0-bxl21 
||     MVC    .S2    B1,      IRP             ; store updated counter in irp  

       LDDW   .D1T1  *A14[A0],A5:A4           ; (6)load xl1p1:xl1
||     LDDW   .D2T2  *B2[B3], B5:B4           ; load xh2p1:xh2
||     ADDSP  .L1X   A7,      B7,       A10   ; yt1=axl1+bxl20
||     SUBSP  .L2X   A7,      B7,       B10   ; yt2=axl1-bxl20
||     SHL    .S2    B3,      1,        B8    ; bl=bh2*2

       SUBSP  .L1    A9,      A11,      A13   ; (7)sum1=prod1-prod2
||     SUBSP  .L2    B9,      B11,      B13   ; sum5=prod9-prod10
||     ADD    .D1    A2,      4,        A11   ; acopy1=a_y+4
||     LDW    .D2T2  *B15[23],B0              ; load 2nd last value of ax
||     SUB    .S2    B1,      4,        B1    ; flag for checking extra loads
||[B1] B      .S1    LOOP                     ; branch to beginning

       ADD    .S1    A1,      3,        A1    ; (8)j=j+3
||     MPYSP  .M1X   B2,      A7,       A12   ; prod5=co2*xt0
||     MPYSP  .M2    B7,      B3,       B12   ; prod6=yt0*si2
||     SHL    .S2X   A1,      3,        B12   ; j*8
||     STW    .D2T1  A13,     *B0[B8]         ; store sum3
||     STW    .D1T2  B13,     *A11[A0]        ; store sum4
||     ADDSP  .L1    A10,     A12,      A13   ; sum2=prod3+prod4
||     ADDSP  .L2    B10,     B12,      B13   ; sum6=prod11+prod12

  [B1] SUB    .S1    A1,      A3,       A1    ; (9)j=j-fftjmp(al2)       
||     MPYSP  .M1X   B3,      A7,       A8    ; prod8=si2*xt0
||     MPYSP  .M2    B2,      B7,       B8    ; prod7=co2*yt0
||     ADD    .D2    B14,     B12,      B3    ; b_w2=b_w+j*8
||     SHL    .S2X   A3,      1,        B2    ; bl2=al2*2

  [!A1]ADDAD  .D1    A14,     A3,       A14   ; (10)a_x=a_x+fftjmp(al2)
||     MPYSP  .M1    A8,      A11,      A9    ; prod1=co1*xt1
||     MPYSP  .M2    B8,      B11,      B9    ; prod9=co3*xt2
||     ADDSP  .L1X   A4,      B4,       A13   ; xh0pxh20=axh0+bxh20
||     ADDSP  .L2X   A5,      B5,       B13   ; xh1pxh21=axh1+bxh21
||     ADD    .S2    B0,      4,        B1    ; bycopy3=b_y+4
||     STW    .D2T1  A14,     *B15[23]        ; store current a_x

       ADDSP  .L1    A6,      A4,       A4    ; (11)axh0=xl1+x0
||     ADDSP  .L2    B4,      B6,       B4    ; bxh20=xh2+xl2
||     MPYSP  .M1    A8,      A10,      A10   ; prod3=yt1*co1
||     MPYSP  .M2    B10,     B9,       B11   ; prod10=yt2*si3
||     ADD    .S1    A2,      4,        A8    ; acopy1=a_y+4
||     STW    .D1T1  A13,     *A2[A15]        ; store sum1
||     STW    .D2T2  B13,     *B0[B2]         ; store sum5

       ADDSP  .L1    A7,      A5,       A5    ; (12)axh1=x1+xl1p1
||     ADDSP  .L2    B5,      B7,       B5    ; bxh21=xh2p1+xl2p1
||     MPYSP  .M1    A10,     A9,       A11   ; prod2=si1*yt1
||     MPYSP  .M2    B8,      B10,      B10   ; prod11=co3*yt2
||     STW    .D1T1  A13,     *A8[A15]        ; store sum2
||     STW    .D2T2  B13,     *B1[B2]         ; store sum6
||     MV     .S2    B3,      B1              ; save b_w in b1
||     MV     .S1X   B0,      A2              ; move b_y to a_y
; BRANCH OCCURS HERE

**************************** LOOP EPILOG **********************************
************PARALLEL WITH OUTER LOOP INSTRUCTIONS *************************

       MPYSP  .M1    A11,     A9,       A12   ; prod4=xt1*si1        
||     MPYSP  .M2    B9,      B11,      B12   ; prod12=si3*xt2
||     SHR    .S2X   A0,      1,        B3    ; bh2=al1/2
||     LDW    .D2T1  *B15[15],A4              ; load radix or n_min 
||     MV     .S1X   B15,     A6              ; move sp for load

       STW    .D2T2  B13,     *B0[1]          ; store xh1pxh21
||     LDW    .D1T1  *A6[16], A14             ; load back initial a_x

       STW    .D2T1  A13,     *B0             ; store xh0pxh20
||     LDW    .D1T2  *A6[17], B4              ; load b_i or N

       SHL    .S1    A0,      1,        A15   ; al=al1*2
||     SUBSP  .L1X   A12,     B12,      A13   ; sum3=prod5-prod6
||     ADDSP  .L2X   B8,      A8,       B13   ; sum4=prod7+prod8
        
       SHR    .S1    A0,      1,        A5    ; get stride=al1/2
||     LDW    .D2T2  *B15[18],B6              ; load y_ptr
       
       SHL    .S2    B3,      1,        B8    ; bl=bh2*2        
||     CMPGT  .L1    A5,      A4,       A1    ; while(stride > radix)
||     LDW    .D2T1  *B15[19],A5              ; load brev 

       SUBSP  .L1    A9,      A11,      A13   ; sum1=prod1-prod2
||     SUBSP  .L2    B9,      B11,      B13   ; sum5=prod9-prod10
||     ADD    .D1    A2,      4,        A11   ; acopy1=a_y+4
||[A1] B      .S1    OUT_LOOP                 ; jump to outer loop
||[!A1]LDW    .D2T2  *B15[22],B5              ; load original csr
 
       STW    .D2T1  A13,     *B0[B8]         ; store sum3
||     STW    .D1T2  B13,     *A11[A0]        ; store sum4
||     ADDSP  .L1    A10,     A12,      A13   ; sum2=prod3+prod4
||     ADDSP  .L2    B10,     B12,      B13   ; sum6=prod11+prod12 
||     MVC    .S2    B4,      IRP             ; move N to irp

       SHL    .S2X   A3,      1,        B2    ; bl2=al2*2
||     SHR    .S1    A0,      2,        A0    ; l1 = l1/4 or stride/4
||     MPY    .M1    A3,      8,        A7    ; get correct fftjmp
||[!A1]LDW    .D1T1  *A6[20], A7              ; load offset
||[!A1]LDW    .D2T2  *B15[21],B7              ; load n_max

       ADD    .D2    B0,      4,        B1    ; bycopy=b_y+4
||     SHR    .S2X   A0,      1,        B3    ; get bh2

       ADD    .S1    A2,      4,        A8    ; acopy1=a_y+4
||     STW    .D1T1  A13,     *A2[A15]        ; store sum1
||     STW    .D2T2  B13,     *B0[B2]         ; store sum5
||     ADD    .S2X   B14,     A7,       B14   ; w= w+fftjmp

       STW    .D1T1  A13,     *A8[A15]        ; store sum2
||     STW    .D2T2  B13,     *B1[B2]         ; store sum6
||     ZERO   .L1    A1                       ; j=0
||     ADD    .S1X   A0,      B3,       A3    ; get al2(fft_jmp)
||[!A1]MVC    .S2    B5,      CSR             ; enable interrupt  

;BRANCH TO OUTER LOOP OCCURS HERE   

***************************************************************************

       CMPGT  .L1    A4,      4,        A1    ; if(radix <= 4)
||     MV     .D1    A14,     A9              ; move x_ptr to correct place
||     MV     .D2    B6,      B10             ; move the y_ptr
||     MVC    .S2    IRP,     B0              ; initialize counter
||     MV     .S1    A5,      A0              ; move the brev value
       
  [A1] B      .S2    END                      ; go to end if radix > 4
||     SHR    .S1    A7,      2,        A3    ; j=offset/4
||     NORM   .L2    B7,      B2              ; l0=_norm(n_max)
||     CMPEQ  .L1    A4,      2,        A2    ; flag=(radix==2)

       ADD    .L2X   A9,      8,        B3    ; copy x_ptr
||     CLR    .S1    A3,      6,        31, A8; 1st iteration j0
||     MV     .L1X   B7,      A15             ; move n_max
||     SUB    .D2    B2,      17,       B2    ; l0= l0-17

       SHR    .S2X   A15,     1,        B1    ; n_max = n_max / 2 
||     SHL    .S1    A15,     2,        A15   ; to get y-ptr copy
||     AND    .L2    B5,      -2,       B5    ; disable interrupt bit
  
       SUB    .L1X   B1,      0,        A1    ; to incr a-side y-ptr
||     ADD    .S1    A15,     4,        A15   ; for a-side y-ptr
||     MVC    .S2    B5,      CSR             ; disable interrupt
;INITIALIZATION OF REGISTERS ENDS HERE

*-------------------------PIPED LOOP PROLOG---------------------------------
       LDDW   .D1T1  *A9++[2],A5:A4           ; load x1:x0(xh1_0:xh0_0)
||     LDDW   .D2T2  *B3++[2],B5:B4           ; load x3:x2(xh1_1:xh0_1) 

       LDDW   .D1T1  *A9++[2],A7:A6           ; load x5:x4(xl1_0:xl0_0)
||     LDDW   .D2T2  *B3++[2],B7:B6           ; load x7:x6(xl1_1:xl0_1)

       INTSP  .L2    B7, B13                  ; Get n_max
  
       NOP
  
       NOP
  
       CLR    .S1    A3,      6,        31, A8; j0 = (j     ) & 0x3F

  [!A2]ADDSP  .L1    A4,      A6,       A4    ; xh0_0  = x0 + x4
||[!A2]ADDSP  .L2    B4,      B6,       B4    ; xh0_1  = x2 + x6
||     SHR    .S1    A3,      6,        A8    ; j1 = (j >> 6)
||     LDBU   .D1T2  *A0[A8], B11             ; k0 = brev[j0]
||     RCPSP  .S2    B13,     B13             ; Get 1/n_max

  [!A2]ADDSP  .L1    A5,      A7,       A5    ; xh1_0  = x1 + x5
||[!A2]ADDSP  .L2    B5,      B7,       B5    ; xh1_1  = x3 + x7
||     LDBU   .D1    *A0[A8], B4              ; k1 = brev[j1]
||     MV     .S1X   B13,     A13             ; A side 1/n_max

       LDDW   .D1T1  *A9++[2],A5:A4           ; load x1:x0(xh1_0:xh0_0)
||     LDDW   .D2T2  *B3++[2],B5:B4           ; load x3:x2(xh1_1:xh0_1) 
||[!A2]SUBSP  .L1    A4,      A6,       A6    ; xl0_0  = x0 - x4
||[!A2]SUBSP  .L2    B7,      B5,       B6    ; xl1_1  = x7 - x3

       LDDW   .D1T1  *A9++[2],A7:A6           ; load x5:x4(xl1_0:xl0_0)
||     LDDW   .D2T2  *B3++[2],B7:B6           ; load x7:x6(xl1_1:xl0_1)
||[!A2]SUBSP  .L1    A5,      A7,       A7    ; xl1_0  = x1 - x5
||[!A2]SUBSP  .L2    B4,      B6,       B7    ; xl0_1  = x2 - x6
||     ADD    .S1    A3,      1,        A3    ; j++

       ADDSP  .L1X   A4,      B4,       A12   ; yt0  = xh0_0 + xh0_1   
||     SUBSP  .L2X   A4,      B4,       B12   ; yt4  = xh0_0 - xh0_1

       ADDSP  .L1X   A5,      B5,       A12   ; yt1  = xh1_0 + xh1_1
||     SUBSP  .L2X   A5,      B5,       B12   ; yt5  = xh1_0 - xh1_1
||     SHL    .S2    B11,     6,        B11   ; k0 << 6
 
       ADDSP  .L1X   A6,      B6,       A12   ; yt2  = xl0_0 + xl1_1
||     SUBSP  .L2X   A6,      B6,       B12   ; yt6  = xl0_0 - xl1_1
||     ADD    .S2    B11,     B4,       B11   ; k = (k0 << 6) +  k1

       CLR    .S1    A3,      6,        31, A8; j0 = (j     ) & 0x3F
||     ADDSP  .L1X   A7,      B7,       A12   ; yt3  = xl1_0 + xl0_1
||     SUBSP  .L2X   A7,      B7,       B12   ; yt7  = xl1_0 - xl0_1    
||     SHR    .S2    B11,     B2,       B11   ; k = k >> l0

; ------------------------- BEGINNING OF KERNEL -------------------------

LOOP1:
  
  [!A2]ADDSP  .L1    A4,      A6,       A4    ; xh0_0  = x0 + x4
||[!A2]ADDSP  .L2    B4,      B6,       B4    ; xh0_1  = x2 + x6
||     SHR    .S1    A3,      6,        A8    ; j1 = (j >> 6)
||     LDBU   .D1T2  *A0[A8], B11             ; k0 = brev[j0]   
||     MPYSP  .M1    A12,     A13,      A12   ; yt0/n_max
||     MPYSP  .M2    B12,     B13,      B12   ; yt4/n_max
||     ADDAD  .D2    B10,     B1,       B9    ; y'' = y + n_max

  [!A2]ADDSP  .L1    A5,      A7,       A5    ; xh1_0  = x1 + x5
||[!A2]ADDSP  .L2    B5,      B7,       B5    ; xh1_1  = x3 + x7
||     LDBU   .D1    *A0[A8], B4              ; k1 = brev[j1]
||     MPYSP  .M1    A12,     A13,      A12   ; yt1/n_max
||     MPYSP  .M2    B12,     B13,      B12   ; yt5/n_max
||     SUB    .S2    B0,      4,        B0    ; Update loop ctr
||     ADD    .S1X   B11,     0,        A8    ; k' = k

   [B0]LDDW   .D1T1  *A9++[2],A5:A4           ; load x1:x0(xh1_0:xh0_0)
|| [B0]LDDW   .D2T2  *B3++[2],B5:B4           ; load x3:x2(xh1_1:xh0_1) 
||[!A2]SUBSP  .L1    A4,      A6,       A6    ; xl0_0  = x0 - x4
||[!A2]SUBSP  .L2    B7,      B5,       B6    ; xl1_1  = x7 - x3
||     MPYSP  .M1    A12,     A13,      A12   ; yt2/n_max
||     MPYSP  .M2    B12,     B13,      B12   ; yt6/n_max
|| [B0]B      .S2    LOOP1                    ; BRANCH TO LOOP
||     MV     .S1X   B10,     A10             ; y' = y

   [B0]LDDW   .D1T1  *A9++[2],A7:A6           ; load x5:x4(xl1_0:xl0_0)
|| [B0]LDDW   .D2T2  *B3++[2],B7:B6           ; load x7:x6(xl1_1:xl0_1)
||[!A2]SUBSP  .L1    A5,      A7,       A7    ; xl1_0  = x1 - x5
||[!A2]SUBSP  .L2    B4,      B6,       B7    ; xl0_1  = x2 - x6
||     ADD    .S1    A3,      1,        A3    ; j++
||     MPYSP  .M1    A12,     A13,      A12   ; yt3/n_max
||     MPYSP  .M2    B12,     B13,      B12   ; yt7/n_max

       ADDSP  .L1X   A4,      B4,       A12   ; yt0  = xh0_0 + xh0_1   
||     SUBSP  .L2X   A4,      B4,       B12   ; yt4  = xh0_0 - xh0_1
||     STW    .D1T1  A12,     *++A10[A8]      ; y0[k] = yt0/n_max
||     STW    .D2T2  B12,     *++B9[B11]      ; y0[k+n_max] = yt4/n_max

       ADDSP  .L1X   A5,      B5,       A12   ; yt1  = xh1_0 + xh1_1
||     SUBSP  .L2X   A5,      B5,       B12   ; yt5  = xh1_0 - xh1_1
||     SHL    .S2    B11,     6,        B11   ; k0 << 6
||     STW    .D1T1  A12,     *+A10[1]        ; y0[k+1] = yt1/n_max 
||     STW    .D2T2  B12,     *+B9[1]         ; y0[k+1+n_max] = yt5/n_max

       ADDSP  .L1X   A6,      B6,       A12   ; yt2  = xl0_0 + xl1_1
||     SUBSP  .L2X   A6,      B6,       B12   ; yt6  = xl0_0 - xl1_1
||     ADD    .S2    B11,     B4,       B11   ; k = (k0 << 6) +  k1
||     STW    .D1T1  A12,     *++A10[A1]      ; y0[k+n_max/2] = yt2/n_max
||     STW    .D2T2  B12,     *++B9[B1]       ; y0[k+3*n_max/2] = yt6/n_max

       CLR    .S1    A3,      6,        31, A8; j0 = (j     ) & 0x3F
||     ADDSP  .L1X   A7,      B7,       A12   ; yt3  = xl1_0 + xl0_1
||     SUBSP  .L2X   A7,      B7,       B12   ; yt7  = xl1_0 - xl0_1     
||     SHR    .S2    B11,     B2,       B11   ; k = k >> l0
||     STW    .D1T1  A12,     *+A10[1]        ; y0[k+1+n_max/2] = yt3/n_max
||     STW    .D2T2  B12,     *+B9[1]         ; y0[k+1+3*n_max/2] = yt7/n_max
            
*--------------------- END OF PIPED LOOP KERNEL ----------------------------------------

; POP OUT THE DATA
END:          
       MV     .S1X   B15,     A1              ; copy stack pointer
||     LDW    .D2T2  *B15[14],B4              ; load irp into b4

       LDW    .D2T2  *B15[12],B3              ; load b3
||     LDW    .D1T1  *A1[13], A15             ; load a15

       LDW    .D2T2  *B15[1], B10             ; load b10
||     LDW    .D1T1  *A1[6],  A10             ; load a10

       LDW    .D2T2  *B15[2], B11             ; load b11
||     LDW    .D1T1  *A1[7],  A11             ; load a11

       LDW    .D2T2  *B15[3], B12             ; load b12
||     LDW    .D1T1  *A1[9],  A12             ; load a12

       LDW    .D2T2  *B15[4], B13             ; load b13
||     LDW    .D1T1  *A1[10], A13             ; load a13

       LDW    .D1T2  *A1[5],  B14             ; load b14
||     LDW    .D2T1  *B15[22],A1              ; load csr                   
||     B      .S2    B3                       ; return

       MVC    .S2    B4,      IRP             ; load irp
||     LDW    .D1T1  *A1[11], A14             ; load a14
                
       ADDAW  .D2    B15,     24,       B15   ; return back stack space
        
       NOP           2
        
       MVC    .S2    A1,      CSR             ; enable interrupts
       ;BRANCH TO OUTSIDE OCCURS HERE 
                .end

* ======================================================================== *
*  End of file: sp_ifftSPxSP.asm                                           *
* ------------------------------------------------------------------------ *
*          Copyright (C) 2003 Texas Instruments, Incorporated.             *
*                          All Rights Reserved.                            *
* ======================================================================== *

