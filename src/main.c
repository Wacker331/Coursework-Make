#include "main.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line;

extern FILE* yyin;

int yylex(void);

void yyerror(const char *str)
{
    printf("Error on line: %d\n", line);
}

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        yyin = fopen("GNUmakefile", "r");
        if (yyin == NULL)
            yyin = fopen("makefile", "r");
        if (yyin == NULL)
            yyin = fopen("Makefile", "r");
    }
    else 
    {
        for (int i = 1; i < argc; i++)
        {
            if (strcmp(argv[i], "-f") == 0 && i + 1 < argc)
            {
                yyin = fopen(argv[i + 1], "r");
            }
        }
        if (strcmp(argv[argc - 2], "-f") == 0)
        {
            MainTarget = argv[1];
        }
        else 
            MainTarget = argv[argc - 1];
    }
    if (yyin == NULL)
    {
        printf("Input file not found, try -f <filename>\n");
        return -1;
    }
    // return yylex();
    return yyparse();
}