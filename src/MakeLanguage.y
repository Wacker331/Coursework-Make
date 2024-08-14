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
%token TAB SPACE UNKNOWN SEPARATOR NAME TOKEN RESERVED_WORDS SPECIAL_CONSTANTS DEFINE ENDEF

%%
result: SEPARATOR result
        | VARIABLE result
        | TARGET DEPENDENCIES SEPARATOR RECIPE result
        {
          printf("TARGET REDUCED in result\n");
        }
        | DIRECTIVE result
        | '$' '(' NAME ')' result
        |

TARGET: name ':'
				{
          printf("TARGET REDUCED\n");
        }
				| name ':' ':'
        | name TARGET
				{
          printf("TARGET CONTINUES\n");
        }
        | SPECIAL_CONSTANTS ':'

VARIABLE: NAME '=' SENTENCE
					| NAME '?' '=' SENTENCE
					| NAME '+' '=' SENTENCE
					| NAME '!' '=' SENTENCE
          | SPECIAL_CONSTANTS '='

RECIPE: 
        | TAB RECIPE_SENTENCE SEPARATOR RECIPE

DEPENDENCIES:  
              | name DEPENDENCIES

RECIPE_SENTENCE: TOKEN RECIPE_SENTENCE
								| name RECIPE_SENTENCE
								| UNKNOWN RECIPE_SENTENCE
								| '$' RECIPE_SENTENCE
                | ':' RECIPE_SENTENCE
								| 

SENTENCE: TOKEN
          | name
          | TOKEN SENTENCE
          | name SENTENCE
					| TOKEN '$' SENTENCE
          | name '$' SENTENCE

DIRECTIVE: DEFINE NAME SEPARATOR RECIPE ENDEF
          | DEFINE NAME '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '?' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '+' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '!' '=' SEPARATOR RECIPE ENDEF

name: NAME
      | '$' '(' NAME ')'
      | '$' '$' '(' NAME ')'
%%
