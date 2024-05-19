#include "../build/MakeLanguage.h"
char* MainTarget = 0;

struct Variable
{
    char Name[1024];
    char Value[1024];
};

struct Target
{
    char* Name[1024];
    char* Dependencies[1024];
};