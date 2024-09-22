#ifndef MAIN_H
#define MAIN_H
#include "../build/MakeLanguage.h"
#define MAX_CHAR 128

char* MainTarget = 0;

struct Variable *Variables = 0;
int VariablesNum = 0;
struct Target *Targets = 0;
int TargetsNum = 0;

struct Variable
{
    char Name[MAX_CHAR];
    char Value[MAX_CHAR];
};

struct Target
{
    char Name[MAX_CHAR];
    char Dependencies[4 * MAX_CHAR];
};

void add_variable(char* name, char* value);
void add_target(char* name, char* dependencies);

void print_target()
{
    printf("Target: %s; Depens: %s", Targets[TargetsNum - 1].Name, Targets[TargetsNum - 1].Dependencies);
}

#endif