#include  <stdio.h>


typedef struct ___pvt {
    int a;
    char b[10];
} __pvt;


#define BASE_OFFSET           \
char __offset[sizeof(__pvt)];


#define PUB_VAR                  \
char c;                          \
void (*foo)();

struct base {
    __pvt __pvt_var;
    PUB_VAR;
};

struct derived1 {
    BASE_OFFSET;
    PUB_VAR;
    int a;
};

struct derived2 {
    BASE_OFFSET;
    PUB_VAR;
    short a;
};

void foo_d1(void* d1, char *s, int i)
{
    printf("Came from %s - %d\n",s,i);
    printf("Member a is %d\n",((struct derived1 *)d1)->a);
}

void foo_d2(void* d2, char *s, void *s2)
{
    printf("Came from %s - %s\n",s,(char *)s2);
    printf("Member a is %d\n",((struct derived2 *)d2)->a);
}

void foo(void* b, char *s)
{
    printf("Came from %s\n",s);
    printf("Member a is %d\n",((struct base *)b)->__pvt_var.a);
}

int main(void)
{
    struct base b, *b1, *b2;
    struct derived1 d1;
    struct derived2 d2;

    d1.foo = &foo_d1;
    d2.foo = &foo_d2;
    b.foo = &foo;

    b.__pvt_var.a = 1;
    strcpy(b.__pvt_var.b,"this is b");
    b.c = 'b';

    d1.c = '1';
    d1.a = 2;

    d2.c = '2';
    d2.a = 5;

    printf("b.__pvt.a==%d\nb.__pvt.b==%s\nb.c==%c\n",b.__pvt_var.a,b.__pvt_var.b,b.c);
    printf("d1.c==%c\nd1.a==%d\n",d1.c,d1.a);
    printf("d2.c==%c\nd2.a==%d\n",d2.c,d2.a);

    b1 = (struct base *)&d1;
    b2 = (struct base *)&d2;
    
    b1->__pvt_var.a = 1;
    strcpy(b1->__pvt_var.b,"this is b");
    printf("b1->__pvt.a==%d\nb1->__pvt.b==%s\nb1->c==%c\n",b1->__pvt_var.a,b1->__pvt_var.b,b1->c);

    d1.foo(&d1,"d1",10);
    d2.foo(&d2,"d2","auxiliary string");
    b1->foo(b1,"b1",10); //this is a base class pointer to derived1
    b2->foo(b2,"b2","auxiliary string"); //this is a base class pointer to derived2
    b.foo(&b,"b");    //this really is base
}
