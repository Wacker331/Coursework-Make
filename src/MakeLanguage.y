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

%union {
  char charValue;
  char* stringValue;
}
%debug
%token UNKNOWN SEPARATOR TARGET RECIPE EMPTY_LINE VARIABLE DEFINE ENDEF IF IFEQ IFDEF ELSE ENDIF
%right ENDIF

%%
result: SEPARATOR result
        | VARIABLE result
        | TARGET result
        | TARGET RECIPES EMPTY_LINE result
        | TARGET RECIPES result
        | EMPTY_LINE result
        | DEFINE RECIPES ENDEF result
        | DEFINE ENDEF result
        | IF result ELSE_CONSTRUCT ENDIF result
        | IF RECIPES ELSE_CONSTRUCT ENDIF result
        | IFEQ result ELSE_CONSTRUCT ENDIF result
        | IFEQ RECIPES ELSE_CONSTRUCT ENDIF result
        | IFDEF result ELSE_CONSTRUCT ENDIF result
        | IFDEF RECIPES ELSE_CONSTRUCT ENDIF result
        | 

RECIPES: RECIPE
        | RECIPE result RECIPES

ELSE_CONSTRUCT: | ELSE result | ELSE RECIPES

%%
