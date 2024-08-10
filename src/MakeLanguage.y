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
%token TAB SPACE UNKNOWN SEPARATOR NAME TOKEN RESERVED_WORDS SPECIAL_CONSTANTS

%%
result: SEPARATOR result
        | VARIABLE result
        | TARGET result
        | VARIABLE
        | TARGET
        | SEPARATOR

VARIABLE: NAME '='
          | NAME SPACE '='
          | VARIABLE SENTENCE

          | SPECIAL_CONSTANTS '='
          | SPECIAL_CONSTANTS SPACE '='

TARGET: NAME SPACE ':'
        {
          printf("WORKS\n");
        }
        | NAME ':'
        | TARGET DEPENDENCIES
        | TARGET SPACE DEPENDENCIES
        | TARGET SEPARATOR RECIPE
        | TARGET SEPARATOR
        | '$' '(' NAME ')' SPACE ':'
        | '$' '(' NAME ')' ':'
        | '$' '(' NAME ')' SPACE TARGET
        | NAME SPACE TARGET

        | SPECIAL_CONSTANTS SPACE ':'
        | SPECIAL_CONSTANTS ':'

RECIPE: TAB SENTENCE
        | TAB SENTENCE RECIPE

DEPENDENCIES: NAME
              | NAME SPACE DEPENDENCIES
              | '$' '(' NAME ')'
              | '$' '(' NAME ')' SPACE DEPENDENCIES

SENTENCE: TOKEN SPACE SENTENCE
          | NAME SPACE SENTENCE
          | TOKEN
          | NAME
          | SPACE
          | '$' '(' NAME ')'
          | '$' '(' NAME ')' SPACE SENTENCE
%%
