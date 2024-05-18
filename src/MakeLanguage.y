%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void yyerror(const char *s);
    int yylex(void);
%}

%union {
  char charValue;
  char* stringValue;
}

%token WORD SEPARATOR RECIPE

%%
result: VAR_ASSIGN
        {
          printf("result0\n");
        }
        | TARGET
        {
          printf("result1\n");
        }
        | result VAR_ASSIGN
        {
          printf("result2\n");
        }
        | result TARGET
        {
          printf("result3\n");
        }
        | result COMMANDS
        {
          printf("result4\n");
        }
        | result SEPARATOR
        {
          printf("result5\n");
        }

VAR_ASSIGN: WORD '='
            {
              printf("Var assign0\n");
            }
            | VAR_ASSIGN WORD
            {
              printf("Var assign1\n");
            }

TARGET: WORD ':'
        {
            printf("Target0\n");
        }
        | WORD ':' ':' 
        {
            printf("Target1\n");
        }
        | VARIABLE ':'
        {
            printf("Target0\n");
        }
        | VARIABLE ':' ':' 
        {
            printf("Target1\n");
        }
        | TARGET WORD
        {
            printf("Target2\n");
        }
        | TARGET VARIABLE
        {
            printf("Target3\n");
        }

VARIABLE: '$' '(' WORD ')'
        {
          printf("Variable\n");
        }

COMMANDS: RECIPE
          {
            printf("Recipe0\n");
          }
          | COMMANDS RECIPE
          {
            printf("Recipe1\n");
          }
          | COMMANDS SEPARATOR
          {
            printf("Recipe2\n");
          }

%%
