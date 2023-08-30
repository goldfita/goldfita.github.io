//how to pass an array of pointers

#include <stdio.h>

//size of array unknown
void foo1(char const **s, int len)
{
    int i;
    for(i=0; i<len; i++)
        puts(s[i]);
    //will not compile
    //s[i][0] = 'k';    
}

//size known (pointer to array of pointers)
void foo2(char const *(*s)[3])
{
    int i;
    for(i=0; i<3; i++)
        puts((*s)[i]);
    //will not compile
    //(*s)[i][0] = 'j';
}

int main(void)
{
    char const *s[3] = {"one","two","three"};
    foo1(s,3);
    foo2(&s);
    return 0;
}

