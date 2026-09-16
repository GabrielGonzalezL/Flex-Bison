%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../interprete/interprete.c"
movimientos maquinaTM;
int yylex();            
void yyerror(const char*); 
%}

%union {
    char* strval;
}

%token <strval> MAQUINA ALFABETO ESTADOS INICIAL FINALES TRANSICIONES DER IZQ QUIETO SUBRUTINA USA REPETIR ID NUMBER UNKNOWN
%token FLECHA "->"
%token L_LLAVE "{"
%token R_LLAVE "}"
%token DOS_PUNTOS ":"
%token PUNTO_COMA ";"
%token COMA ","
%token PAREN_ABRE "("
%token PAREN_CIERRA ")"
%type <strval> valor direccion

%%
/*De aqui en adelante son reglas de gramatica, por lo cual se define cada uno de los bloques de nuestro lenguaje aunque por lo visto son caleta*/
/*
Esto es una base de lo que se supone debemos tener

programa:
    lista_subrutinas maquina
    | maquina
    ;

lista_subrutinas:
    lista_subrutinas subrutina
    | subrutina
    ;

subrutina:
    SUBRUTINA ID PAREN_ABRE ID PAREN_CIERRA L_LLAVE bloque_estados bloque_transiciones R_LLAVE
    ;

maquina:
    MAQUINA ID L_LLAVE bloque_alfabeto bloque_estados INICIAL DOS_PUNTOS ID PUNTO_COMA FINALES DOS_PUNTOS L_LLAVE lista_ids R_LLAVE PUNTO_COMA lista_usos bloque_transiciones R_LLAVE
    ;

*/

/* De aqui en adelante estan las declaraciones */

programa:
    declaraciones
    ;

declaraciones:
    declaraciones declaracion
    | declaracion
    ;

declaracion:
    subrutina
    | maquina
    ;


subrutina:
    SUBRUTINA ID PAREN_ABRE ID PAREN_CIERRA L_LLAVE estados transiciones R_LLAVE
    ;


maquina:
    MAQUINA ID L_LLAVE alfabeto estados inicial finales sentencias_usa transiciones R_LLAVE
    ;

/* Estructura */
alfabeto:
    ALFABETO L_LLAVE lista_valores R_LLAVE
    ;

estados:
    ESTADOS L_LLAVE lista_valores R_LLAVE
    | /* Las subrutinas a veces no definen estados, lo dejamos opcional por si acaso */
    ;

inicial:
    INICIAL DOS_PUNTOS ID PUNTO_COMA {
        maquinaTM.estado_actual = strdup($3);
        printf("Estado inicial configurado: %s\n", maquinaTM.estado_actual);
    }
    ;
    
finales:
    FINALES DOS_PUNTOS L_LLAVE lista_valores R_LLAVE PUNTO_COMA
    ;

/* --- USOS DE SUBRUTINAS --- */
sentencias_usa:
    sentencias_usa sentencia_usa
    | /* Puede que la máquina no use subrutinas (vacio) */
    ;

sentencia_usa:
    USA ID PAREN_ABRE parametro_usa PAREN_CIERRA PUNTO_COMA
    ;

parametro_usa:
    valor
    | direccion
    ;

/* --- TRANSICIONES --- */
transiciones:
    TRANSICIONES L_LLAVE lista_transiciones R_LLAVE
    ;

lista_transiciones:
    lista_transiciones instruccion_transicion
    | instruccion_transicion
    | /* vacio */
    ;

instruccion_transicion:
    transicion_simple
    | bloque_repetir
    ;

transicion_simple:
    valor COMA valor FLECHA valor COMA valor COMA direccion PUNTO_COMA {
        agregar_transicion(&maquinaTM.transiciones, $1, $3[0], $5, $7[0], $9);
        
        printf("Regla agregada: (%s, %c) -> (%s, %c, %s)\n", $1, $3[0], $5, $7[0], $9);
    }
    ;

bloque_repetir:
    /* Ejemplo: repetir (n) { ... } */
    REPETIR PAREN_ABRE ID PAREN_CIERRA L_LLAVE lista_transiciones R_LLAVE
    ;

/* Un valor puede ser un ID  (q0, _) o un NUMBER (0, 1) */
valor:
    ID 
    | NUMBER 
    ;

/* Lista separada por comas (0, 1, 2, 3, etc) */
lista_valores:
    lista_valores COMA valor
    | valor
    ;

/* Direcciones validas para el cabezal */
/* Devolvemos la dirección como texto puro o aceptamos una variable (ID) */
direccion:
    DER      { $$ = strdup("DER"); }
    | IZQ    { $$ = strdup("IZQ"); }
    | QUIETO { $$ = strdup("QUIETO"); }
    | ID     { $$ = strdup($1); }
    ;

%%

void yyerror ( char  const  * mensaje ) {
  printf ( "Error: %s \n " , mensaje ) ;
}

int main() {
    /*Inicializar maquina*/
    maquinaTM.transiciones.transiciones = NULL;
    maquinaTM.transiciones.cantidad = 0;
    maquinaTM.transiciones.capacidad = 0;
    
    iniciar_cinta(&maquinaTM.cinta, "_");
    
    printf("Inicializar maquina\n");
    if (yyparse() == 0) {
        simular_maquina(&maquinaTM);
    } else {
        printf("Error de Sintaxis\n");
    }

    return 0;
}