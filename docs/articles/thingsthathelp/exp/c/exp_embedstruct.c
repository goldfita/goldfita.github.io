#include  <stdio.h>

struct foo {
    struct boo {
	int a;
	char b;
    };
    int c;
};


int main(void)
{
    struct foo f;

    *(int *)(&f) = 1;
    *(char *)((int *)(&f)+1) = 'b';
    f.c = 2;
    printf("c is %d\ninner a is %d\ninner b is %c\n\n",f.c,
	   *(int *)(&f),*((char *)((int *)(&f)+1)));
    printf("f (inner a) %x + 4 == f (inner b) %x\n",(int *)(&f),(char *)((int *)(&f)+1));

    /* c appears to have been aligned on the next int */
    printf("address f.c %x != %x\n\n",&f.c,(int *)(((char *)((int *)(&f)+1))+1));

    printf("inner a is %d\ninner b is %c\n",
	   ((struct boo *)(&f))->a,((struct boo *)(&f))->b);
    
    /* Ah, so that's how you access those inner elements. */
    printf("inner a - %d, inner b - %c\n",f.a,f.b);
}
