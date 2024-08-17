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
%token TAB SPACE UNKNOWN SEPARATOR NAME TOKEN RESERVED_WORDS SPECIAL_CONSTANTS DEFINE ENDEF EXPORT
%type<charValue> UNKNOWN
%right '$'
%left ':'

%%
result: SEPARATOR result | ';' result
        | VARIABLE SEPARATOR result | VARIABLE ';' result
        | TARGET DEPENDENCIES ';' RECIPE_SENTENCE SEPARATOR RECIPE result | TARGET DEPENDENCIES SEPARATOR RECIPE result
        {
          printf("TARGET REDUCED in result\n");
        }
        | DIRECTIVE result
        | '$' '(' NAME ')' result
        |

TARGET: name ':'
				| name ':' ':'
        | name '&' ':'
        | name TARGET
        | SPECIAL_CONSTANTS ':'

VARIABLE: NAME '=' SENTENCE
          | NAME '?' '=' SENTENCE
					| NAME '+' '=' SENTENCE
					| NAME '!' '=' SENTENCE
          | EXPORT NAME '=' SENTENCE
          | EXPORT NAME '?' '=' SENTENCE
					| EXPORT NAME '+' '=' SENTENCE
					| EXPORT NAME '!' '=' SENTENCE
          | EXPORT NAME 
          | SPECIAL_CONSTANTS '='

RECIPE: 
        | TAB RECIPE_SENTENCE SEPARATOR RECIPE

UNTABBED_RECIPE: 
                | RECIPE_SENTENCE SEPARATOR UNTABBED_RECIPE
                {
                  printf("1\n");
                }

DEPENDENCIES: 
              | name DEPENDENCIES
              | '|' DEPENDENCIES
              | TOKEN DEPENDENCIES
              | TARGET DEPENDENCIES

RECIPE_SENTENCE: TOKEN RECIPE_SENTENCE
								| name RECIPE_SENTENCE
								| UNKNOWN RECIPE_SENTENCE
                | ':' RECIPE_SENTENCE
                | '^' RECIPE_SENTENCE
                | '?' RECIPE_SENTENCE
                | ';' RECIPE_SENTENCE
                | ',' RECIPE_SENTENCE
                | '(' RECIPE_SENTENCE
                | ')' RECIPE_SENTENCE
                | '*' RECIPE_SENTENCE
                | '\'' RECIPE_SENTENCE
                | '\"' RECIPE_SENTENCE
                | '&' RECIPE_SENTENCE
                | '=' RECIPE_SENTENCE
								| 

SENTENCE: TOKEN
          | name
          | name ':' name
          | TOKEN SENTENCE
          | name SENTENCE
					| TOKEN '$' SENTENCE
          | name '$' SENTENCE
          | '\'' SENTENCE
          | '\"' SENTENCE
          |

DIRECTIVE: DEFINE NAME SEPARATOR RECIPE ENDEF
          | DEFINE NAME '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '?' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '+' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '!' '=' SEPARATOR RECIPE ENDEF
          | DEFINE NAME SEPARATOR UNTABBED_RECIPE ENDEF
          | DEFINE NAME '=' SEPARATOR UNTABBED_RECIPE ENDEF
					| DEFINE NAME '?' '=' SEPARATOR UNTABBED_RECIPE ENDEF
					| DEFINE NAME '+' '=' SEPARATOR UNTABBED_RECIPE ENDEF
					| DEFINE NAME '!' '=' SEPARATOR UNTABBED_RECIPE ENDEF

name: NAME
      | NAME '?'
      | '*' NAME
      | '$' '(' NAME ')'
      | '$' '(' UNKNOWN NAME ')'
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
      | '$' UNKNOWN NAME '$' '$' '$' '$'
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

empty: 
%%
