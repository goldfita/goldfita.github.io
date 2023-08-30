/* Todd Goldfinger
 *
 * This is freely distributable.  The author makes
 * absolutely no guarantees whatsoever.
 *
 * FLT stands for 'floating point' implying single precision.
 * This is to distinguish it from Matlab's double precision.
 */
 
/* Select a target computer. */
#define MATLAB 0
#define EMULATOR 1
#define DSP 2
#define TARGET MATLAB
/* Select an algorithm. */
#define CANCEL1 1
#define CANCEL2 2
#define CANCEL CANCEL1

#define BUFFER_COUNT 256
#define FILTER_LEN 1024
#define MU .001

#if TARGET==MATLAB
#define RESTRICT
#else
#define RESTRICT restrict
#endif

void reduceEcho(int refFrame, float * RESTRICT reference, float * RESTRICT input, float * RESTRICT c, float * RESTRICT error);

/* The +3 is needed to ensure that the length of the dot product is always
   a multiple of four no matter which position it starts at. */
float referenceFLT[FILTER_LEN+3];
float inputFLT[BUFFER_COUNT], cFLT[FILTER_LEN+3], errorFLT[BUFFER_COUNT];

#if TARGET==MATLAB
#include "mex.h"
mxArray *lhs[1], *rhs[2];
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    static int refFrame=0;
    double *referenceDBL, *inputDBL, *outDBL, *cDBL, *coutDBL, *errorDBL;
    const mxArray *reference, *input, *c;
    mxArray *error, *cout;
    int i;

    /* Temporary reference to matlab data structures. */
    reference=prhs[0]; /* original (without echo) */
    input=prhs[1];     /* with echo */
    c=prhs[2];         /* adaptive filter */

    /* Allocate arrays and retrieve array pointers. */
    referenceDBL=mxGetPr(reference);
    inputDBL=mxGetPr(input);
    cDBL=mxGetPr(c);
    error=mxCreateDoubleMatrix(BUFFER_COUNT,1,mxREAL);
    errorDBL=mxGetPr(error);
    cout=mxCreateDoubleMatrix(FILTER_LEN,1,mxREAL);
    coutDBL=mxGetPr(cout);

    rhs[0]=mxCreateDoubleMatrix(FILTER_LEN,1,mxREAL);
    rhs[1]=mxCreateDoubleMatrix(FILTER_LEN,1,mxREAL);
    /* Convert from double to single. */
    for(i=0; i<BUFFER_COUNT; i++) {
        referenceFLT[i+refFrame]=referenceDBL[i];
	inputFLT[i]=inputDBL[i];
	cFLT[i]=cDBL[i];
    }
    /* Run LMS, then move to the next frame. */
    reduceEcho(refFrame,referenceFLT,inputFLT,cFLT,errorFLT);
    refFrame=(refFrame+BUFFER_COUNT)&(FILTER_LEN-1);

    mxDestroyArray(lhs[0]);
    mxDestroyArray(rhs[0]);
    mxDestroyArray(rhs[1]);

    /* Convert back to double and return the results. */
    for(i=0; i<BUFFER_COUNT; i++)
	errorDBL[i]=errorFLT[i];
    for(i=0; i<FILTER_LEN; i++)
    	coutDBL[i]=cFLT[i];
    if(nlhs>0)
        plhs[0]=error;
    else
        mxDestroyArray(error);
    if(nlhs>1)
        plhs[1]=cout;
    else
        mxDestroyArray(cout);
}
#elif TARGET==EMULATOR
#include <stdio.h>
#include "DSPF_sp_dotprod.h"
#include "DSPF_sp_dotprod2.h"

#define TEST_BUF 20000
#pragma DATA_SECTION(ref, "sram");
#pragma DATA_SECTION(inp, "sram");
#pragma DATA_SECTION(err, "sram");
#pragma DATA_ALIGN(cFLT, 8);
#pragma DATA_ALIGN(referenceFLT, 8);
float ref[TEST_BUF], inp[TEST_BUF], err[TEST_BUF];
void readfile(char *name, float *buf);
int main()
{
    int i, j, refFrame=0;
    /* Read in test signals into a test buffer.
       The err signal is the output of the matlab
       version of this code. */
    readfile("ref",ref);
    readfile("inp",inp);
    readfile("err",err);
    memset((void*)cFLT,0,sizeof(cFLT));
    memset((void*)referenceFLT,0,sizeof(referenceFLT));
 	
    /*Run through the test buffer comparing the matlab output
      to the emulator output.  They should be identical except
      for numerical differences.  In this case the results were
      exactly the same until around 4000 samples.  I believe 
      this was due to the fact that the matlab version was filtered
      in double precision.  The TI version only had access to 
      the single precision files.  I could not find any bugs to
      exlain the difference.*/
    for(i=0; i<TEST_BUF-FILTER_LEN; i+=BUFFER_COUNT) {
	for(j=0; j<BUFFER_COUNT; j++) {
	    referenceFLT[j+refFrame]=ref[i+j];
	    inputFLT[j]=inp[i+j];
	}
    	reduceEcho(refFrame,referenceFLT,inputFLT,cFLT,errorFLT);
    	for(j=0; j<BUFFER_COUNT; j++)
	    printf("% 10.10f % 10.10f % 10.10f %d\n",err[j+i],errorFLT[j],err[j+i]-errorFLT[j],i);
    	refFrame=(refFrame+BUFFER_COUNT)&(FILTER_LEN-1);
    }
}

