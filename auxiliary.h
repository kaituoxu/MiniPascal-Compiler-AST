#pragma once
#ifndef __AUXILIARY_H__
#define __AUXILIARY_H__

int lookUp(char *Name);
int enter(char *Name);
int entry(char *Name);
int newTemp(void);
void gen(char *op, int arg1, int arg2, int result);
int merge(int p1, int p2);
void backPatch(int p, int t);

#endif
