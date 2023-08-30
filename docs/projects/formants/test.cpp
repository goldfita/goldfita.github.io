#include <stdio.h>	
#include "boardprocessor.h"
#include "c:\Program Files\Matlab7\extern\include\mex.h"

#import "c:\CCStudio\cc\bin\rtdxint.dll"
using namespace RTDXINTLib;


#define Success 0x0
#define EOLF 0x80030002
#define FAIL 0x80004005
#define WARNING 0x80004004
#define NODATA 0x8003001E

IRtdxExpPtr rtdx;
void get(double *out, int num);
int open();
void close();

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
    mxArray *param, *out;
	double p, *outDBL;

    param=prhs[0];
    p = mxGetScalar(param);
	if(p==0) {
		out = mxCreateDoubleMatrix(1,1,mxREAL);
		outDBL = mxGetPr(out);
		*outDBL = (double)open();
	} else if(p<0)
		close();
	else {
		out = mxCreateDoubleMatrix(p,1,mxREAL);
		outDBL = mxGetPr(out);
		get(outDBL,p);
	}

	if(p>=0) {
		if(nlhs>0)
			plhs[0]=out;
		else
			mxDestroyArray(out);
	}
}

void get(double *out, int num)
{
	long status=0;
	short val;
	int i=0;
	
	for(i=0; i<num; i++)
		out[i]=-1;
	i=0;
	while(i<num) {
		status = rtdx->ReadI2(&val);
		if(status==Success)
			out[i++]=val;
		else {
			return;
		}
	}
}

int open()
{
	long status;
	HRESULT hr;
	CBoardProcessor boardproc;
	TCHAR BoardName[MAX_PATH];
	TCHAR ProcessorName[MAX_PATH];

	::CoInitialize(NULL);
	if (boardproc.GetBoard((TCHAR*)&BoardName) == FALSE) {
		cerr << _T("\n*** Error: Unable to get desired board!.\n***");
		return -1;
	}
	if (boardproc.GetProcessor((TCHAR*)&BoardName,(TCHAR*)&ProcessorName) == FALSE) {
		cerr << _T("\n*** Error: Unable to get desired processor!.\n***");
		return -1;
	}
	//BSTR board=::SysAllocString(L"C6xxx EVM (Texas Instruments)");
	//BSTR processor=::SysAllocString(L"TMS320C6713EVM");
	hr = rtdx.CreateInstance(__uuidof(RTDXINTLib::RtdxExp));
	if (FAILED(hr))
		return hr;
	//status = rtdx->SetProcessor(board,processor);
	status = rtdx->SetProcessor(T2BSTR(BoardName),T2BSTR(ProcessorName));
	printf("status %ld (1)\n",status);
	if (status!=Success)
		return -1;
	status = rtdx->ConfigureRtdx(1,1024,4);
	printf("status %ld (2)\n",status);
	if(status!=Success)
		return -1;
	status = rtdx->EnableRtdx();
	printf("status %ld (3)\n",status);
	if(status!=Success)
		return -1;
	status = rtdx->Open("ochan","r");
	printf("status %ld (4)\n",status);
	if(status!=Success)
		return -1;
	return 1;
}

void close()
{
	rtdx->DisableRtdx();
	rtdx->Close();
}