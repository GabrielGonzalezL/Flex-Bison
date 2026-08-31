maquina Complemento {
    alfabeto { 0, 1, _ }
    estados { q0, qA } 
    inicial: q0;
    finales: { qA };
    transiciones {
        q0, 0 -> q0, 1, DER;
        q0, 1 -> q0, 0, DER;
        q0, _ -> qA, _, QUIETO;
    }
}



