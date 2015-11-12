%{
#include <stdlib.h>
#include "ast.h"
#include "yacc.h"
#include "auxiliary.h"

#define MAXSTR 20
#define MAXMEMBER 100

#define INTTYPE  0
#define REALTYPE 1

int yyerror(char*);

// define in ast.c
extern struct node root;
extern struct node *tmprtn;

extern int yylex();
extern FILE* yyin;
extern char str1[20];

extern NXQ;
extern int VarCount;
extern struct QUATERLIST QuaterList[MAXMEMBER];
extern struct VARLIST VarList[MAXMEMBER];

int flag_var_def = 0;
%}
%start    ProgDef
%union 
{
 struct {
	 union{
		 int Iv;
		 int CH;
		 int NO;
		 struct { int TC,FC;} _BExpr;
		 struct { int QUAD,CH;} _WBD;
		 struct { int type,place; union{int Iv;float Rv;} Value;} _Expr;
		 char _Rop[5];
		 int First;
	 } attr;
 	struct node *Node;
 } all;
 char str[20];
}
/*Define const:  */
%token <str>   	Iden    300
%token <str>   	IntNo		301
%token <str>  	RealNo  302
/*Define keywords here:*/
%token	<str>  	Program 400
%token	<str>  	Begin		401
%token	<str> 	End			402
%token	<str>  	Var			403
%token	<str>  	Integer 404
%token	<str>  	Real		405
%token	<str>  	While		406
%token	<str>  	Do			407
%token	<str>		If			408
%token	<str>		Then		409
%token	<str>		Else		410
%token	<str>		Or			411
%token	<str>		And			412
%token	<str>		Not			413
/*Define double_character terminates:   */
%token		LE	500
%token		GE	501
%token		NE	502

%left 	Or
%left		And
%nonassoc  	Not
%nonassoc '<' '>' '=' LE GE NE
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS


%type <all> ProgDef	//ast_node
%type <all> SubProg	//ast_node
%type <all> VarDef	//CH
%type <all> VarDefList	//CH
%type <all> Type	//Iv
%type <all> VarDefState	//CH
%type <all> VarList	//First
%type <all> Statement	//CH
%type <all> StateList	//CH
%type <all> S_L	//CH
%type <all> CompState	//CH
%type <all> AsignState	//CH
%type <all> ISE	//CH
%type <all> IBT	//IBT
%type <all> WBD	//_WBD
%type <all> RelationOp	//_Rop
%type <all> Expr 	//_Expr
/*%type <CH> BAND	
%type <CH> BOR*/
%type <all> Wh	//CH
%type <all> Variable //NO
%type <all> Const //_Expr
%type <all>	BoolExpr //_BExpr


%%
ProgDef:	Program Iden {set_node_val_str(&root,str1);} ';' SubProg '.'
          {
		      struct node *tmpnode=NULL;
              //printf("\n\n**** test ast node ****\n\n");
			  $$.Node=&root;
			  $$.Node->type=e_program;
			  tmpnode=$5.Node;
			  add_son_node(&root,$5.Node);
			  printf("\n\n**** Program %s ****\n",root.val.str);
          }
	;
SubProg:	VarDef CompState
		{
		new_node(&($$.Node));
		$$.Node->type = e_sub_prog;
		set_node_val_str($$.Node, "SubProg");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $2.Node);
		}
	;
VarDef:		Var VarDefList ';'
        {
		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_var_def;
		set_node_val_str($$.Node, "Var");
		add_son_node($$.Node, $2.Node);
		}
	;
VarDefList:	VarDefList';'VarDefState
        {
		/* =========================== */
		struct node *last = get_last_node($1.Node);
		add_brother_node(last, $3.Node);
		$$.Node = $1.Node;
		}
	|	VarDefState
	    {
		/* =========================== */
		$$.Node = $1.Node;
        }
	;
VarDefState:	VarList':'Type
		{

		int check = 0;
		while ($1.attr.First) {
			VarList[$1.attr.First].type = $3.attr.Iv;
			$1.attr.First = VarList[$1.attr.First].addr;

			if(check++ > MAXMEMBER) {
				printf("** Repeatly define variable **\n");
				exit(0);
			}
		}

		/* =========================== */
		struct node *last = get_last_node($1.Node);
		add_brother_node(last, $3.Node);
		$1.Node->type = e_varlist;
		$$.Node = $1.Node;
		}
	;
Type:		Integer
		{
		//Type <Iv> <int>
		$$.attr.Iv = 0;

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_type_int;
		set_node_val_str($$.Node, "Integer");
		}
	|	Real
		{
		$$.attr.Iv = 1;

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_type_real;
		set_node_val_str($$.Node, "Real");
		}
	;
