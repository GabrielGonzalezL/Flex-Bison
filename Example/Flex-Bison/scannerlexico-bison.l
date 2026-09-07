%option noyywrap
%{
    /* Conexión con Bison */
    #include "scannersintactico.tab.h"
    #include <string.h>  /* Necesario para strdup */
%}

word [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+"."[0-9]+|[0-9]+

%%
"maquina"               { yylval.strval = strdup(yytext); return MAQUINA; }
"alfabeto"              { yylval.strval = strdup(yytext); return ALFABETO; }
"estados"               { yylval.strval = strdup(yytext); return ESTADOS; }
"inicial"               { yylval.strval = strdup(yytext); return INICIAL; }
"finales"               { yylval.strval = strdup(yytext); return FINALES; }
"transiciones"          { yylval.strval = strdup(yytext); return TRANSICIONES; }
"subrutina"             { yylval.strval = strdup(yytext); return SUBRUTINA; }
"usa"                   { yylval.strval = strdup(yytext); return USA; }
"repetir"               { yylval.strval = strdup(yytext); return REPETIR; }
"DER"                   { yylval.strval = strdup(yytext); return DER; }
"IZQ"                   { yylval.strval = strdup(yytext); return IZQ; }
"QUIETO"                { yylval.strval = strdup(yytext); return QUIETO; }

"->"                    { yylval.strval = strdup(yytext); return FLECHA; }
"{"                     { yylval.strval = strdup(yytext); return L_LLAVE; }
"}"                     { yylval.strval = strdup(yytext); return R_LLAVE; }
":"                     { yylval.strval = strdup(yytext); return DOS_PUNTOS; }
";"                     { yylval.strval = strdup(yytext); return PUNTO_COMA; }
","                     { yylval.strval = strdup(yytext); return COMA; }
"_"                     { yylval.strval = strdup(yytext); return ID; }
"("                     { yylval.strval = strdup(yytext); return PAREN_ABRE; }
")"                     { yylval.strval = strdup(yytext); return PAREN_CIERRA; }

{word}                  { yylval.strval = strdup(yytext); return ID; }
{number}                { yylval.strval = strdup(yytext); return NUMBER; }

"//".*                  { /* ignorar */ }
[ \t\n\r]+              { /* ignorar */ }
.                       { yylval.strval = strdup(yytext); return UNKNOWN; }
%%