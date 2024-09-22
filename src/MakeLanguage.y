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
%token TAB SPACE UNKNOWN SEPARATOR NAME TOKEN RESERVED_WORDS SPECIAL_CONSTANTS UNDEFINE DEFINE ENDEF EXPORT IFEQ IFDEF ELSE ENDIF OVERRIDE DEFAULT_GOAL
%type<charValue> UNKNOWN
%type<stringValue> TARGET DEPENDENCIES NAME TOKEN name SPECIAL_CONSTANTS
%right '$'
%left ':'

%%
result: SEPARATOR result | ';' result
        | VARIABLE SEPARATOR result | VARIABLE ';' result
        | TARGET DEPENDENCIES ';' RECIPE_SENTENCE SEPARATOR RECIPE result 
        {
          add_target($1, $2);
          printf("TARGET: %s\n", $1);
        }
        | TARGET DEPENDENCIES SEPARATOR RECIPE result
        {
          add_target($1, $2);
          printf("TARGET: %s\n", $1);
        }
        | DIRECTIVE result
        | IFEQ_CONSTRUCT result
        | IFDEF_CONSTRUCT result
        | '$' '(' NAME ')' result
        |

TARGET: name ':'
        {
          $$ = $1;
        }
				| name ':' ':'
        {
          $$ = $1;
        }
        | name '&' ':'
        {
          $$ = $1;
        }
        | name TARGET
        {
          // $$ = strcat($1, $2);
        }
        | SPECIAL_CONSTANTS ':'
        {
          $$ = $1;
        }

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
          | OVERRIDE VARIABLE

RECIPE: 
        | TAB RECIPE_SENTENCE SEPARATOR RECIPE

UNTABBED_RECIPE: 
                | RECIPE_SENTENCE SEPARATOR UNTABBED_RECIPE

DEPENDENCIES: 
              {
                $$ = calloc(sizeof(char), 1);
              }
              | name DEPENDENCIES
              {
                strcat($1, " ");
                $$ = strcat($1, $2);
              }
              | '|' DEPENDENCIES
              | TOKEN DEPENDENCIES
              | TARGET DEPENDENCIES
              | VARIABLE

RECIPE_SENTENCE: TOKEN RECIPE_SENTENCE
								| name RECIPE_SENTENCE
								| UNKNOWN RECIPE_SENTENCE
                | ':' RECIPE_SENTENCE
                | '^' RECIPE_SENTENCE
                | '?' RECIPE_SENTENCE
                | '!' RECIPE_SENTENCE
                | ';' RECIPE_SENTENCE
                | ',' RECIPE_SENTENCE
                | '(' RECIPE_SENTENCE
                | ')' RECIPE_SENTENCE
                | '*' RECIPE_SENTENCE
                | '\'' RECIPE_SENTENCE
                | '\"' RECIPE_SENTENCE
                | '&' RECIPE_SENTENCE
                | '=' RECIPE_SENTENCE
                | '+' RECIPE_SENTENCE
                | '|' RECIPE_SENTENCE
                | '{' RECIPE_SENTENCE
                | '}' RECIPE_SENTENCE
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
          | UNKNOWN SENTENCE
          | ';' SENTENCE
          | ',' SENTENCE
          | '+' SENTENCE
          | '=' SENTENCE
          | RESERVED_WORDS SENTENCE
          |

DIRECTIVE: DEFINE NAME SEPARATOR RECIPE ENDEF
          | DEFINE NAME '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '?' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '+' '=' SEPARATOR RECIPE ENDEF
					| DEFINE NAME '!' '=' SEPARATOR RECIPE ENDEF
          | DEFINE name SEPARATOR UNTABBED_RECIPE ENDEF
          | DEFINE NAME SEPARATOR UNTABBED_RECIPE ENDEF
          | DEFINE name '=' SEPARATOR UNTABBED_RECIPE ENDEF
          | DEFINE NAME '=' SEPARATOR UNTABBED_RECIPE ENDEF
					| DEFINE NAME '?' '=' SEPARATOR UNTABBED_RECIPE ENDEF
					| DEFINE NAME '+' '=' SEPARATOR UNTABBED_RECIPE ENDEF
					| DEFINE NAME '!' '=' SEPARATOR UNTABBED_RECIPE ENDEF
          | DEFINE NAME SEPARATOR SEPARATOR SEPARATOR ENDEF
          | UNDEFINE name
          | OVERRIDE DIRECTIVE

IFEQ_HEADER: IFEQ '(' name ',' name ')'
            | IFEQ '(' TOKEN ',' name ')'
            | IFEQ '(' name ',' TOKEN ')'
            | IFEQ '(' TOKEN ',' TOKEN ')'
            | IFEQ '\"' name '\"' '\"' name '\"'
            | IFEQ '\"' name '\"' '\"' '\"'
            | IFEQ '(' name ',' ')'
            | IFEQ '(' ',' name ')'

IFEQ_CONSTRUCT: IFEQ_HEADER SEPARATOR RECIPE ENDIF
                | IFEQ_HEADER SEPARATOR UNTABBED_RECIPE ENDIF
                | IFEQ_HEADER SEPARATOR RECIPE ELSE SEPARATOR RECIPE ENDIF
                | IFEQ_HEADER SEPARATOR UNTABBED_RECIPE ELSE SEPARATOR UNTABBED_RECIPE ENDIF

IFDEF_CONSTRUCT: IFDEF name SEPARATOR RECIPE ENDIF
                | IFDEF name SEPARATOR UNTABBED_RECIPE ENDIF
                | IFDEF name SEPARATOR RECIPE ELSE RECIPE ENDIF
                | IFDEF name SEPARATOR UNTABBED_RECIPE ELSE UNTABBED_RECIPE ENDIF

name: NAME
      {
        $$ = $1;
      }
      | TOKEN name
      {
        // $$ = strcat($1, $2);
      }
      | NAME '?'
      | '*' NAME
      | '$' '(' name_tuple ')'
      | '$' '(' NAME ')' NAME
      {
        $$ = calloc(sizeof(char), strlen($3) + strlen($5) + 2);
        $$ = strcat($$, $3);
        $$ = strcat($$, " ");
        $$ = strcat($$, $5);
      }
      | '$' '(' NAME ')'
      {
        $$ = calloc(sizeof(char), strlen($3) + 1);
        strcpy($$, $3);
      }
      | '$' '(' name ':' name '=' name ')'
      | '$' '(' name '_' name ')'
      | '$' '{' NAME '}'
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
      | '$' '$' UNKNOWN
      {
        printf("%c\n", $3);
        if ($3 != '<' && $3 != '*')
          yyerror("Wrong arg");
      }
      | DEFAULT_GOAL

name_tuple: name ',' name_tuple
            | empty ',' name_tuple
            | name name_tuple
            |

empty: 
%%
