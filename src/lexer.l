%{
#include <stdio.h>
%}

%%
start    printf("START\n");
stop     printf("STOP\n");
.        ; /* игнорируем все остальное */
%%
