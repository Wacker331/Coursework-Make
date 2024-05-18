#include "../build/MakeLanguage.h"

int  wrapRet = 1;

int yylex(void);

int yywrap(void)
{
    return wrapRet;
}

void yyerror(const char *str)
{
#ifdef DEBUG
    // cout << "Python Parser: " << str << endl;
#endif
}

int main()
{
    return yyparse();
}