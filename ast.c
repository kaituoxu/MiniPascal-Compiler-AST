#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "ast.h"

/****************************************
  root节点是全局变量。其他需要使用的地方
需定义为extern struct node root。
*****************************************/
struct node root;/*整个AST的根节点。该节点不允许有
                   兄弟节点，即root.next==NULL*/

/***************************************
  init_node函数负责对nd节点进行初始化
****************************************/
int init_node(struct node *nd)
{
    if(NULL==nd)
        return NULL_NODE_POINTER;
    else if(nd!=NULL)
    {
        nd->type=e_null_node;
        nd->val.str=NULL;
        nd->son=NULL;
        nd->parent=NULL;
        nd->next=NULL;
    }
    return INIT_NODE_SUCCESS;
};


/************************************************
  添加兄弟节点时，只能从parent->son处开始添加
*************************************************/
int add_son_node(struct node *parent, struct node *son)
{
    if(NULL!=parent && NULL!=son)
    {
        if(parent->son==NULL)/*parent还没有添加子节点*/
        {
            parent->son=son;
			son->parent = parent;// KTX
        }
        else/*parent已经有若干子节点，则将son添加到该链的末尾*/
        {
            struct node *tmp_node=parent->son;
            
            while(NULL!=tmp_node->next)
            {
                tmp_node=tmp_node->next;
            }/*本循环负责查找最后一个兄弟节点*/
            
            tmp_node->next=son;/*如果son是已经识别出来的
                                 一个序列，则son可能有其
                                 兄弟节点。故此处不需要将
                                 son->next设置为NULL*/
            son->parent=parent;/*建立son和parent的映射关系*/
//            tmp_node->next=son;
        }
        return ADD_SON_NODE_SUCCESS;
    }
    else
    {
        return NULL_NODE_POINTER;
    }
    
    return ADD_SON_NODE_SUCCESS;
}

/***********************************************
    本函数为brother节点添加后续兄弟节点，并对
后续兄弟的parent进行设置。
************************************************/
int add_brother_node(struct node *last, struct node *new_brother)
{
    if(NULL!=last && NULL!=new_brother)
    {
        struct node *tmpparent=NULL;
        //if(NULL==last->parent)
        //{
        //    return ADD_BROTHER_TO_NODE_WITHOUT_PARENT;
        //}
        //else
        //{
			last->next=new_brother;
            new_brother->parent= last->parent;
 //       }
        return ADD_BROTHER_NODE_SUCCESS;
    }
    else
    {
        return NULL_NODE_POINTER;
    }
}

/************************************************
 set_node_val_str函数给节点nd->val.str设置字符串
*************************************************/
int set_node_val_str(struct node *nd, char *str)
{
    if(NULL==nd || NULL==str)
        return NULL_NODE_POINTER;
    else
    {
        if(NULL!=nd->val.str)
            free(nd->val.str);
        nd->val.str=(char *)malloc(strlen(str)+1);
        strcpy(nd->val.str,str);
        
        return SET_NODE_VAL_STR_SUCCESS;
    }
    
    return SET_NODE_VAL_STR_SUCCESS;
}

/************************************************
    本函数通过result参数返回结果。函数返回值
用于表示成功与否。
*************************************************/
int get_son_node(struct node *parent, struct node **result)
{
    if(NULL!=parent && NULL!=result)
    {
        *result=parent->son;
        return GET_SON_NODE_SUCCESS;
    }
    else
    {
        return NULL_NODE_POINTER;
    }
}


int get_next_brother_node(struct node *cur_nd, struct node **result)
{
    if(NULL!=cur_nd && NULL!=result)
    {
        *result=cur_nd->next;
        return GET_NEXT_BROTHER_NODE_SUCCESS;
    }
    else
    {
        return NULL_NODE_POINTER;
    }
    
    return GET_NEXT_BROTHER_NODE_SUCCESS;
}

int new_node(struct node **result)
{
    if(NULL!=result)
    {
        *result=(struct node *)malloc(sizeof(struct node));
        if(init_node(*result)==INIT_NODE_SUCCESS)
            return NEW_NODE_SUCCESS;
        else
            return MEMORY_ALLOC_ERROR;
    }
    else
    {
        return NULL_NODE_POINTER;
    }
    
    return NEW_NODE_SUCCESS;
}


struct node* get_last_node(struct node *N)
{
	struct node *tmp = N;
	if (N == NULL) {
		return NULL;
	}
	while (tmp->next != NULL) {
		tmp = tmp->next;
	}
	return tmp;
}
