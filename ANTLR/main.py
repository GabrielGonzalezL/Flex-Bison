from tabla_simbolos import *
from cinta import Interprete
import os
import sys
from antlr4 import *
from lexicoLexer import lexicoLexer
from lexicoParser import lexicoParser
from lexicoListener import lexicoListener

class GeneradorMaquina(lexicoListener):
    def __init__(self):
        self.subrutinas = {}           # nombre -> Subrutina
        self.maquinas = {}             # nombre -> TablaSimbolosMaquina
        self.subrutina_actual = None   # Puntero a subrutina activa
        self.maquina_actual = None     # Puntero a máquina activa
        self.en_bloque_repetir = False 
        self.param_repetir = None      
        self.transiciones_repetir = [] 
    
    #  se usa el property para obtener la maquina actual sin importar donde estemos
    @property
    def maquina(self):
        return self.maquina_actual or next(iter(self.maquinas.values()), None)
    # se usa el enterEveryRule para entrar a cada regla del parser lexicoParser
    def enterEveryRule(self, contexto_general):
        nombre_regla = type(contexto_general).__name__.replace('Context', '').lower()
        metodo = getattr(self, nombre_regla, None)
        if metodo: metodo(contexto_general) 
    # se usa el exitEveryRule para salir de cada regla del parser lexicoParser
    def exitEveryRule(self, contexto_general):
        nombre_regla = type(contexto_general).__name__.replace('Context', '').lower()
        metodo = getattr(self, f"salir_{nombre_regla}", None)
        if metodo: metodo(contexto_general)

    #metodo para entrar a una subrutina
    def subrutina(self, subrutina_datos):
        nombre = subrutina_datos.ID(0).getText()
        param = subrutina_datos.ID(1).getText() if subrutina_datos.ID(1) else None
        self.subrutina_actual = TablaSimboloSubrutina(nombre, param)
        self.subrutinas[nombre] = self.subrutina_actual
    
    #metodo para salir de una subrutina
    def salir_subrutina(self, subrutina_datos):
        self.subrutina_actual = None

    #metodo para entrar a una maquina
    def maquina(self, contexto_maquina):
        nombre = contexto_maquina.ID().getText()
        self.maquina_actual = TablaSimbolosMaquina(nombre)
        self.maquinas[nombre] = self.maquina_actual
    
    #metodo para salir de una maquina
    def salir_maquina(self, contexto_maquina):
        self.maquina_actual = None

    #metodo para usar una subrutina
    def uso_subrutina(self, contexto_uso):
        if not self.maquina_actual: return
        
        nombre_sub = contexto_uso.ID().getText()
        arg = contexto_uso.parametro().getText() if contexto_uso.parametro() else None
        
        if nombre_sub not in self.subrutinas:
            raise ValueError(f"Subrutina '{nombre_sub}' no declarada.")
            
        self.maquina_actual.incorporar_subrutina(self.subrutinas[nombre_sub], arg)
    
    #metodo para definir el alfabeto de una maquina
    def a_alfabeto(self, contexto_alfabeto):
        if not self.subrutina_actual and self.maquina_actual:
            self.maquina_actual.definir_alfabeto([s.getText() for s in contexto_alfabeto.simbolo()])
    #metodo para definir los estados de una maquina
    def e_estados(self, contexto_estados):
        estados = [e.getText() for e in contexto_estados.ID()]
        if self.subrutina_actual:
            self.subrutina_actual.definir_estados(estados)
        elif self.maquina_actual:
            self.maquina_actual.definir_estados(estados)

    def i_inicial(self, contexto_inicial):
        if not self.subrutina_actual and self.maquina_actual:
            self.maquina_actual.definir_inicial(contexto_inicial.ID().getText())

    def f_finales(self, contexto_finales):
        if not self.subrutina_actual and self.maquina_actual:
            self.maquina_actual.definir_finales([e.getText() for e in contexto_finales.ID()])

    def bloque_repetir(self, contexto_bloque):
        self.en_bloque_repetir = True
        self.param_repetir = contexto_bloque.ID().getText()
        self.transiciones_repetir.clear()

    #metodo para salir de un bloque de repetir  
    def salir_bloque_repetir(self, contexto_bloque):
        if self.subrutina_actual:
            self.subrutina_actual.registrar_bloque_repetir(self.param_repetir, self.transiciones_repetir)
        self.en_bloque_repetir = False
    
    #metodo para registrar una transicion
    def transicion(self, contexto_transicion):
        transicion_data = (
            contexto_transicion.ID(0).getText(),
            contexto_transicion.simbolo(0).getText(),
            contexto_transicion.ID(1).getText(),
            contexto_transicion.simbolo(1).getText(),
            contexto_transicion.Mov().getText() if contexto_transicion.Mov() else contexto_transicion.ID(2).getText()
        )

        if self.en_bloque_repetir:
            self.transiciones_repetir.append(transicion_data)
        elif self.subrutina_actual:
            self.subrutina_actual.registrar_transicion(*transicion_data)
        elif self.maquina_actual:
            self.maquina_actual.registrar_transicion(*transicion_data)

# Metodo principal para ejecutar la simulacion, se le pasa la ruta del archivo, la cinta de entrada y el nombre de la maquina a simular
def ejecutar_simulacion(ruta_archivo, entrada_cinta, nombre_maquina=None):
    lexer = lexicoLexer(FileStream(ruta_archivo, encoding='utf-8'))
    arbol = lexicoParser(CommonTokenStream(lexer)).programa()
    generador = GeneradorMaquina()
    ParseTreeWalker().walk(generador, arbol)
    if not generador.maquinas:
        raise ValueError("No se encontro ninguna maquina definida")
    if nombre_maquina:
        if nombre_maquina not in generador.maquinas:
            disponibles = list(generador.maquinas.keys())
            raise ValueError(f"Maquina '{nombre_maquina}' no encontrada. Disponibles: {disponibles}")
        maq = generador.maquinas[nombre_maquina]
    else:
        maq = next(iter(generador.maquinas.values()))
    print(f"\n Simulación de Máquina: '{maq.nombre}'\n Entrada: {entrada_cinta}")
    maq.validar_consistencia()
    Interprete(maq, entrada_cinta).simular()

if __name__ == '__main__':
    dir_script = os.path.dirname(os.path.abspath(__file__))
    ruta_default = "./maquina.tm" if os.path.exists("./maquina.tm") else os.path.join(dir_script, "maquina.tm")
    archivo_tm = sys.argv[1] if len(sys.argv) > 1 else ruta_default
    
    nombre_maq = None
    cinta = ["_"]

    if len(sys.argv) > 2:
        arg2 = sys.argv[2]
        if all(c in '01_' for c in arg2):
            cinta = list(arg2)
        else:
            nombre_maq = arg2
            cinta = list(sys.argv[3]) if len(sys.argv) > 3 else ["_"]

    ejecutar_simulacion(archivo_tm, cinta, nombre_maq)