#include "auxiliary.h"
#include "yacc.h"

// define in yacc.c
int VarCount = 1;
int tempVarCount = 1;
int NXQ = 1;
struct QUATERLIST QuaterList[MAXMEMBER];
struct VARLIST VarList[MAXMEMBER];



/*****************************
 * Find symbol table 
 * if successfully find entry, return its index(from 0)
 * else return -1  
 *****************************/
int lookUp(char *Name)
{
	int i;
	for (i = 1; i < VarCount; ++i) {
		if (!strcmp(Name, VarList[i].name)) {
			return i;
		}
	}
	return 0;
}

/*****************************
 * Add new entry to symbol table
 *****************************/
int enter(char *Name)
{
	//printf("* %s *", Name);
	strcpy(VarList[VarCount].name, Name);
	VarList[VarCount].type = 0; // default type is INTEGER
	return VarCount++;
}

/*****************************
 * Find or Add symbol table 
 * if dont find entry, then add it to symbol table.
 *****************************/
int entry(char *Name)
{
	int i = lookUp(Name);
	if (i > 0) {
		return i;
	} else {
		return enter(Name);
	}
}

int newTemp(void)
{
	char temp[5];
	sprintf(temp, "T%d", tempVarCount);
	strcpy(VarList[MAXMEMBER - tempVarCount].name, temp);
	VarList[MAXMEMBER - tempVarCount].type = 0;
	return MAXMEMBER-(tempVarCount++);
}

/*****************************
 * 产生四元式
 * 每执行一次，均执行NXQ++
 *****************************/
void gen(char *op, int arg1, int arg2, int result)
{
	strcpy(QuaterList[NXQ].op, op);
	QuaterList[NXQ].arg1 = arg1;
	QuaterList[NXQ].arg2 = arg2;
	QuaterList[NXQ].result = result;
	NXQ++;
}

/*****************************
 * 将链首“指针”分别为p1和p2的两条链合并为一条
 * 并返回新联的链首“指针”
 * 此处的指针实际上是四元式的序号，为整数值
 *****************************/
int merge(int p1, int p2)
{
	int p;
	if (!p2) { // p2 = 0即第二条链为空
		return p1;
	} else {
		//find the last quadruple of chain p2
		p = p2;
		while (QuaterList[p].result) {
			p = QuaterList[p].result;
		}
		// append p1 to p2
		QuaterList[p].result = p1;
		return p2;
	}
}

/*****************************
 * 用四元式序号t回填以p为首的链
 * 将链中每个四元式的Result域改写为t的值 
 *****************************/
void backPatch(int p, int t)
{
	int q = p, q1;
	while (q) {
		q1 = QuaterList[q].result;
		QuaterList[q].result = t;
		q = q1;
	}
	return;
}

/*****************************
 * 计算并填写符号表第NO登记项ADDR域所指的内情向量中的C值
 * C（CONSTPART）
 *****************************/
void FillArrMSG_C(int NO)
{
	int n = VarList[NO].ADDR->DIM;
	int C = 0, j, k, mul;
	for (j = 1; j < n; ++j) {
		mul = 1;
		for (k = j + 1; k < n + 1; ++k) {
			mul *= VarList[NO].ADDR->Vector[3*k + 1];
		}
		C += VarList[NO].ADDR->Vector[3 * j - 1] * mul;
	}
	VarList[NO].ADDR->Vector[0] = C;
}

/*****************************
* 取数组C值
*****************************/
int Access_C(int no)
{
	return VarList[no].ADDR->Vector[0];
}

/*****************************
 * 这里有待完善
 *****************************/
int Access_a(int no)
{
	return VarList[no].ADDR;
}

/*****************************
 * 取数组第k维的界差
 *****************************/
int Access_d(int no, int k)
{
	return VarList[no].ADDR->Vector[3 * k + 1];
}