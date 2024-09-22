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
    extern char* find_variable(char* name);
%}

%union {
  char charValue;
  char* stringValue;
}
%token TAB SPACE UNKNOWN SEPARATOR NAME TOKEN RESERVED_WORDS SPECIAL_CONSTANTS UNDEFINE DEFINE ENDEF EXPORT IFEQ IFDEF ELSE ENDIF OVERRIDE DEFAULT_GOAL
%type<charValue> UNKNOWN
%type<stringValue> TARGET DEPENDENCIES NAME TOKEN name SPECIAL_CONSTANTS VARIABLE SENTENCE
%right '$'
%left ':'

%%
result: SEPARATOR result | ';' result
        | VARIABLE SEPARATOR result | VARIABLE ';' result
        | TARGET DEPENDENCIES ';' RECIPE_SENTENCE SEPARATOR RECIPE result 
        {
          add_target($1, $2);
        }
        | TARGET DEPENDENCIES SEPARATOR RECIPE result
        {
          add_target($1, $2);
        }
        | DIRECTIVE result
        | IFEQ_CONSTRUCT result
        | IFDEF_CONSTRUCT result
        | '$' '(' NAME ')' result
        |

TARGET: name ':'
        {
          $$ = calloc(sizeof(char), strlen($1) + 2);
          strcpy($$, $1);
        }
				| name ':' ':'
        {
          $$ = calloc(sizeof(char), strlen($1) + 2);
          strcpy($$, $1);
        }
        | name '&' ':'
        {
          $$ = calloc(sizeof(char), strlen($1) + 2);
          strcpy($$, $1);
        }
        | name TARGET
        {
          printf("Test: %s\n", $1);
          $$ = calloc(sizeof(char), strlen($1) + strlen($2) + 2);
          strcpy($$, $1);
          $$ = strcat($$, " ");
          $$ = strcat($$, $2);
        }
        | SPECIAL_CONSTANTS ':'
        {
          $$ = calloc(sizeof(char), strlen($1) + 2);
          strcpy($$, $1);
        }

VARIABLE: NAME '=' SENTENCE
          {
            add_variable($1, $3);
          }
          | NAME '?' '=' SENTENCE
					| NAME '+' '=' SENTENCE
          {
            $$ = find_variable($1);
            if ($$ != 0)
            {
              // $$ = realloc($$, sizeof(char) * (strlen($$) + strlen($4)));
              $$ = strcat($$, " ");
              $$ = strcat($$, $4);
            }
            else
              printf("%s undefined :(\n", $1);
          }
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
          {
            $$ = calloc(sizeof(char), strlen($1) + 1);
            strcpy($$, $1);
          }
          | name
          {
            $$ = calloc(sizeof(char), strlen($1) + 1);
            strcpy($$, $1);
          }
          | name ':' name
          | TOKEN SENTENCE
          {
            $$ = calloc(sizeof(char), strlen($1) + strlen($2) + 2);
            $$ = strcat($$, $1);
            $$ = strcat($$, " ");
            $$ = strcat($$, $2);
          }
          | name SENTENCE
          {
            $$ = calloc(sizeof(char), strlen($1) + strlen($2) + 2);
            $$ = strcat($$, $1);
            $$ = strcat($$, " ");
            $$ = strcat($$, $2);
          }
					| TOKEN '$' SENTENCE
          | name '$' SENTENCE
          | '\'' SENTENCE
          | '\"' SENTENCE
          {
            $$ = calloc(sizeof(char), strlen($2) + 2);
            $$[0] = '\"';
            $$ = strcat($$, $2);
          }
          | UNKNOWN SENTENCE
          {
            $$ = calloc(sizeof(char), strlen($2) + 2);
            $$[0] = $1;
            $$ = strcat($$, $2);
          }
          | ';' SENTENCE
          | ',' SENTENCE
          | '+' SENTENCE
          {
            $$ = calloc(sizeof(char), strlen($2) + 2);
            $$[0] = '+';
            $$ = strcat($$, $2);
          }
          | '=' SENTENCE
          {
            $$ = calloc(sizeof(char), strlen($2) + 2);
            $$[0] = '=';
            $$ = strcat($$, $2);
          }
          | RESERVED_WORDS SENTENCE
          |
          {
            $$ = calloc(sizeof(char), 1);
          }

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
        if ($1 != NULL)
        {
          $$ = calloc(sizeof(char), strlen($1) + 1);
          strcpy($$, $1);
        }
      }
      | TOKEN name
      {
        $$ = calloc(sizeof(char), strlen($1) + strlen($2) + 2);
        strcpy($$, $1);
        $$ = strcat($$, " ");
        $$ = strcat($$, $2);
      }
      | NAME '?'
      | '*' NAME
      {
        $$ = $2;
      }
      | '$' '(' name_tuple ')'
      | '$' '(' NAME ')' NAME
      {
        if (find_variable($3) != NULL)
        {
          $$ = calloc(sizeof(char), strlen(find_variable($3)) + strlen($5) + 2);
          $$ = strcat($$, find_variable($3));
          $$ = strcat($$, " ");
          $$ = strcat($$, $5);
        }
      }
      | '$' '(' NAME ')'
      {
        if (find_variable($3) != NULL)
        {
          $$ = calloc(sizeof(char), strlen(find_variable($3)) + 1);
          strcpy($$, find_variable($3));
        }
        else
          yyerror("variable is undefined!\n");
      }
      | '$' '(' name ':' name '=' name ')'
      {
        int i, str_size, offset = strlen($7) - strlen($5), end_flag = 0;
        $$ = calloc(sizeof(char), strlen(find_variable($3)) + offset + 3);
        strcpy($$, find_variable($3));
        char* replace_p = $$;
        while ((replace_p = strstr(replace_p, $5)) != NULL)
        {
          if (offset > 0)
          {
            $$ = realloc($$, sizeof(char) * (strlen($$) + strlen($7) - strlen($5)));
            str_size = strlen($$);
            for (i = 0; $$ + str_size - i != replace_p; i++)
            {
              $$[str_size + offset - 1 - i] = $$[str_size - 1 - i];
            }
            $$[str_size + offset] = '\0';
          }
          else if (offset < 0)
          {
            for (i = 0; replace_p[i] != '\0'; i++)
            {
              replace_p[i] = replace_p[i + offset + 2];
            }
          }
          for (i = 0; i < strlen($7); i++)
          {
            replace_p[i] = $7[i];
          }
        }
      }
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
