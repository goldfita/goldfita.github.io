#include <stdlib.h>
#include <alloca.h>
#include <stdio.h>

int inc(int i)
{
    int a[50];
    a[0]=5;
    int *f[2]={(int*)malloc(10*sizeof(int)),(int*)alloca(5*sizeof(int))};
    *(f[0]+3)=88;
    *(f[0]+5)=87;
    *(f[1]+0)=86;
    free(f[0]);
    printf("%d %d\n",*(f[1]),a[-10]);
    return i+1;
}

int main(void)
{
    int i=99, k=102;
    {
	int k=101, a[50],k2=102;
	a[0] = 8;
	inc(k+1);
    }
    int j=131,m=123,n=321;
    int b[20];
    b[0]=7;
    if(b[0]==6) {
	int b[40];
	b[0]=0;
	inc(0);
    }
    inc(k+1);

    return inc(i);
}

//http://www.owlnet.rice.edu/~comp320/2003/notes/sparc/stack.html
//http://www.cs.wisc.edu/~fischer/cs701.f05/sparc.htm
//http://www.cs.wisc.edu/~fischer/cs701.f05/asg1.html
