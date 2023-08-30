/* Todd Goldfinger
   5/3/2006

   This is in the public domain.

   Reverses lists.  Note that some implementations will fail on very
   short lists.  It may be possible to simplify some implementations
   by using a sentinel value.
   gcc reverse.c -o reverse */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* I'm using this as both a stack and a list.  But I've only
   implemented the stack interface.  I didn't need the list interface
   for anything. */
struct list {
    void *data;
    struct list *next;
};

void test_stack(void);
void test_reverse(void);
void time_reverse(void);
struct list **reverse1(struct list *head, struct list **start);
struct list *reverse2(struct list *head);
struct list *reverse3(struct list *head);
struct list *reverse4(struct list *head);
void reverse5(struct list *head);
int push(struct list **top, void *data);
int pop(struct list **top, void **data);
void display_forwards(struct list *top, void (*disp)(void *));
void display_backwards(struct list *top, void (*disp)(void *));
void disp_int(void *data);

struct list *create(void)
{
    return NULL;
}

int push(struct list **top, void *data)
{
    struct list *new = malloc(sizeof(struct list));
    if(!new)
        return -1;
    new->next = *top;
    *top = new;
    new->data = data;
    return 0;
}

int pop(struct list **top, void **data)
{
    struct list *tmp=*top;

    if(*top == NULL)
        return -1;
    *data = (*top)->data;
    *top = (*top)->next;
    free(tmp);
    return 0;
}

void disp_int(void *data)
{
    printf("%d ",*(int *)data);
}

//think of this as the stack version
void display_forwards(struct list *top, void (*disp)(void *))
{
    if(top) {
        disp(top->data);
        display_forwards(top->next,disp);
    }
}

//think of this as the list version
void display_backwards(struct list *top, void (*disp)(void *))
{
    if(top) {
        display_backwards(top->next,disp);
        disp(top->data);
    }
}

int main(void)
{
    test_stack();
    test_reverse();
    time_reverse();
    return 0;
}


//recursive, implicit stack, elegant
struct list **reverse1(struct list *head, struct list **start)
{
    if(!head->next)
        *start = head;
    else
        *reverse1(head->next,start) = head;
    return &head->next;
}

//recursive, implicit stack, nicer interface
struct list *reverse2(struct list *head)
{
    if(!head->next->next) {
        head->next->next = head;
        struct list *tmp = head->next;
        head->next = NULL;
        return tmp;
    }

    struct list *start = reverse2(head->next);
    head->next->next = head;
    head->next = NULL;
    return start;
}

//iterative, no stack
struct list *reverse3(struct list *head)
{
    struct list *tmp,*next=head->next,*nextnext=head->next->next;

    head->next = NULL;
    while(nextnext) {
        tmp = nextnext->next;
        next->next = head;
        head = next;
        next = nextnext;
        nextnext = tmp;
    }
    next->next = head;
    return next;
}

//iterative, explicit stack, pointers
struct list *reverse4(struct list *head)
{
    struct list *tmp,*stack = create();
    void *data;

    push(&stack,head);
    while(head=head->next)
        push(&stack,head);
    pop(&stack,&data);
    head = tmp = data;
    while(pop(&stack,&data) == 0) {
        head->next = data;
        head = head->next;
    }
    head->next = NULL;
    return tmp;
}

//iterative, explicit stack, data (in place)
void reverse5(struct list *head)
{
    struct list *tmp=head,*stack = create();

    while(tmp) {
        push(&stack,tmp->data);
        tmp = tmp->next;
    }
    tmp = head;
    while(pop(&stack,&tmp->data) == 0)
        tmp = tmp->next;
}

void test_stack(void)
{
    struct list *stack = create();
    int i,*data=malloc(sizeof(int)*10);
    void *tmp;//see http://c-faq.com/ptrs/genericpp.html

    for(i=0; i< 10; i++) {
        data[i] = i;
        push(&stack,&data[i]);
    }
    display_forwards(stack,disp_int);
    puts("");
    display_backwards(stack,disp_int);
    puts("");
    for(i=0; i<10; i++) {
        pop(&stack,&tmp);
        printf("data%d %d\n",i,*(int *)tmp);
    }
    free(data);
}

void test_reverse(void)
{
    struct list *l = create();
    int data[8] = {1,2,3,4,5,6,7,8};
    void *tmp;

    push(&l,&data[0]);
    push(&l,&data[1]);
    push(&l,&data[2]);
    push(&l,&data[3]);
    push(&l,&data[4]);
    push(&l,&data[5]);
    push(&l,&data[6]);
    push(&l,&data[7]);

    puts("original reverse1");
    display_backwards(l,disp_int);
    puts("");
    *reverse1(l,&l) = NULL;
    puts("reversed");
    display_backwards(l,disp_int);
    puts("\n");

    puts("original reverse2");
    display_backwards(l,disp_int);
    puts("");
    l = reverse2(l);
    puts("reversed");
    display_backwards(l,disp_int);
    puts("\n");

    puts("original reverse3");
    display_backwards(l,disp_int);
    puts("");
    l = reverse3(l);
    puts("reversed");
    display_backwards(l,disp_int);
    puts("\n");

    puts("original reverse4");
    display_backwards(l,disp_int);
    puts("");
    l = reverse4(l);
    puts("reversed");
    display_backwards(l,disp_int);
    puts("\n");

    puts("original reverse5");
    display_backwards(l,disp_int);
    puts("");
    reverse5(l);
    puts("reversed");
    display_backwards(l,disp_int);
    puts("\n");

    //free memory
    pop(&l,&tmp);
    pop(&l,&tmp);
    pop(&l,&tmp);
    pop(&l,&tmp);
    pop(&l,&tmp);
    pop(&l,&tmp);
    pop(&l,&tmp);
    pop(&l,&tmp);
}

void time_reverse(void)
{
#define LEN 100000
#define NUM_TIMES 1000
    clock_t c;
    struct list *l = create();
    int i,*data=malloc(sizeof(int)*LEN);
    void *tmp;

    for(i=0; i< LEN; i++) {
        data[i] = i;
        push(&l,&data[i]);
    }
    

    c = clock();
    for(i=0; i<NUM_TIMES; i++)
        *reverse1(l,&l) = NULL;
    printf("Reverse1: %d seconds\n", (clock()-c)/CLOCKS_PER_SEC);
    
    c = clock();
    for(i=0; i<NUM_TIMES; i++)
        l = reverse2(l);
    printf("Reverse2: %d seconds\n", (clock()-c)/CLOCKS_PER_SEC);

    c = clock();
    for(i=0; i<NUM_TIMES; i++)
        l = reverse3(l);
    printf("Reverse3: %d seconds\n", (clock()-c)/CLOCKS_PER_SEC);

    c = clock();
    for(i=0; i<NUM_TIMES; i++)
        l = reverse4(l);
    printf("Reverse4: %d seconds\n", (clock()-c)/CLOCKS_PER_SEC);

    c = clock();
    for(i=0; i<NUM_TIMES; i++)
        reverse5(l);
    printf("Reverse5: %d seconds\n", (clock()-c)/CLOCKS_PER_SEC);
    
    for(i=0; i<LEN; i++)
        pop(&l,&tmp);
    free(data);    
}
