#include <stdio.h>
#include <stdarg.h>

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

void general_foo(void (*foo)(), int opt, ...)
{
    va_list argp;

    codeA();
    va_start(argp,opt);
    if(opt == 0)
        foo();
    else if(opt == 1)
        foo(va_arg(argp,int));
    else if(opt == 2) {
        int arg1 = va_arg(argp,int);
        char *arg2 = va_arg(argp,char *);
        foo(arg1,arg2);
    }
    va_end(argp);
    codeB();
}

int main(void)
{
    general_foo(foo0,0);
    general_foo(foo1,1,5);
    general_foo(foo2,2,10,"a string");
    return 0;
}
