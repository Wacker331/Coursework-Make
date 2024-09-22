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
SPECIAL_SYMBOLS     (:|=|$|"("|")"|\*|\^|\?|\+|!|\||&|\{|\}|,|;|\"|\'|(_))

TOKEN      [A-Za-z0-9\._%/-]+
COMMENT     #.*
NAME [A-Za-z0-9_%/.]{TOKEN}?

%%
{SPECIAL_CONSTANTS} {print_token("SPECIAL_CONSTANTS", yytext); yylval.stringValue = malloc(sizeof(char) * strlen(yytext) + 1); strcpy(yylval.stringValue, yytext); return SPECIAL_CONSTANTS;}

(\$@\.\$\$\$\$) {print_token("NAME", yytext); yylval.stringValue = malloc(sizeof(char) * strlen(yytext) + 1); strcpy(yylval.stringValue, yytext); return NAME;}
{NAME}\$\$ {print_token("NAME", yytext); yylval.stringValue = malloc(sizeof(char) * strlen(yytext) + 1); strcpy(yylval.stringValue, yytext); return NAME;}
^" "*-?include" ".* {print_token("RESERVED_WORDS", yytext); yylval.stringValue = yytext;}
define {print_token("DEFINE", yytext); return DEFINE;}
undefine {print_token("UNDEFINE", yytext); return UNDEFINE;}
^" "*endef {print_token("ENDEF", yytext); return ENDEF;}
^" "*endif {print_token("ENDIF", yytext); return ENDIF;}
^" "*vpath" ".* {print_token("VPATH", yytext); yylval.stringValue = yytext;}
^export {print_token("EXPORT", yytext); return EXPORT;}
^unexport" "*.* {print_token("UNEXPORT", yytext); yylval.stringValue = yytext;}
^" "*ifeq {print_token("IFEQ", yytext); return IFEQ;}
^" "*ifneq {print_token("IFNEQ", yytext); return IFEQ;}
^" "*ifdef {print_token("IFDEF", yytext); return IFDEF;}
^" "*else {print_token("ELSE", yytext); return ELSE;}
^override {print_token("OVERRIDE", yytext); return OVERRIDE;}
\$"("\.DEFAULT_GOAL")" {print_token("DEFAULT_GOAL", yytext); return DEFAULT_GOAL;}
{RESERVED_WORDS} {print_token("RESERVED_WORDS", yytext); yylval.stringValue = yytext; return RESERVED_WORDS;}
:{0,3}= {}{print_token("SPECIAL_SYMBOLS", yytext); return '=';}
{SPECIAL_SYMBOLS} {print_token("SPECIAL_SYMBOLS", yytext); return *yytext;}

^((\t)|(" "{2,4}))+ {print_token("TAB", yytext); return TAB;}

{COMMENT} {print_token("COMMENT", yytext);}
{NAME} {print_token("NAME", yytext); yylval.stringValue = malloc(sizeof(char) * strlen(yytext) + 1); strcpy(yylval.stringValue, yytext); return NAME;}
{TOKEN} {print_token("TOKEN", yytext); yylval.stringValue = malloc(sizeof(char) * strlen(yytext) + 1); strcpy(yylval.stringValue, yytext); return TOKEN;}

(" "|\t)+ {print_token("SPACE", yytext); /*return SPACE;*/}

\\" "*{COMMENT}?\n(" "|\t)* {print_token("PERENOS", yytext); line++;}
\n|; {print_token("SEPARATOR", yytext); if (*yytext != ';') line++; return SEPARATOR;}

.   { print_token("UNKNOWN", yytext); yylval.charValue = *yytext; return UNKNOWN;}

%%
