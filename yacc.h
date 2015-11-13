#pragma once
#ifndef __YACC_H__
#define __YACC_H__

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#define MAXSTR 20
#define MAXMEMBER 100

#define INTTYPE  0
#define REALTYPE 1

struct QUATERLIST {
	char op[6];
	int arg1, arg2, result;
};

struct arr_info {
	int DIM;
	int *Vector;//Vector[0]´æ·ÅC
};
struct VARLIST {
	char name[20];
	int type;	//IF type is REAL THEN type = 1, ELSE IF type is INTEGER type = 0
	int addr;
	struct arr_info *ADDR;
	/*union{int Iv;float Rv;} Value;*/
};

#endif