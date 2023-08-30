#include <stdio.h>

void codeA()
{
    puts("in a");
}

void codeB()
{
    puts("in b");
}

void foo0()
{
    codeA();
    puts("no parameters in foo0");
    codeB();
}

void foo1(int f1)
{
    codeA();
    printf("f1==%d in foo1\n",f1);
    codeB();
}

void foo2(int f1, char *f2)
{
    codeA();
    printf("f1==%d f2==%s in foo2\n",f1,f2);
    codeB();
}

int main(void)
{
    foo0();
    foo1(5);
    foo2(10,"a string");
    return 0;
}
