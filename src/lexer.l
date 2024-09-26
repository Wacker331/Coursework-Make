%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "../build/MakeLanguage.h"

    extern int line;

    void print_token(const char* token_type, const char* token_text) 
    {
        printf("Line: %d - %s: \"%s\"\n", line, token_type, token_text);
    }
%}

%option noyywrap

SPECIAL_CONSTANTS   (.(PHONY|SUFFIXES|DEFAULT|PRECIOUS|INTERMEDIATE|NOTINTERMEDIATE|SECONDARY|SECONDEXPANSION|DELETE_ON_ERROR|IGNORE|LOW_RESOLUTION_TIME|SILENT|EXPORT_ALL_VARIABLES|NOTPARALLEL|ONESHELL|POSIX))
RESERVED_WORDS      (include|define|endef|override|undefine)
SPECIAL_SYMBOLS     (:|=|$|"("|")"|\*|;|>|<|\^|@|\?|\+|!|\||&|\{|\})
PERENOS             \\" "*{COMMENT}?\n" "*

TOKEN               [A-Za-z0-9\*$@\._%/\\\"=-]+
COMMENT             #.*
NAME                [A-Za-z0-9_\.*%/-]{TOKEN}?
VARIABLE            {NAME}" "*(:{1,3}|\?|\+|!)?=" "*(.*{PERENOS}?)*

TARGET_NAME         ((($$?"("{NAME}")")|({NAME}))" "*)+
DEPENDENCIES        ((\|" "*)?(($$?"("{TOKEN}")")|({NAME})|($$?"("((patsubst)|(addsuffix)|(findstring)|(wildcard))" ".*")")|$$?(<|\^|\+|\*)|$$?"("{NAME}:{NAME}={NAME}")")" "*{PERENOS}?)*
RECIPE              (" "{2,}|\t)+(.)+

%%
^-?include" "+{DEPENDENCIES}(" "|\t)* {print_token("INCLUDE", yytext);}
define" "+{NAME}(" "|\t)*((:{1,3}|\?|\+|!)?=)? {print_token("DEFINE", yytext); return DEFINE;}
endef {print_token("ENDEF", yytext); return ENDEF;}
if" "+{DEPENDENCIES} {print_token("IF", yytext); return IF;}
ifn?eq" "+"("{DEPENDENCIES}," "*{DEPENDENCIES}")" {print_token("IFEQ", yytext); return IFEQ;}
ifn?def" "+{DEPENDENCIES} {print_token("IFDEF", yytext); return IFDEF;}
else(" "|\t)* {print_token("ELSE", yytext); return ELSE;}
endif(" "|\t)* {print_token("ENDIF", yytext); return ENDIF;}
("vpath"|"VPATH").* {print_token("VPATH", yytext);}

{SPECIAL_CONSTANTS}" "*(:|=)" "*{DEPENDENCIES} {print_token("SPECIAL_CONSTANTS", yytext);}
{RESERVED_WORDS} {print_token("RESERVED_WORDS", yytext);}
{COMMENT} {print_token("COMMENT", yytext);}

({RECIPE}{PERENOS}?)+ {print_token("RECIPE", yytext); return RECIPE;}
({TARGET_NAME}&?:{1,2}" "*)+(({DEPENDENCIES})|({VARIABLE}))(;.*)? {print_token("TARGET", yytext); return TARGET;}
{NAME}" "*(:{1,3}|\?|\+|!)?=" "*(.*{PERENOS}?)* {print_token("VARIABLE", yytext); return VARIABLE;}
$"("{NAME}")" {print_token("VARIABLE_REPLACE", yytext);}


^(" "|\t)*\n {print_token("EMPTY_LINE", yytext); line++; return EMPTY_LINE;}
{PERENOS} {print_token("PERENOS", yytext); line++;}
\n {print_token("SEPARATOR", yytext); line++;}

.   { print_token("UNKNOWN", yytext); return UNKNOWN;}

%%
