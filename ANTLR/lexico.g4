grammar lexico;

// Analizador Sintáctico
// para que sepa como leer el orden del archivo (como inician los tm con subrutinas o sin ninguna)
programa : (subrutina | maquina)+;

subrutina : 'subrutina' ID '(' ID ')' '{'
            e_estados?
            t_transiciones
          '}' ;

maquina : 'maquina' ID '{' 
             a_alfabeto 
             e_estados 
             i_inicial 
             f_finales
             cinta_inicial?
             pos_cabezal_inicial?
             uso_subrutina*
             t_transiciones
          '}' ;

a_alfabeto : 'alfabeto' '{' simbolo (',' simbolo)* '}' ;
e_estados : 'estados' '{' ID (',' ID)* '}' ;
i_inicial : 'inicial' ':' ID ';' ;
f_finales : 'finales' ':' '{' ID (',' ID)* '}' ';' ;
cinta_inicial : 'c_inicial' ':' SIMBOLO+ ';' ;
pos_cabezal_inicial : 'c_cabezal' ':' INT ';' ;
uso_subrutina : 'usa' ID '(' parametro ')' ';' ;

// La subrutina puede tener una mov, un numero, o una variable asociada (n con n = alguna cosa jeje)

parametro : INT | ID | Mov ;
// ------------------------------------------------------------------------------------
// Las transiciones pueden ser reglas normales o un bloque repetir
t_transiciones : 'transiciones' '{' (transicion | bloque_repetir)* '}' ;
// ------------------------------------------------------------------------------------
// El bloque repetir para ejecutar un for n veces en caso de ser creados.
bloque_repetir : 'repetir' '(' ID ')' '{' transicion* '}' ;

transicion : ID ',' simbolo '->' ID ',' simbolo ',' (Mov | ID) ';' ;
simbolo : ID | INT ;
// Analizador Lexico o lexer.

Mov : 'IZQ' | 'DER' | 'QUIETO' ;

// Ids (Para reglas gramaticales, nombres de estados, variables)
ID : [a-zA-Z_][a-zA-Z0-9_]* ;

// Solo numeros enteros
INT : [0-9]+ ;

// (0, 1, _)
SIMBOLO : [a-zA-Z0-9_] ;

// Ignorar saltos de líneas o espacios
WS : [ \t\r\n]+ -> skip ;

// Ignorar comentarios
COMMENT : '//' ~[\r\n]* -> skip ;