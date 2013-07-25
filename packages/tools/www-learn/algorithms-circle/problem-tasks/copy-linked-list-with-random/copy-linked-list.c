#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
struct Node
{
        int data;
        struct Node *next;
        struct Node *arb;
};
 
typedef struct Node Node;
typedef Node* list;
 
Node* dupNode(Node *p)
{
        Node *temp = malloc(sizeof(Node));
 
        memcpy(temp, p, sizeof(Node));
        p->next = temp;
 
        return temp;
}
 
list copyList(list l)
{
        Node *p;
        Node *temp;
 
        if(!l) return NULL;
 
        for(p = l; p ; p = temp->next)
        {
                temp = dupNode(p);
        }
 
        for(p = l; p ; p = p->next->next)
        {
                if(p->arb)
                        p->arb = p->arb->next;
        }
 
        Node *newlist = l->next;
 
        for(p = l; p ; p = p->next)
        {
                temp = p->next;
                p->next = temp->next;
                if(temp->next)
                        temp->next = temp->next->next;
        }
 
        return newlist;
}
 
Node *insertNode(list l, int elm)
{
        Node *temp = malloc(sizeof(Node));
        temp->next = NULL;
        temp->arb = NULL;
        temp->data = elm;
 
        if(!l)
                return temp;
        temp->next = l->next;
        l->next = temp;
        temp->arb = l->next;
        return l;
}
 
void print(list l)
{
        for(; l ; l = l->next)
                printf("%d\n", l->data);
}
 
int main()
{
        list l = NULL;
        int i;
 
        for(i = 0; i < 10; ++i)
        {
                l = insertNode(l,i);
        }
 
        print(l);
        list n = copyList(l);
        print(n);
}
