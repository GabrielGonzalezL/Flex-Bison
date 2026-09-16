subrutina escribir_unos (n) {
    estados { qE }
    transiciones {
        // Un for de repeticion n veces
        repetir (n) { 
            qE, _ -> qE, 1, DER;
        }
        
    }
}
subrutina moverhastablanco(dir) {
    estados { qM }
    transiciones {
        qM, 1 -> qM, 1, dir;
    }

}
// Maquina que utiliza la subrutina.
maquina Generador {
    alfabeto {0, 1, _}
    estados {q0, qE, qM, qF}
    inicial: q0;
    finales: {qF};

    // Usar Subrutina para crear n = 4 unos (Inicializar). 
    usa escribir_unos(4);

    // Ahora nos movemos a la izquierda de la cinta (Inicializar)
    usa moverhastablanco(IZQ);  
    
    transiciones {
        // Pasamos a usar la subrutina ya establecida
        q0, _ -> qE, _, DER;

        // Al terminar la subrutina, quedaremos en un espacio vacio "_", por lo cual pasamos al estado de moverhastablanco(IZQ)
        qE, _ -> qM, _, IZQ;
        
        // Una vez volvemos al blanco izquierdo, pasamos a finalizar el estado
        qM, _ -> qF, _, QUIETO;
    
    }
}