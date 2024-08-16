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
%type<charValue> UNKNOWN
%right '$'

%%
result: SEPARATOR result | ';' result
        | VARIABLE SEPARATOR result | VARIABLE ';' result
        | TARGET DEPENDENCIES ';' RECIPE result | TARGET DEPENDENCIES SEPARATOR RECIPE result 
        {
          printf("TARGET REDUCED in result\n");
        }
        | DIRECTIVE result
        | '$' '(' NAME ')' result
        |

TARGET: 
        | name ':' TARGET
				{
          printf("TARGET REDUCED\n");
        }
				| name ':' ':'
        | name '&' ':'
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
        | TAB RECIPE_SENTENCE ';' RECIPE_SENTENCE RECIPE
        {
          printf("check5\n");
        }

DEPENDENCIES:  
              | name DEPENDENCIES
              | '|' DEPENDENCIES
              | TOKEN DEPENDENCIES

RECIPE_SENTENCE: TOKEN RECIPE_SENTENCE
								| name RECIPE_SENTENCE
								| UNKNOWN RECIPE_SENTENCE
                {
                  printf("%c", $1);
                }
                | ':' RECIPE_SENTENCE
                | '^' RECIPE_SENTENCE
                | '?' RECIPE_SENTENCE
								| 

SENTENCE: TOKEN
          | name
          | name ':' name
          | TOKEN SENTENCE
          | name SENTENCE
					| TOKEN '$' SENTENCE
          | name '$' SENTENCE
          |

DIRECTIVE: DEFINE NAME SEPARATOR RECIPE ENDEF
          | DEFINE NAME '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '?' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '+' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '!' '=' SEPARATOR RECIPE ENDEF

name: NAME
      | '*' NAME
      | '$' '(' NAME ')'
      {
        printf("check2\n");
      }
      | '$' '$' '(' NAME ')'
      | '$' '$' '(' '$' '$' UNKNOWN NAME ')'
      | '$' '$' '(' NAME name_tuple ')'
      | '$' '(' NAME name_tuple ')'
      | '$' '$' '+'
      | '$' '$' '^'
      | '$' '$' '*'
      | '$' '*'
      | '$' '^'
      | '$' '?'
      | '$' '$' NAME
      | '$' UNKNOWN
      {
        printf("check\n");
      }
      | '$' '$' UNKNOWN
      {
        printf("%c\n", $3);
        if ($3 != '<' && $3 != '*')
          yyerror("Wrong arg");
      }

name_tuple: name ',' name_tuple
            | empty ',' name_tuple
            | name name_tuple
            |
            {
              printf("check3\n");
            }

empty: 
%%
