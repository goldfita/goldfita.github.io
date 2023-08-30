
#define matlab 0
#define asterisk 1
#define platform matlab
#define BUFSIZE 160

void init();
void AGC(int *in, int *out);

#if platform==matlab
#include "mex.h"
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{
    static int start=0;
    double *inDBL, *outDBL;
    int i,in[BUFSIZE],out[BUFSIZE];
    mxArray *o;
    
    if(start==0) { start++; init(); }

    inDBL=mxGetPr(prhs[0]);
    o=mxCreateDoubleMatrix(BUFSIZE,1,mxREAL);
    outDBL=mxGetPr(o);

    for(i=0; i<mxGetM(prhs[0]); i++)
	in[i]=(int)inDBL[i];

    AGC(in,out);

    for(i=0; i<BUFSIZE; i++)
        outDBL[i]=out[i];
    if(nlhs>0)
        plhs[0]=o;
    else
        mxDestroyArray(o);	
}
#endif

void AGC(int *in, int *out)
{
    int i;
    float mag=0;

    for(i=0; i<BUFSIZE; i++)
	mag += abs(in[i]);
printf("%f \n",mag);
    if(mag>250*BUFSIZE) {
	for(i=0; i<BUFSIZE; i++) //{
	    out[i] = (int)(in[i]/(mag/500000));//printf("%d\n",out[i]);}
    } else {
	for(i=0; i<BUFSIZE; i++)
	    out[i] = 0;
    }
}

void init()
{
    /* initialization here */
}
