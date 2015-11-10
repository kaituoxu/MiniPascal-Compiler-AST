# MiniPascal-compiler-AST
MiniPascal-compiler produce symbol table, quaterlist and abstract syntax tree.

## Use it in VS2015:
### Configuration
项目处右键---属性

* 常规---字符集---设为“使用多字符字符集”
* C/C++---预处理器---预处理器定义---  
WIN32;_DEBUG;_CONSOLE;_CRT_SECURE_NO_WARNINGS;%(PreprocessorDefinitions)
* 生成事件---预先生成事件---  
  win_flex -o ast_lex.c --wincompat ast_lex.l  
  win_bison -o ast_yacc.c ast_yacc.y  
  说明：在VS中，新建的工程不能只包含.l和.y文件，记得包含空的.c文件（不包含会怎么样自己可以试试）
* 配置环境变量，把win_flex和win_bison路径加入到环境变量里。  
也可以使用如下的bat文件：  
set path=路径;%path%  
start 项目名.sln  

### Files Description
* ast_lex.l  
词法分析器，用win_flex生成.c文件，
* ast_yacc.y  
语法分析器，用win_bison生成.c文件
* yacc.c  
本应在ast_yacc.y中，为了便于调试，把.y文件中的第三部分独立成一个.c文件
* yacc.h  
与yacc.c相关的头文件，包括结构定义、宏定义
* auxiliary.c  
语法子程序会用到的一些辅助函数
* auxiliary.h  
auxiliary.c的头文件
* ast.c  
生成抽象语法树用到的一些辅助函数
* ast.h  
ast.c的头文件
