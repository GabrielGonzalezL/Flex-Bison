class Cinta:
    # Se considera una cinta de longitud infinita.
    # Se inicia con el estado base de la cinta, ya que esta vacio usamos su representador "_"
    def __init__(self, contenido_inicial, simbolo_blanco='_'):
        self.simbolo_blanco = simbolo_blanco
        self.celdas = list(contenido_inicial) if contenido_inicial else [self.simbolo_blanco]
        # ponemos nuestro simbolo de cabezal en su lugar inicial "0" leyendo "_"
        self.cabezal = 0
    
    # Leemos el cabezal, si el cabezal es negativo, retornamos vacio
    def leer(self):
        if self.cabezal < 0 or self.cabezal >= len(self.celdas):
            return self.simbolo_blanco
        return self.celdas[self.cabezal]
    
    # Si el cabezal supera cierto umbral (-) o (+) agregamos simbolos en blanco a la cinta y devolvemos 
    # el cabezal al inicio (0) (Solo para el caso en que el cabezal sea negativo).
    def escribir(self, simbolo):
        if self.cabezal < 0:
            self.celdas = [self.simbolo_blanco] * abs(self.cabezal) + self.celdas
            self.cabezal = 0
        elif self.cabezal >= len(self.celdas):
            self.celdas.extend([self.simbolo_blanco] * (self.cabezal - len(self.celdas) + 1))
        self.celdas[self.cabezal] = str(simbolo)
    
    # Mover cabezal izquierda o derecha
    def mover(self, direccion):
        if direccion == 'DER':
            self.cabezal += 1
        elif direccion == 'IZQ':
            self.cabezal -= 1

    # Se obtiene el estado actual de la cinta (la cadena que se ha formado hasta ahora y la posicion del cabezal)
    def obtener_estado(self):
        return "".join(self.celdas), self.cabezal


class Interprete:
    def __init__(self, maquina, cinta_inicial):
        self.maquina = maquina
        self.cinta = Cinta(cinta_inicial)
        self.estado_actual = maquina.estado_inicial
        self.paso = 0

    def simular(self):
        print(f"{'paso':<5} | {'estado':<8} | {'lee':<5} | {'accion':<35} | {'cinta despues'} | {'cabezal'}")
        
        while True:
            simbolo_leido = self.cinta.leer()
            cinta_str, pos_cabezal = self.cinta.obtener_estado()
            clave_transicion = (self.estado_actual, simbolo_leido)
            if clave_transicion not in self.maquina.transiciones:
                self.reportar_fin("Detencion / Rechazo (Sin transicion)", cinta_str)
                break
            destino, escrito, mov = self.maquina.transiciones[clave_transicion]
            accion_str = f"escribe {escrito}, mueve {mov}"
            estado_formateado = f"{cinta_str} \t(cabezal: {pos_cabezal})"
            print(f"{self.paso:<5} | {self.estado_actual:<8} | {simbolo_leido:<5} | {accion_str:<35} | {estado_formateado}")            
            self.cinta.escribir(escrito)
            self.cinta.mover(mov)
            self.estado_actual = destino
            self.paso += 1
            
            if self.estado_actual in self.maquina.estados_finales:
                cinta_str, _ = self.cinta.obtener_estado()
                accion_final = f"pasa a {self.estado_actual} (acepta)"
                print(f"{self.paso:<5} | {self.estado_actual:<8} | {'-':<5} | {accion_final:<35} | {cinta_str}")
                self.reportar_fin("Aceptacion", cinta_str)
                break

    def reportar_fin(self, resultado, cinta_final):
        print(f"\nResultado: {resultado}")
        print(f"Cinta final: {cinta_final}")