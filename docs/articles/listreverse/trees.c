/* Todd Goldfinger
   5/7/2006

   This is in the public domain.

   Traverse trees in in-order.

   gcc trees.c -o trees */

#include <stdio.h>
#include <stdlib.h>

struct tree {
    int data;
    struct tree *left;
    struct tree *right;
};

// lazy man's stack
int ind = 0;
struct tree *stack[128];


int make_tree(struct tree **t, int level, int *num);
void free_tree(struct tree *t);
void in_order1(struct tree *t);
void in_order2(struct tree *t);
void in_order3(struct tree *curr);
void push(struct tree *t);
struct tree *pop(void);

int main(void)
{
    struct tree *t;
    int num = 0;

    make_tree(&t,5,&num);
    in_order1(t);
    puts("");

    in_order2(t);
    puts("");

    in_order3(t);
    puts("");

    return 0;
}

//recursive, implicit stack (this was obvious)
void in_order1(struct tree *t)
{
    if(t) {
        in_order1(t->left);
        printf("%d ",t->data);
        in_order1(t->right);
    }
}

//iterative, explicit stack (this took forever)
void in_order2(struct tree *t)
{
    while(1) {
        if(t) {
            push(t);
            t = t->left;
        } else {
            do {
                if(!(t=pop()))
                   return;
                printf("%d ",t->data);
            } while(!t->right);
            t = t->right;
        }
    }
}

//iterative, no stack (destroys tree)
void in_order3(struct tree *curr)
{
    struct tree *prev=NULL,*next=curr->left;

    curr->left = NULL;
    while(1) {
        if(next) {
            prev = curr;
            curr = next;
            next = next->left;
            curr->left = prev;
        } else {
            do {
                printf("%d ",curr->data);
                next = curr;
                curr = prev;
                if(!prev)
                    return;
                prev = prev->left;
            } while(!curr->right);
            printf("%d ",curr->data);
            next = curr->right;
            curr = next;
            next = next->left;
            curr->left = prev;
        }
    }
}

void push(struct tree *t)
{
    stack[ind++] = t;
}

struct tree *pop(void)
{
    return ind<=0? NULL: stack[--ind];
}

int make_tree(struct tree **t, int level, int *num)
{
    if(!level)
        return 0;
    if(!(*t = malloc(sizeof(struct tree *))))
        return -1;
    
    if(make_tree(&(*t)->left,level-1,num) == -1)
        return -1;
    (*t)->data = (*num)++;
    return make_tree(&(*t)->right,level-1,num);
}

void free_tree(struct tree *t)
{
    //eh, this is an exercise for the reader
}
