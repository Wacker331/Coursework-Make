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
%token WORD TAB SPACE UNKNOWN SEPARATOR NAME TOKEN

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

TARGET: NAME SPACE ':'
        | NAME ':'
        | TARGET SENTENCE
        | TARGET SEPARATOR RECIPE

RECIPE: TAB SENTENCE
        | TAB SENTENCE RECIPE

SENTENCE: TOKEN SPACE SENTENCE
          | NAME SPACE SENTENCE
          | WORD SPACE SENTENCE
          | TOKEN
          | NAME
          | SPACE
          | WORD

%%
