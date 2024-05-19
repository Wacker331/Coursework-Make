%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "../build/MakeLanguage.h"

    extern int line;

    void print_token(const char* token_type, const char* token_text) {
        printf("%s: %s\n", token_type, token_text);
}
%}

%option noyywrap

WORD      (\${1,2}@)?[A-Za-z0-9\._%/-]+
WORD_WITH (\$\$?@)?[A-Za-z0-9\._%\/-][A-Za-z0-9\._%\/-:]*[A-Za-z0-9\._%\/-]
RECIPE      ((\t)|(" "{2,4}))[^ ].*
COMMENT     ^#.*

%%
"include"|"define"|"endef" {print_token("SPECIAL", yytext); return SPECIAL;}

\$\$[<\^\+\*>] {print_token("SPECIAL_VARIABLE", yytext); return SPECIAL_VARIABLE;}

{RECIPE} { print_token("RECIPE", yytext + 1); return RECIPE; }

{WORD_WITH} {
    print_token("WORD", yytext);
    return WORD;
}

{WORD} {
    print_token("WORD", yytext);
    return WORD;
}

([:]{0,3}|\??|\!?|\+?)= {print_token("=", yytext); return '='; }

\${1,2} {print_token("$", yytext); return '$';}

\( {print_token("(", yytext); return '(';}

\) {print_token(")", yytext);return ')';}

\{ {print_token("{", yytext);return '{';}

\} {print_token("}", yytext);return '}';}

\! {print_token("!", yytext);return '!';}

\? {print_token("?", yytext);return '?';}

\| {print_token("|", yytext);return '|';}

:{1,2} {print_token(":", yytext);return ':';}

\\\n[ \t]*  {print_token("CONTINUATOR", yytext); line++; return CONTINUATOR;}

\> {print_token(">", yytext);return '>';}

{COMMENT} { print_token("COMMENT", yytext); }

\n  { print_token("\\n", yytext); line++; return SEPARATOR;}

[ ] { print_token("SPACE", yytext);}

.   { print_token("UNKNOWN", yytext); }

%%
