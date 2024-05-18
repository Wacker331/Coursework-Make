%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "../build/MakeLanguage.h"

    void print_token(const char* token_type, const char* token_text) {
        printf("%s: %s\n", token_type, token_text);
}
%}

%option noyywrap

WORD      [A-Za-z0-9._%/-]+
RECIPE      [\t].*
COMMENT     ^#.*

%%
[ \t]*{WORD}[ \t]* {
    print_token("WORD", yytext);
    return WORD;
}

= {print_token("=", yytext); return '='; }

\$ {print_token("$", yytext); return '$';}

\( {print_token("(", yytext); return '(';}

\) {print_token(")", yytext);return ')';}

\{ {print_token("{", yytext);return '{';}

\} {print_token("}", yytext);return '}';}

\! {print_token("!", yytext);return '!';}

\? {print_token("?", yytext);return '?';}

\| {print_token("|", yytext);return '|';}

: {print_token(":", yytext);return ':';}

{RECIPE} { print_token("RECIPE", yytext + 1); return RECIPE; }

{COMMENT} { print_token("COMMENT", yytext); }

\n  { print_token("\\n", yytext); return SEPARATOR;}

[ \t]+ { print_token("TAB", yytext);}

.   { print_token("UNKNOWN", yytext); }
%%
