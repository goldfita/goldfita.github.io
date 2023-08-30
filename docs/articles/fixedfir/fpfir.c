#include "mex.h"

#define NUMTAPS 8
#define toFix(x) ((short)((x)*32768))
#define toFloat(x) (((double)(x))/32768)
short filt[NUMTAPS] = {
    toFix(.8),
    toFix(.7),
    toFix(.6),
    toFix(.5),
    toFix(.4),
    toFix(.3),
    toFix(.2),
    toFix(.1)};

short delays[NUMTAPS];

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int i,j,accum,len,start=0;
    double *sigDBL, *outDBL;
    const mxArray *sig;
    mxArray *out;

    sig=prhs[0];
    sigDBL=mxGetPr(sig);
    len=mxGetScalar(prhs[1]);
    out=mxCreateDoubleMatrix(len,1,mxREAL);
    outDBL=mxGetPr(out);

    for(i=0; i<NUMTAPS; i++)
	delays[i]=0;

    for(j=0; j<len; j++) {
	delays[start]=toFix(sigDBL[j]);
	for(i=0,accum=0; i<NUMTAPS-1; i++) {
	    accum+=filt[i]*delays[start];
	    if(--start<0) start=NUMTAPS-1;
	}
	accum+=filt[NUMTAPS-1]*delays[start];
	outDBL[j]=toFloat(accum>>15);
    }

    if(nlhs>0)
        plhs[0]=out;
    else
        mxDestroyArray(out);
}