VarList:	VarList','Variable
		{
		// VarList <First> <int>

		$$.attr.First = $3.attr.NO;
		VarList[$3.attr.NO].addr = $1.attr.CH;

		// check whether variable is repeatedly defined
		//printf("Here! %d ", VarCount);
		//VarCount--;
		


		/* =========================== */
		struct node *last = get_last_node($1.Node);
		add_brother_node(last, $3.Node);
		$$.Node = $1.Node;
		}
	|	Variable
		{
		$$.attr.First = $1.attr.NO;
		VarList[$1.attr.NO].addr = 0;

		
		

		/* =========================== */
		$$.Node = $1.Node;
		}
	;
StateList:	S_L Statement
		{
		$$.attr.CH = $2.attr.CH;

		/* =========================== */
		struct node *last = get_last_node($1.Node);
		add_brother_node(last, $2.Node);
		$$.Node = $1.Node;
		}
	|	Statement
		{
		$$.attr.CH = $1.attr.CH;

		/* =========================== */
		$$.Node = $1.Node;
		}
	;
S_L:		StateList ';'
		{
		backPatch($1.attr.CH, NXQ);

		/* =========================== */
		$$.Node = $1.Node;
		}
	;
Statement:	AsignState
		{
		$$.attr.CH = 0;

		/* =========================== */
		$$.Node = $$.Node;
		}
	|	ISE Statement
		{
		$$.attr.CH = merge($1.attr.CH, $2.attr.CH);

		/* =========================== */
		add_son_node($1.Node, $2.Node);
		$$.Node = $1.Node;
		}
	|	IBT Statement
		{
		$$.attr.CH = merge($1.attr.CH, $2.attr.CH);

		/* =========================== */
		add_son_node($1.Node, $2.Node);
		$$.Node = $1.Node;
		}
	|	WBD Statement
		{
		backPatch($2.attr.CH, $1.attr._WBD.QUAD);
		gen("j", 0, 0, $1.attr._WBD.QUAD);
		$$.attr.CH = $1.attr._WBD.CH;

		/* =========================== */
		add_son_node($1.Node, $2.Node);
		$$.Node = $1.Node;
		}
	|	CompState
	    {
		$$.attr.CH = $1.attr.CH;

		/* =========================== */
		$$.Node = $1.Node;
		}
	|	{
	    }
	;
CompState:	Begin StateList End
		{
		$$.attr.CH = $2.attr.CH;

		new_node(&($$.Node));
		$$.Node->type = e_compstat;
		set_node_val_str($$.Node, "begin_end");
		add_son_node($$.Node, $2.Node);
		}
	;
AsignState:	Variable ':''=' Expr
		{
		gen(":=", $4.attr._Expr.place, 0, $1.attr.NO);

		if (flag_var_def == 0) {
			printf("** undefined variable %s **", VarList[$1.attr.NO].name);
			exit(0);
		}
		
		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_assign_stat;
		set_node_val_str($$.Node, ":=");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $4.Node);
		}
	;
ISE:		IBT Statement Else
		{
		int q = NXQ;
		gen("j", 0, 0, 0);
		backPatch($1.attr.CH, NXQ); // right now, NXQ = q + 1
		$$.attr.CH = merge($2.attr.CH, q);

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_if_then_else_stat;
		set_node_val_str($$.Node, "if_then_else");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $2.Node);
		}
	;
IBT:		If BoolExpr Then
		{
		backPatch($2.attr._BExpr.TC, NXQ); $$.attr.CH = $2.attr._BExpr.FC;

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_if_then_stat;
		set_node_val_str($$.Node, "if_then");
		add_son_node($$.Node, $2.Node);
		}

	;
WBD: Wh BoolExpr Do
		{
		// WBD <_WBD> <QUAD, CH>

		backPatch($2.attr._BExpr.TC, NXQ);
		$$.attr._WBD.CH = $2.attr._BExpr.FC;
		$$.attr._WBD.QUAD = $1.attr.CH;

		/* =========================== */
		add_son_node($1.Node, $2.Node);
		$$.Node = $1.Node;
		}
	;
Wh:		While
        {
		$$.attr.CH = NXQ;

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_while_stat;
		set_node_val_str($$.Node, "while");
        }
	;
