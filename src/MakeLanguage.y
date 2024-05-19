%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    void yyerror(const char *s);
    int yylex(void);
    int line = 1;
%}

%union {
  char charValue;
  char* stringValue;
}

%token WORD SEPARATOR RECIPE CONTINUATOR SPECIAL
%token SPECIAL_VARIABLE

%%
result: VAR_ASSIGN
        {
          printf("result0\n");
        }
        | TARGET
        {
          printf("result1\n");
        }
        | DIRECTIVE
        {
          printf("result directive\n");
        }
        | result VAR_ASSIGN
        {
          printf("result2\n");
        }
        | result TARGET
        {
          printf("result3\n");
        }
        | result DIRECTIVE
        {
          printf("result += directive\n");
        }
        | result VARIABLE
        {
          printf("result += variable\n");
        }
        | result COMMANDS
        {
          printf("result4\n");
        }
        | result SEPARATOR
        {
          printf("result5\n");
        }
        | SEPARATOR
        {
          printf("result6\n");
        }

VAR_ASSIGN: WORD '='
            {
              printf("Var assign0\n");
            }
            | VAR_ASSIGN EXPRESSION
            {
              printf("Var assign1\n");
            }

TARGET: EXPRESSION ':'
        {
            printf("Target0\n");
        }
        | EXPRESSION ':' ':' 
        {
            printf("Target1\n");
        }
        | TARGET EXPRESSION
        {
            printf("Target2\n");
        }
        | TARGET ':'
        {
          printf("Target in target\n");
        }

VARIABLE: '$' '(' EXPRESSION ')'
        {
          printf("Variable\n");
        }
        | SPECIAL_VARIABLE
        {
          printf("Sprecial variable\n");
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

DIRECTIVE:  SPECIAL
            {
              printf("Special\n");
            }
            | SPECIAL EXPRESSION
            {
              printf("Special + expr\n");
            }
            | DIRECTIVE '='
            {
              printf("directive ==\n");
            }

EXPRESSION: WORD
            | VARIABLE
            | EXPRESSION WORD
            {
              printf("Expr1\n");
            }
            | EXPRESSION VARIABLE
            {
              printf("expr += var\n");
            }
            | EXPRESSION CONTINUATOR
            | '(' EXPRESSION ')'
            | EXPRESSION '$' CONTINUATOR
            | EXPRESSION '$' WORD
            | '|' EXPRESSION

%%
