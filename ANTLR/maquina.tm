//Genera 'n' unos consecutivos en la cinta
subrutina escribir_unos(n){
    estados { qE, qE_fin }
    transiciones {
        repetir (n) { 
            qE, _ -> qE_fin, 1, DER;
        }
    }
}

//Mueve el cabezal hacia una direccion hasta encontrar un blanco '_'
subrutina moverhastablanco(dir){
    estados { qM }
    transiciones {
        qM, 1 -> qM, 1, dir;
    }
}

maquina Generador{
    alfabeto {0, 1, _}
    estados {q0, qE, qE_fin, qM, qF}
    inicial: q0;
    finales: {qF};

    usa escribir_unos(4);
    usa moverhastablanco(IZQ);

    transiciones {
        q0, _ -> qE, _, DER;
        qE_fin, _ -> qM, _, IZQ;
        qM, _ -> qF, _, QUIETO;
    }
}

maquina Duplicador{
    alfabeto {0, 1, X, Y, S, _}
    estados {q0, q_avanza_0, q_avanza_1, q_escribe_primer_0, q_escribe_primer_1, q_busca_fin_0, q_busca_fin_1, q_retorno, q_sgte, q_restaura, q_rebobina, qF}
    inicial: q0;
    finales: {qF};

    transiciones {
        q0, 0 -> q_avanza_0, X, DER;
        q0, 1 -> q_avanza_1, Y, DER;
        q0, _ -> qF, _, QUIETO;
        q_avanza_0, 0 -> q_avanza_0, 0, DER;
        q_avanza_0, 1 -> q_avanza_0, 1, DER;
        q_avanza_0, S -> q_busca_fin_0, S, DER;
        q_avanza_0, _ -> q_escribe_primer_0, S, DER;
        q_escribe_primer_0, _ -> q_retorno, 0, IZQ;
        q_busca_fin_0, 0 -> q_busca_fin_0, 0, DER;
        q_busca_fin_0, 1 -> q_busca_fin_0, 1, DER;
        q_busca_fin_0, _ -> q_retorno, 0, IZQ;
        q_avanza_1, 0 -> q_avanza_1, 0, DER;
        q_avanza_1, 1 -> q_avanza_1, 1, DER;
        q_avanza_1, S -> q_busca_fin_1, S, DER;
        q_avanza_1, _ -> q_escribe_primer_1, S, DER;
        q_escribe_primer_1, _ -> q_retorno, 1, IZQ;
        q_busca_fin_1, 0 -> q_busca_fin_1, 0, DER;
        q_busca_fin_1, 1 -> q_busca_fin_1, 1, DER;
        q_busca_fin_1, _ -> q_retorno, 1, IZQ;
        q_retorno, 0 -> q_retorno, 0, IZQ;
        q_retorno, 1 -> q_retorno, 1, IZQ;
        q_retorno, S -> q_retorno, S, IZQ;
        q_retorno, X -> q_sgte, X, DER;
        q_retorno, Y -> q_sgte, Y, DER;
        q_sgte, 0 -> q_avanza_0, X, DER;
        q_sgte, 1 -> q_avanza_1, Y, DER;
        q_sgte, S -> q_restaura, S, IZQ;
        q_restaura, X -> q_restaura, 0, IZQ;
        q_restaura, Y -> q_restaura, 1, IZQ;
        q_restaura, _ -> q_rebobina, _, DER;
        q_rebobina, 0 -> qF, 0, QUIETO;
        q_rebobina, 1 -> qF, 1, QUIETO;
        q_rebobina, S -> qF, S, QUIETO;
        q_rebobina, _ -> qF, _, QUIETO;
    }
}