Expr:		Expr'+'Expr
		{
		$$.attr._Expr.place = newTemp();
		gen("+", $1.attr._Expr.place, $3.attr._Expr.place, $$.attr._Expr.place);

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_exp;
		set_node_val_str($$.Node, "+");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $3.Node);
		}
	|	Expr'-'Expr
		{
		$$.attr._Expr.place = newTemp();
		gen("-", $1.attr._Expr.place, $3.attr._Expr.place, $$.attr._Expr.place);

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_exp;
		set_node_val_str($$.Node, "-");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $3.Node);
		}
	|	Expr'*'Expr
		{
		$$.attr._Expr.place = newTemp();
		gen("*", $1.attr._Expr.place, $3.attr._Expr.place, $$.attr._Expr.place);

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_exp;
		set_node_val_str($$.Node, "*");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $3.Node);
		}
	|	Expr'/'Expr
		{
		$$.attr._Expr.place = newTemp();
		gen("/", $1.attr._Expr.place, $3.attr._Expr.place, $$.attr._Expr.place);

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_exp;
		set_node_val_str($$.Node, "/");
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $3.Node);
		}
	|	'('Expr')'
		{
		$$.attr._Expr.place = $2.attr._Expr.place;

		/* =========================== */
		$$.Node = $2.Node;
		}
	|	'-' Expr %prec UMINUS
		{
		$$.attr._Expr.place = newTemp();
		gen("-", $2.attr._Expr.place, 0, $$.attr._Expr.place);

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_exp;
		set_node_val_str($$.Node, "-");
		add_son_node($$.Node, $2.Node);
		}
	|	Variable
		{
		$$.attr._Expr.place = $1.attr.NO;

		// undefined error
		if (flag_var_def == 0) {
			printf("** undefined variable %s **", VarList[$1.attr.NO].name);
			exit(0);
		}

		/* =========================== */
		$$.Node = $1.Node;
		}

	|	Const
		{
		$$.attr._Expr.type = $1.attr._Expr.type;
		$$.attr._Expr.place = $1.attr._Expr.place;
		if ($$.attr._Expr.type) {
			$$.attr._Expr.Value.Rv = $1.attr._Expr.Value.Rv;
		} else {
			$$.attr._Expr.Value.Iv = $1.attr._Expr.Value.Iv;
		}

		/* =========================== */
		$$.Node = $1.Node;
		}
	;

BoolExpr:	Expr RelationOp Expr
		{
		$$.attr._BExpr.TC = NXQ; $$.attr._BExpr.FC = NXQ + 1;
		gen($2.attr._Rop, $1.attr._Expr.place, $3.attr._Expr.place, 0);
		gen("j", 0, 0, 0); 

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_bool_exp;
		set_node_val_str($$.Node, &($2.attr._Rop[1]));
		add_son_node($$.Node, $1.Node);
		add_son_node($$.Node, $3.Node);
		}
	|	BoolExpr And
	    {
		backPatch($1.attr._BExpr.TC, NXQ); $$.attr._BExpr.FC = $1.attr._BExpr.FC;
		}
	|	BoolExpr Or
	    {
		backPatch($1.attr._BExpr.FC, NXQ); $$.attr._BExpr.TC = $1.attr._BExpr.TC;
		}	
	|	Not BoolExpr
	    {
		$$.attr._BExpr.TC = $2.attr._BExpr.FC; $$.attr._BExpr.FC = $2.attr._BExpr.TC;

		/* =========================== */
		new_node(&($$.Node));
		$$.Node->type = e_bool_exp;
		set_node_val_str($$.Node, "Not");
		add_son_node($$.Node, $2.Node);
		}
	|	'(' BoolExpr ')'
	    {
		$$.attr._BExpr.TC = $2.attr._BExpr.TC; $$.attr._BExpr.FC = $2.attr._BExpr.FC;

		/* =========================== */
		$$.Node = $2.Node;
		}
	;
Variable:	Iden
		{
		//Variable <NO> <int>
		if (lookUp(str1)) {
			flag_var_def = 1;
		} else {
			flag_var_def = 0;
		}
		$$.attr.CH = entry(str1); 

		/* =========================== */
		new_node(&($$.Node));
		set_node_val_str($$.Node, str1);
		}
	;
Const:		IntNo
		{
		//Const <_Expr> <int, int , int/float>

		$$.attr._Expr.type = 0;
		$$.attr._Expr.place = entry(str1);
		VarList[$$.attr._Expr.place].type = 0;
		$$.attr._Expr.Value.Iv = atoi(str1);

		/* =========================== */
		new_node(&($$.Node));
		set_node_val_str($$.Node, str1);
		}
	|	RealNo
		{
		$$.attr._Expr.type = 1;
		$$.attr._Expr.place = entry(str1);
		VarList[$$.attr._Expr.place].type = 1;
		$$.attr._Expr.Value.Rv = (float)atof(str1);
		
		/* =========================== */
		new_node(&($$.Node));
		set_node_val_str($$.Node, str1);
		}
	;
RelationOp:	'<'
		{
		//RelationOp <_Rop> <char [5]>
		
		strcpy($$.attr._Rop, "j<");
		}
	|	'>'
		{
		strcpy($$.attr._Rop, "j>");
		}	
	|	'='
		{
		strcpy($$.attr._Rop, "j=");
		}
	|	GE
		{
		strcpy($$.attr._Rop, "j>=");
		}
	|	NE
		{
		strcpy($$.attr._Rop, "j!=");
		}
	|	LE
		{
		strcpy($$.attr._Rop, "j<=");
		}
	;

%%