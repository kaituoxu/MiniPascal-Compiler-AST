#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <math.h>

#include "ast.h"
#include "yacc.h"
#include "auxiliary.h"

extern int yylex();
extern FILE* yyin;
extern char str1[20];
/*int CheckKeyWord(char *str);*/
int yyparse();
int yyerror(char*);

void OutputQ(void);
void OutputIList(void);
void OutputAST(void);

FILE* fp;

extern int VarCount;
extern int NXQ;  /* used to indicate the number of next Quater*/
extern struct QUATERLIST QuaterList[MAXMEMBER];
extern struct VARLIST VarList[MAXMEMBER];
extern struct node root;
/*int yylex(void)
{
}
*/

int main(int argc, char *argv[])
{
	yyin = stdin;
	init_node(&root);

	if (argc>1) {
		if ((yyin = fopen(argv[1], "r")) == NULL) {
			printf("Can't open file %s\n", argv[1]);
			return -1;
		}
	}

	yyparse();

	OutputQ();

	OutputIList();

	OutputAST();

	return 0;
}

int yyerror(char *errstr)
{
	printf(" %s\n", errstr);
	return 0;
}

void OutputIList(void)
{
	int i = 1;

	printf("\n**** Symbol Table ****\n");
	printf(" No.\t name \t\t   type\n");

	if (i >= VarCount) {
		printf("Symbol Table is NULL!\n");
	}

	for (i = 1;i<VarCount;i++) {
		printf("%4d\t%6s\t\t", i, VarList[i].name);
		if (VarList[i].type) {
			printf(" REAL  \n");
		} else {
			printf(" INTEGER\n");
		}
	}

	return;
}

void OutputQ(void)
{
	int i = 1;

	if (i >= NXQ) {
		printf("no quater exists!\n");
	}

	for (i = 1;i<NXQ;i++) {

		printf("(%3d) ( %5s, ", i, QuaterList[i].op);
		if (QuaterList[i].arg1)
			printf("%6s, ", VarList[QuaterList[i].arg1].name);
		else
			printf("      , ");

		if (QuaterList[i].arg2)
			printf("%6s, ", VarList[QuaterList[i].arg2].name);
		else printf("      , ");

		if ((QuaterList[i].op[0] == 'j') || (QuaterList[i].op[0] == 'S'))
			printf("%6d )\n", QuaterList[i].result);
		else if (QuaterList[i].result)
			printf("%6s )\n", VarList[QuaterList[i].result].name);
		else printf("-\t )\n");
	}

	return;
}

//int tab代表缩进的tab数
void PreOrder(struct node *root, int tab)
{
	int i = 0;
	struct node *son = root->son;
	if (root != NULL) {
		for (i = 0; i < tab - 1; ++i) {
			printf("|\t");
		}
		if (i == tab - 1) {
			printf("|------");
		}
		printf("<%s>\n", root->val.str);
		++tab;
		while (son != NULL) {
			PreOrder(son, tab);
			son = son->next;
		}
	}
}

#define MAX 50
void levelOrder(struct node *root)
{
	struct node *tmp, *son;
	int node_num_cur_level = 0, node_num_next_level = 0;
	//queue
	struct node *Q[MAX];
	int f, r;
	f = r = 0;

	//enqueue
	Q[r] = root;
	r = (r + 1) % MAX;
	++node_num_cur_level;

	//loop when queue is not empty
	while (!(f == r)) {
		//dequeue
		tmp = Q[f];
		f = (f + 1) % MAX;
		
		//process tmp
		printf("| %s |", tmp->val.str);
		//
		son = tmp->son;
		while (son != NULL) {
			//enqueue
			Q[r] = son;
			r = (r + 1) % MAX;
			son = son->next;

			if (node_num_cur_level > 0) {
				++node_num_next_level;
			}
		}
		--node_num_cur_level;
		if (node_num_cur_level == 0) {
			printf("\n");
			node_num_cur_level = node_num_next_level;
			node_num_next_level = 0;
		}
	}
}
void OutputAST(void)
{
	printf("\n**** Abstract Sytax Tree ****\n");
	//levelOrder(&root);
	//printf("\n");
	PreOrder(&root, 0);
}
