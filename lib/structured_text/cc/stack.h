#ifndef __STACK_H__
#define __STACK_H__

typedef struct {
    void *elems;
    int elemSize;
    int logLength;
    int allocLength;
} stack;

void StackInit(stack *s, int elemSize);
void StackFree(stack *s);
int StackEmpty(stack *s);
void StackPush(stack *s, const void *elemPtr);
void StackPop(stack *s);
const void *StackTop(stack *s);

#endif /* __STACK_H__ */



