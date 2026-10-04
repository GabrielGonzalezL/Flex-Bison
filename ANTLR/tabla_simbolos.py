class TablaSimbolosMaquina:
    # Nos encargamos de almacenar los simbolos obtenidos del parser para validar
    # y manipular las maquinas que puedan crearse .
    def __init__(self, nombre=""):
        self.nombre = nombre
        self.alfabeto = set()
        self.estados = set()
        self.estado_inicial = None
        self.estados_finales = set()
        self.transiciones = {}
    # -------------------------------------------------------------

    # Se definen como set para poder facilitar la busqueda de elementos.
    def definir_alfabeto(self, simbolos): 
        self.alfabeto = set(simbolos)

    def definir_estados(self, estados):
        self.estados = set(estados)

    def definir_inicial(self, estado): # 
        self.estado_inicial = estado

    def definir_finales(self, estados): # 
        self.estados_finales = set(estados)

    # Verificaciones semanticas minimas solicitadas. 
    # Determinismo: No pueden existir mas de una transicion para un mismo estado y simbolo.
    def registrar_transicion(self, estado, lee, estado_siguiente, escribe, mov):
        if (estado, lee) in self.transiciones:
            raise ValueError(f"Error Semantico: Transicion duplicada para ({estado}, {lee}).")
        self.transiciones[(estado, lee)] = (estado_siguiente, escribe, mov)


    def incorporar_subrutina(self, subrutina, argumento=None):
        nuevas_transiciones, nuevos_estados = subrutina.instanciar(argumento)
        # Agregamos los estados de la subrutina al grafo de la maquina
        self.estados.update(nuevos_estados)

        # Registramos cada transicion generada en el grafo de la maquina
        for orig, lee, dest, esc, mov in nuevas_transiciones:
            self.registrar_transicion(orig, lee, dest, esc, mov)

    # Verifica que todo estado referenciado en una transición haya sido declarado
    # Que el estado inicial y los finales existan,
    # y que todo símbolo leído o escrito en una transición pertenezca al alfabeto declarado.
    def validar_consistencia(self):
        if '_' not in self.alfabeto:    
            raise ValueError("Alfabeto no incluye el simbolo blanco/vacio '_'.")
        if self.estado_inicial not in self.estados:
            raise ValueError(f"Estado inicial '{self.estado_inicial}' no declarado.")
        for estado_final in self.estados_finales:
            if estado_final not in self.estados:
                raise ValueError(f"Estado final '{estado_final}' no declarado.")
        for (estado, lee), (estado_siguiente, escribe, mov) in self.transiciones.items():
            if estado not in self.estados:
                raise ValueError(f"Estado '{estado}' no declarado.")
            if estado_siguiente not in self.estados:
                raise ValueError(f"Estado '{estado_siguiente}' no declarado.")
            if str(lee) not in self.alfabeto:
                raise ValueError(f"Simbolo '{lee}' no pertenece al alfabeto.")
            if str(escribe) not in self.alfabeto:
                raise ValueError(f"Simbolo '{escribe}' no pertenece al alfabeto.")

class TablaSimboloSubrutina:
    def __init__(self, nombre, parametro=None):
        self.nombre = nombre
        self.parametro = parametro  # Parametro formal (ej. 'n', 'dir')
        self.estados = set()
        self.transiciones = []      # Lista de tuplas: (origen, lee, destino, escribe, mov)
        self.bloques_repetir = []   # Lista de tuplas: (param_rep, transiciones)

    def definir_estados(self, estados):
        self.estados.update(estados)

    def registrar_transicion(self, estado, lee, estado_siguiente, escribe, mov):
        self.transiciones.append((estado, lee, estado_siguiente, escribe, mov))
        self.estados.add(estado)
        self.estados.add(estado_siguiente)

    def registrar_bloque_repetir(self, param_rep, transiciones):
        self.bloques_repetir.append((param_rep, transiciones))

    def instanciar(self, argumento=None):
        resultado_trans = []
        resultado_estados = set(self.estados)
        arg_str = str(argumento) if argumento is not None else None

        # 1. Transiciones base de la subrutina (sustituyendo parametro formal si coincide)
        for orig, lee, dest, esc, mov in self.transiciones:
            l = arg_str if (self.parametro and lee == self.parametro) else lee
            e = arg_str if (self.parametro and esc == self.parametro) else esc
            m = arg_str if (self.parametro and mov == self.parametro) else mov
            resultado_trans.append((orig, l, dest, e, m))

        # 2. Bloques de repeticion parametrizados repetir(n)
        for param_rep, trans_bloque in self.bloques_repetir:
            veces = int(argumento) if (argumento is not None and str(argumento).isdigit()) else 1
            for orig, lee, dest, esc, mov in trans_bloque:
                # Si orig == dest y existe un estado de salida declarado (orig_fin), lo usamos
                dest_final = dest
                if orig == dest and f"{orig}_fin" in self.estados:
                    dest_final = f"{orig}_fin"

                if veces <= 1:
                    resultado_trans.append((orig, lee, dest_final, esc, mov))
                else:
                    # Encadenamos estados: orig -> rep_1 -> rep_2 ... -> dest_final
                    estado_previo = orig
                    for i in range(1, veces):
                        estado_intermedio = f"{orig}_rep_{i}"
                        resultado_estados.add(estado_intermedio)
                        resultado_trans.append((estado_previo, lee, estado_intermedio, esc, mov))
                        estado_previo = estado_intermedio
                    # La ultima repeticion conecta con el estado destino
                    resultado_trans.append((estado_previo, lee, dest_final, esc, mov))

        return resultado_trans, resultado_estados
            