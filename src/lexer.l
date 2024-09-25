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
DEPENDENCIES        ((\|" "*)?(($$?"("{TOKEN}")")|({NAME})|($$?"("((patsubst)|(addsuffix))" ".*")")|$$?(<|\^|\+|\*)|$$?"("{NAME}:{NAME}={NAME}")")" "*{PERENOS}?)*
RECIPE              (" "{2,}|\t)+(.)+

%%
^-?include" "+{DEPENDENCIES} {print_token("INCLUDE", yytext);}
define" "+{NAME}" "*((:{1,3}|\?|\+|!)?=)? {print_token("DEFINE", yytext); return DEFINE;}
endef {print_token("ENDEF", yytext); return ENDEF;}
("vpath"|"VPATH").* {print_token("VPATH", yytext);}

{SPECIAL_CONSTANTS}" "*(:|=)" "*{DEPENDENCIES} {print_token("SPECIAL_CONSTANTS", yytext);}
{RESERVED_WORDS} {print_token("RESERVED_WORDS", yytext);}

({TARGET_NAME}&?:{1,2}" "*)+(({DEPENDENCIES})|({VARIABLE}))(;.*)? {print_token("TARGET", yytext); return TARGET;}
({RECIPE}{PERENOS}?)+ {print_token("RECIPE", yytext); return RECIPE;}
{NAME}" "*(:{1,3}|\?|\+|!)?=" "*(.*{PERENOS}?)* {print_token("VARIABLE", yytext); return VARIABLE;}
$"("{NAME}")" {print_token("VARIABLE_REPLACE", yytext);}

{COMMENT} {print_token("COMMENT", yytext);}

^(" "|\t)*\n {print_token("EMPTY_LINE", yytext); line++; return EMPTY_LINE;}
{PERENOS} {print_token("PERENOS", yytext); line++;}
\n {print_token("SEPARATOR", yytext); line++;}

.   { print_token("UNKNOWN", yytext); return UNKNOWN;}

%%
