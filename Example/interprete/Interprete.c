#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
// Estructuras de datos para la simulación de la maquina de Turing
typedef struct {
    char* estado_actual;
    char lee;
    char* estado_nuevo;
    char escribe;
    char* mov;
} Transicion;

// transiciones
typedef struct {
    Transicion* transiciones;
    int cantidad;
    int capacidad;
} GestorTransiciones;

// estructura dela cinta
typedef struct {
    char* contenido;
    int size;
    int cabezal;
} Cinta;
// estructura de movimientos sobre la cinta y el estado actual un simulador
typedef struct {
    Cinta cinta;
    GestorTransiciones transiciones;
    char* estado_actual;
    char** finales;
    int num_finales;
} movimientos;


// Inicializa la cinta con el contenido inicial y coloca el cabezal en la posición 0
void iniciar_cinta(Cinta* c, const char* inicial) {
    c->size = strlen(inicial) > 0 ? strlen(inicial) : 1;
    c->contenido = (char*)malloc(c->size + 1);
    
    if (strlen(inicial) > 0) {
        strcpy(c->contenido, inicial);
    } else {
        strcpy(c->contenido, "_"); // Blanco por defecto
    }
    c->cabezal = 0;
}

// Escribe un símbolo en la posición actual del cabezal de la cinta
void escribir_cinta(Cinta* c, char simbolo) {
    c->contenido[c->cabezal] = simbolo;
}

// Mueve el cabezal de la cinta a la izquierda o derecha según la dirección especificada utilizando "DER" para derecha y "IZQ" para izquierda. 
// Si el cabezal se mueve fuera de los límites actuales de la cinta, la cinta se expande dinámicamente con espacios en blanco '_'.
void mover_cinta(Cinta* c, const char* direccion) {
    if (strcmp(direccion, "DER") == 0) {
        c->cabezal++;
        // Si el cabezal se sale por la derecha, expandimos la memoria
        if (c->cabezal >= c->size) {
            c->size++;
            c->contenido = (char*)realloc(c->contenido, c->size + 1);
            c->contenido[c->size - 1] = '_'; // Agregamos un espacio en blanco en la nueva posición
            c->contenido[c->size] = '\0';
        }
    } else if (strcmp(direccion, "IZQ") == 0) {
        if (c->cabezal == 0) {
            // Si estamos en el borde izquierdo, expandimos moviendo todo un espacio a la derecha
            c->size++;
            c->contenido = (char*)realloc(c->contenido, c->size + 1);
            memmove(c->contenido + 1, c->contenido, c->size - 1);
            c->contenido[0] = '_'; // Mismo que el anterior, agregamos un espacio en blanco al inicio
            c->contenido[c->size] = '\0';
            // El cabezal se queda en 0 porque empujamos todo hacia adelante
        } else {
            c->cabezal--;
        }
    }
}

// Tanciciones
void agregar_transicion(GestorTransiciones* g, const char* e_act, char lee, const char* e_nue, char esc, const char* mov) {
    if (g->cantidad >= g->capacidad) {
        g->capacidad = g->capacidad == 0 ? 10 : g->capacidad * 2;
        g->transiciones = (Transicion*)realloc(g->transiciones, g->capacidad * sizeof(Transicion));
    }
    g->transiciones[g->cantidad].estado_actual = strdup(e_act); //Estado actual para evitar problemas de memoria
    g->transiciones[g->cantidad].lee = lee; //leemos el simbolo
    g->transiciones[g->cantidad].estado_nuevo = strdup(e_nue); // Estado nuevo para evitar problemas de memoria
    g->transiciones[g->cantidad].escribe = esc; // Escribimos el simbolo
    g->transiciones[g->cantidad].mov = strdup(mov); // Movimiento del cabezal
    g->cantidad++; // Incrementamos la cantidad de transiciones
}

// Busca la transición en el arreglo. Devuelve un puntero si la encuentra, o NULL si no.
Transicion* obtener_transicion(GestorTransiciones* g, const char* estado, char lee) {
    for (int i = 0; i < g->cantidad; i++) {
        if (strcmp(g->transiciones[i].estado_actual, estado) == 0 && g->transiciones[i].lee == lee) {
            return &g->transiciones[i];
        }
    }
    return NULL;
}


bool es_estado_final(movimientos* sim) {
    for (int i = 0; i < sim->num_finales; i++) {
        if (strcmp(sim->estado_actual, sim->finales[i]) == 0) {
            return true;
        }
    }
    return false;
}

void simular_maquina(movimientos* sim) {
    int paso = 0;
    printf("paso | estado | lee | accion \t\t| cinta despues | cabezal\n");
    
    while (true) {
        // Verificar si llegamos a un estado de aceptación
        if (es_estado_final(sim)) {
            printf("%d    | %s     |   | (acepta)\t\t| %s\t| (alto)\n", paso, sim->estado_actual, sim->cinta.contenido);
            break;
        }

        char leido = sim->cinta.contenido[sim->cinta.cabezal];
        
        Transicion* t = obtener_transicion(&sim->transiciones, sim->estado_actual, leido);
        
        if (t == NULL) {
            printf("No hay transicion para (%s, %c).\n", sim->estado_actual, leido);
            break;
        }

        escribir_cinta(&sim->cinta, t->escribe);
        
        printf("%d    | %s     | %c | esc %c, mov %s\t| %s\t| -> celda %d\n", 
               paso, sim->estado_actual, leido, t->escribe, t->mov, sim->cinta.contenido, sim->cinta.cabezal);
        
        mover_cinta(&sim->cinta, t->mov);
        
        // Actualizar el estado actual
        sim->estado_actual = t->estado_nuevo; // Apuntamos al nuevo estado
        paso++;
    }
}