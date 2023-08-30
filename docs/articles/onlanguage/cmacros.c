#include <stdio.h>

#define general_foo(foo) \
    codeA();             \
    foo;                 \
    codeB();


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
    puts("no parameters in foo0");
}

void foo1(int f1)
{
    printf("f1==%d in foo1\n",f1);
}

void foo2(int f1, char *f2)
{
    printf("f1==%d f2==%s in foo2\n",f1,f2);
}

int main(void)
{
    general_foo(foo0());
    general_foo(foo1(5));
    general_foo(foo2(10,"a string"));
    return 0;
}
