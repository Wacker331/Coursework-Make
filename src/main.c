#include "../src/main.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line;

extern FILE* yyin;

int yylex(void);

void yyerror(const char *str)
{
    printf("%s error on line: %d\n", str, line);
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
    yyparse();
    for (int i = 0; i < TargetsNum; i++)
        printf("Target: %s; Depens: %s\n", Targets[i].Name, Targets[i].Dependencies);
    for (int i = 0; i < VariablesNum; i++)
        printf("Variable_name: %s; Value: %s\n", Variables[i].Name, Variables[i].Value);
    return 0;
}

void add_variable(char* name, char* value)
{
    if (Variables == 0)
    {
        Variables = malloc(sizeof(struct Variable));
    }
    else
    {
        Variables = realloc(Variables, sizeof(struct Variable) * (VariablesNum + 1));
    }
    strncpy(Variables[VariablesNum].Name, name, MAX_CHAR);
    strncpy(Variables[VariablesNum].Value, value, 4 * MAX_CHAR);
    VariablesNum++;
}

void add_target(char* name, char* dependencies)
{
    if (Targets == 0)
    {
        Targets = malloc(sizeof(struct Target));
    }
    else
    {
        Targets = realloc(Targets, sizeof(struct Target) * (TargetsNum + 1));
    }
    strncpy(Targets[TargetsNum].Name, name, MAX_CHAR);
    strncpy(Targets[TargetsNum].Dependencies, dependencies, 4 * MAX_CHAR);
    TargetsNum++;
}

char* find_variable(char* name)
{
    if (Variables != NULL && name != NULL && VariablesNum > 0)
    {
        for (int i = 0; i < VariablesNum; i++)
        {
            if (Variables[i].Name != NULL && strcmp(Variables[i].Name, name) == 0)
            {
                // printf("%s\n", Variables[i].Value);
                return Variables[i].Value;
            }
        }
    }
    return NULL;
}