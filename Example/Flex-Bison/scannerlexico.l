/*Escaner Lexico lex.yy.cc*/
%option c++
%option noyywrap

%{
    #include <iostream>
    #include <string>

    enum yytokentype {
        MAQUINA = 1,
        ALFABETO,
        ESTADOS,
        INICIAL,
        FINALES,
        TRANSICIONES,
        DER,
        IZQ,
        QUIETO,
        ID,
        NUMBER,
        FLECHA,
        L_LLAVE,
        R_LLAVE,
        DOS_PUNTOS,
        PUNTO_COMA,
        COMA,
        SUBRUTINA,
        USA,
        REPETIR,
        PAREN_ABRE,
        PAREN_CIERRA,
        UNKNOWN
        
    };

    int yyval {};
    std::string yystr{};
%}

word [a-zA-Z_][a-zA-Z0-9_]*
number [0-9]+"."[0-9]+|[0-9]+

%%
"subrutina"             {yystr = YYText(); return SUBRUTINA;}
"usa"                   {yystr = YYText(); return USA;}
"repetir"               {yystr = YYText(); return REPETIR;}
"maquina"               {yystr = YYText(); return MAQUINA;}
"alfabeto"              {yystr = YYText(); return ALFABETO;}
"estados"               {yystr = YYText(); return ESTADOS;}
"inicial"               {yystr = YYText(); return INICIAL;}
"finales"               {yystr = YYText(); return FINALES;}
"transiciones"          {yystr = YYText(); return TRANSICIONES;}
"DER"                   {yystr = YYText(); return DER;}
"IZQ"                   {yystr = YYText(); return IZQ;}
"QUIETO"                {yystr = YYText(); return QUIETO;}


"->"                    {yystr = YYText(); return FLECHA;}
"{"                     {yystr = YYText(); return L_LLAVE;}
"}"                     {yystr = YYText(); return R_LLAVE;}
":"                     {yystr = YYText(); return DOS_PUNTOS;}
";"                     {yystr = YYText(); return PUNTO_COMA;}
","                     {yystr = YYText(); return COMA;}
"("                     {yystr = YYText(); return PAREN_ABRE;}
")"                     {yystr = YYText(); return PAREN_CIERRA;}

{word}                  {yystr = YYText(); return ID;}
{number}                {yyval = std::atoi(YYText()); return NUMBER;}

"//".*                  {/*ignorar */}
[ \t\n\r]+              {/*ignorar */}
.                       {yystr = YYText(); return UNKNOWN;}
%%

/* Función principal adaptada para C++ */
int main() {
    FlexLexer* lexer = new yyFlexLexer;
    int token {};
    while ((token = lexer->yylex())) {
        if (token == NUMBER)        std::cout << "number: " << yyval << "\n";
        else if (token == ID)       std::cout << "ID: " << yystr <<" \n";
        else if (token == UNKNOWN)  std::cout << "unknow: " << yystr <<"\n";
        else                        std::cout << "Comando: " << yystr << "\n";
    }

    delete lexer;
    return 0;
}