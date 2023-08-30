#ifndef DSPF_SP_IFFTSPXSPSCALE_
#define DSPF_SP_IFFTSPXSPSCALE_ 1

void DSPF_sp_ifftSPxSPscale(
                       int N,
                       float * x,
                       float * w,
                       float * y,
                       unsigned char * brev,
                       int n_min,
                       int offset,
                       int n_max
                       );

#endif
