%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void yyerror(const char *s);
    int yylex(void);
    int line = 1;
    void print_pack(const char* token_type) 
    {
        printf("Line: %d - %s\n", line, token_type);
    }
%}

%token UNKNOWN TARGET RECIPE EMPTY_LINE VARIABLE DEFINE ENDEF IF IFEQ IFDEF ELSE ENDIF

%%
result:  VARIABLE result
        {
          printf("2\n");
        }
        | TARGET result
        {
          printf("3\n");
        }
        | TARGET RECIPES EMPTY_LINE result
        {
          printf("4\n");
        }
        | TARGET RECIPES result
        {
          printf("5\n");
        }
        | EMPTY_LINE result
        {
          printf("6\n");
        }
        | DEFINE RECIPES ENDEF result
        {
          printf("7\n");
        }
        | IF result ELSE_CONSTRUCT ENDIF result
        {
          printf("8\n");
        }
        | IF RECIPES ELSE_CONSTRUCT ENDIF result
        {
          printf("9\n");
        }
        | IFEQ result ELSE_CONSTRUCT ENDIF result
        {
          printf("10\n");
        }
        | IFEQ RECIPES ELSE_CONSTRUCT ENDIF result
        {
          printf("11\n");
        }
        | IFDEF result ELSE_CONSTRUCT ENDIF result
        {
          printf("12\n");
        }
        | IFDEF RECIPES ELSE_CONSTRUCT ENDIF result
        {
          printf("13\n");
        }
        |
        {
          printf("14\n");
        } 

RECIPES: 
        | RECIPE RECIPES
        | RECIPE IFEQ result ELSE_CONSTRUCT ENDIF RECIPES
        | RECIPE IFEQ RECIPES ELSE_CONSTRUCT ENDIF RECIPES

ELSE_CONSTRUCT: | ELSE result | ELSE RECIPES

%%
