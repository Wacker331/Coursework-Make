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
RESERVED_WORDS      (include|define|endef)
SPECIAL_SYMBOLS     (:|=|$|"("|")"|\*|;|>|<|\^|@|\?|\+|!|\||&|\{|\})
PERENOS             \\" "*{COMMENT}?\n" "*

TOKEN               [A-Za-z0-9$\._%/-]+
COMMENT             #.*
NAME                [A-Za-z_]{TOKEN}

TARGET_NAME         ((($"("{NAME}")")|({NAME}))" "*)+
DEPENDENCIES        ((($"("{NAME}")")|({NAME}))" "*{PERENOS}?)*
RECIPE              " "{2,}(.[^\n])*

%%
{SPECIAL_CONSTANTS}" "*(:|=)" "*{DEPENDENCIES} {print_token("SPECIAL_CONSTANTS", yytext); /*return yytext;*/}
{RESERVED_WORDS} {print_token("RESERVED_WORDS", yytext); return yytext;}

{TARGET_NAME}:" "*{DEPENDENCIES} {print_token("TARGET", yytext);}
({RECIPE}{PERENOS}?)+ {print_token("RECIPE", yytext);}
{NAME}" "*(:)?=" "*{DEPENDENCIES} {print_token("VARIABLE", yytext);}

^((\t)|(" "{2,4}))+ {print_token("TAB", yytext); return TAB;}

{COMMENT} {print_token("COMMENT", yytext);}

\\" "*{COMMENT}?\n" "* {print_token("PERENOS", yytext); line++;}
\n {print_token("SEPARATOR", yytext); line++; return SEPARATOR;}

.   { print_token("UNKNOWN", yytext); return UNKNOWN;}

%%
