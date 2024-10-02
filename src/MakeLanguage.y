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
%left ELSE

%%
result:  VARIABLE result
        | TARGET result
        | TARGET RECIPES EMPTY_LINE result
        | TARGET RECIPES result
        | EMPTY_LINE result
        | DEFINE RECIPES ENDEF result
        | IF result ELSE_CONSTRUCT ENDIF result
        | IF RECIPES ELSE_CONSTRUCT ENDIF result
        | IFEQ_CONSTRUCT ENDIF result
        | IFDEF result ELSE_CONSTRUCT ENDIF result
        | IFDEF RECIPES ELSE_CONSTRUCT ENDIF result
        |

IFEQ_CONSTRUCT: IFEQ RECIPES ELSE_CONSTRUCT
              | IFEQ result ELSE_CONSTRUCT

RECIPES: 
        | RECIPE RECIPES
        | RECIPE IFEQ_CONSTRUCT ENDIF RECIPES

ELSE_CONSTRUCT: | ELSE result ELSE_CONSTRUCT | ELSE RECIPES ELSE_CONSTRUCT
                | ELSE IFEQ_CONSTRUCT ELSE_CONSTRUCT

%%