void readfile(char *name, float *buf)
{
    FILE *f = fopen(name,"rb");
    fseek(f,0,SEEK_SET);
    fread(buf,sizeof(float),TEST_BUF,f);
    fclose(f);
}

#endif

#if CANCEL==CANCEL2
/* This is the partially optimized version.  I used matlab's dot function
   to find the dot product.  But this is only for demonstration.  Taking a
   dot product is easy, but you might want to do something more complex, 
   like taking the FFT in matlab.  The c67 version uses two different dot 
   product routines due to the limitations of the DSPLIB dotprod function. */
void reduceEcho(int refFrame, float * RESTRICT reference, float * RESTRICT input, float * RESTRICT c, float * RESTRICT error)
{
    int i,j,dlen,tmp;
    float sum=0,step=0;

    for(j=0; j<BUFFER_COUNT; j++) {
#if TARGET==MATLAB
	if((mxGetPr(rhs[0])==0) || (mxGetPr(rhs[1])==0))
	    return;
	for(i=0; i<FILTER_LEN; i++) {
	    *(mxGetPr(rhs[0])+i)=reference[(i+refFrame+j)&(FILTER_LEN-1)];
	    *(mxGetPr(rhs[1])+i)=c[i];
	}
	mexCallMATLAB(1,lhs,2,rhs,"dot");
	sum=mxGetScalar(lhs[0]);
#else
	/* Calculate where to start the dot product. */
	dlen=FILTER_LEN-((j+refFrame)&(FILTER_LEN-1));
	/* If it's even, use the orignal version. */
	if(j%2==0) {
	    sum=DSPF_sp_dotprod(&reference[(j+refFrame)&(FILTER_LEN-1)],c,dlen); 
	    /* Complete the dot product from the start of reference. */
	    if(dlen<FILTER_LEN)
		sum+=DSPF_sp_dotprod(reference,&c[dlen],FILTER_LEN-dlen);
	} else {
	    /* It's odd.  Round the length up to the next multiple of four. */
	    if((dlen%4)!=0) 
		tmp=dlen-(dlen%4)+4;
	    else
		tmp=dlen;
	    sum=DSPF_sp_dotprod2(&reference[(j+refFrame)&(FILTER_LEN-1)],c,tmp); 
	    /* Complete the dot product from the beginning of reference. */
	    if(dlen<FILTER_LEN) {
		/* Make the length a multiple of four again. */
		if(((FILTER_LEN-dlen)%4)!=0)
		    tmp=FILTER_LEN-dlen-((FILTER_LEN-dlen)%4)+4;
		else
		    tmp=FILTER_LEN-dlen;
		sum+=DSPF_sp_dotprod2(&c[dlen],reference,tmp);
	    }
	} 
#endif
	error[j]=input[j]-sum;
	step=MU*error[j];
	for(i=0; i<FILTER_LEN; i++)
	    c[i]+=step*reference[(i+refFrame+j)&(FILTER_LEN-1)];
    }
}


#elif CANCEL==CANCEL1
/* This is the original LMS.  Note that the filter is backwards to 
   simplify index calculations. */
void reduceEcho(int refFrame, float * RESTRICT reference, float * RESTRICT input, float * RESTRICT c, float * RESTRICT error)
{
    int i,j;
    float sum,step;

    for(j=0; j<BUFFER_COUNT; j++) {
	for(i=0,sum=0; i<FILTER_LEN; i++)
	    sum+=c[i]*reference[(i+refFrame+j)&(FILTER_LEN-1)];
	error[j]=input[j]-sum;
	step=MU*error[j];
	for(i=0; i<FILTER_LEN; i++)
	    c[i]+=step*reference[(i+refFrame+j)&(FILTER_LEN-1)];
    }
}
#endif
