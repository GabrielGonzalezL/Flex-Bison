# Simulador de Máquinas de Turing con ANTLR4 y Python

**Certamen 1 — Lenguajes de Programación**  
**Integrantes:**
- Eduardo Amigo
- Gabriel González
- Ricardo Gil

Este proyecto implementa un intérprete y simulador completo de Máquinas de Turing deterministas utilizando una gramática formal en **ANTLR v4** y un motor de ejecución en **Python 3**. Soporta composición modular de subrutinas parametrizadas, bloques de repetición (`repetir(n)`), validación semántica de consistencia y simulación visual paso a paso sobre una cinta infinita bidireccional.

---

## 📁 Estructura del Proyecto

```text
Flex-Bison/
├── makefile                 # Automatización de ejecución, pruebas, compilación ANTLR y limpieza
├── README.md                # Documentación del proyecto y guía de uso
└── ANTLR/
    ├── antlr-4.13.1-complete.jar # Herramienta de generación de código ANTLR 4
    ├── lexico.g4            # Definición léxica y sintáctica de la gramática
    ├── lexicoLexer.py       # Analizador léxico generado por ANTLR
    ├── lexicoParser.py      # Analizador sintáctico generado por ANTLR
    ├── lexicoListener.py    # Clase base Listener generada por ANTLR
    ├── main.py              # Punto de entrada, recorrido AST (Listener) y orquestación
    ├── tabla_simbolos.py    # Clases semánticas (TablaSimbolosMaquina, TablaSimboloSubrutina)
    ├── cinta.py             # Modelo de Cinta infinita e Intérprete de ejecución paso a paso
    └── maquina.tm           # Definición de máquinas y subrutinas de prueba (Generador y Duplicador)
```

### Descripción de Componentes

- **`ANTLR/lexico.g4`**: Define la gramática para el lenguaje de especificación `.tm`. Permite definir subrutinas reutilizables con parámetros, múltiples máquinas en un mismo archivo, alfabetos, conjuntos de estados, transiciones y bloques `repetir(n)`.
- **`ANTLR/main.py`**: Implementa `GeneradorMaquina`, un listener que recorre el árbol de análisis sintáctico (`ParseTreeWalker`), construye las tablas de símbolos, valida las restricciones semánticas y arranca la simulación con `Interprete`.
- **`ANTLR/tabla_simbolos.py`**:
  - `TablaSimbolosMaquina`: Almacena el grafo de la máquina, verifica el determinismo (sin transiciones duplicadas) y valida consistencia (existencia de símbolos en el alfabeto, estados inicial/finales válidos).
  - `TablaSimboloSubrutina`: Representa subrutinas con parámetros formales, expansión dinámica de argumentos e instanciación de bloques de repetición enlazando estados intermedios.
- **`ANTLR/cinta.py`**:
  - `Cinta`: Modela una cinta infinita bidireccional que maneja crecimiento dinámico hacia la derecha y hacia la izquierda (índices negativos reubicados de forma transparente).
  - `Interprete`: Ejecuta la máquina paso a paso mostrando en consola el estado, símbolo leído, acción realizada, contenido de la cinta y posición del cabezal.
- **`ANTLR/maquina.tm`**: Contiene la definición de dos máquinas de prueba:
  1. `Generador`: Invoca subrutinas modulares (`escribir_unos(4)` y `moverhastablanco(IZQ)`) para escribir cuatro unos en la cinta y posicionarse al inicio.
  2. `Duplicador`: Máquina que toma una entrada binaria $w \in \{0, 1\}^*$ y produce $w S w$.

---

## 🛠️ Requisitos Previos

1. **Python 3.10+**: Comprobar instalación con:
   ```bash
   python --version
   ```
2. **Runtime de ANTLR4 para Python**:
   ```bash
   pip install antlr4-python3-runtime==4.13.1
   ```
3. **Java (JRE/JDK 11+)** *(Opcional, solo si se modifica `lexico.g4` y se recompila la gramática)*:
   ```bash
   java -version
   ```
4. **GNU Make / mingw32-make** *(Opcional pero recomendado para usar el `makefile`)*.

---

## 🚀 Guía de Uso

### Opción 1: Uso mediante `make` / `mingw32-make` (Recomendado)

En la raíz del directorio `Flex-Bison`:

| Comando | Descripción |
|---|---|
| `make` o `make help` | Muestra el menú de ayuda con todos los comandos disponibles. |
| `make run` | Ejecuta la simulación por defecto (`Generador` con cinta inicial `_`). |
| `make run-generador` | Ejecuta la máquina `Generador`. |
| `make run-duplicador` | Ejecuta la máquina `Duplicador` con la entrada `101`. |
| `make test` | Ejecuta una suite completa probando ambas máquinas automáticamente. |
| `make simular MAQ=<nombre> CINTA=<cadena>` | Simula una máquina específica con una cinta personalizada. |
| `make antlr` | Recompila el archivo `lexico.g4` usando el `.jar` de ANTLR 4. |
| `make clean` | Elimina la caché de Python (`__pycache__` y archivos `.pyc`). |

> **Nota para Windows**: Si `make` no está en tu `PATH`, puedes usar `mingw32-make` con exactamente los mismos objetivos.

#### Ejemplos con `make`:
```bash
# Ejecución por defecto
make run

# Duplicar una cadena personalizada (ej: '110')
make simular MAQ=Duplicador CINTA=110

# Limpiar cache
make clean
```

---

### Opción 2: Uso directo con Python

También se puede ejecutar el script directamente mediante la línea de comandos:

```bash
# 1. Ejecución básica (usa la máquina por defecto 'Generador' con cinta '_')
python ANTLR/main.py

# 2. Ejecutar máquina específica con cinta personalizada
# Formato: python ANTLR/main.py <archivo.tm> <NombreMaquina> <CintaInicial>
python ANTLR/main.py ANTLR/maquina.tm Duplicador 101

# 3. Ejecutar Generador con cinta explícita
python ANTLR/main.py ANTLR/maquina.tm Generador _
```

---

## 📝 Formato de Especificación (`.tm`)

El archivo de especificación permite estructurar la máquina de Turing con las siguientes construcciones:

### 1. Definición de Subrutinas y Bloques de Repetición
```antlr
subrutina escribir_unos(n){
    estados { qE, qE_fin }
    transiciones {
        repetir (n) { 
            qE, _ -> qE_fin, 1, DER;
        }
    }
}
```

### 2. Definición de Máquinas y Llamadas a Subrutinas
```antlr
maquina Generador{
    alfabeto {0, 1, _}
    estados {q0, qE, qE_fin, qM, qF}
    inicial: q0;
    finales: {qF};

    // Incorporación de subrutinas con argumento concreto
    usa escribir_unos(4);
    usa moverhastablanco(IZQ);

    transiciones {
        q0, _ -> qE, _, DER;
        qE_fin, _ -> qM, _, IZQ;
        qM, _ -> qF, _, QUIETO;
    }
}
```

### 3. Formato de Transición
`estado_origen, simbolo_leido -> estado_destino, simbolo_escrito, movimiento;`  
Donde los movimientos válidos son `DER` (Derecha), `IZQ` (Izquierda) y `QUIETO`.

---

## 🤖 Declaración de Uso de Inteligencia Artificial (IA)

En conformidad con las pautas de transparencia académica del Certamen:

1. **Generación Automatizada**: La IA fue utilizada directamente para la redacción y maquetación de esta documentación (`README.md`) y para la construcción del archivo de automatización (`makefile`).
2. **Alcance en el Código**: El uso de herramientas de Inteligencia Artificial en el código fuente estuvo **estrictamente acotado a tareas de debugging puntual y orientación conceptual/técnica de diseño y codificación**. La lógica central, algoritmos y reglas de diseño fueron implementados por los autores del proyecto.

### Ejemplos de Prompts Realizados:

- **Prompt 1 (Debugging - Error de resolución de nombres e imports):**  
  > *"Tengo un error al ejecutar `main.py`: `ImportError: cannot import name 'TablaSimboloSubrutina' from 'tabla_simbolos'`. Revisa la discrepancia entre el nombre de la clase en `tabla_simbolos.py` y cómo se importa en `main.py`, y propón la corrección manteniendo consistencia semántica."*

- **Prompt 2 (Orientación en Codificación - Conexión de Subrutinas en Listener ANTLR):**  
  > *"¿Cómo puedo estructurar los métodos del Listener en ANTLR (`enterEveryRule` o métodos específicos por regla) para que al detectar la regla `usa <nombre>(<param>);` en la máquina, busque la subrutina previamente definida en la tabla de símbolos y fusione sus transiciones sustituyendo el parámetro formal por el argumento real?"*

- **Prompt 3 (Orientación en Codificación - Expansión de Bloques `repetir(n)`):**  
  > *"Necesito implementar una funcionalidad `repetir(n)` en las subrutinas de la máquina de Turing. ¿Cómo puedo transformar una transición repetitiva dentro de un bucle de tamaño $n$ en una cadena de estados intermedios únicos (ej. `q_rep_1`, `q_rep_2`, ..., `q_fin`) para que la máquina opere de forma determinista sin colisiones?"*

- **Prompt 4 (Debugging y Robustez - Cinta infinita y resolución de rutas relativas):**  
  > *"Al mover el cabezal hacia la izquierda con índices negativos, la lista de la cinta lanza IndexError o desfasa el cabezal. ¿Cómo ajustar la clase `Cinta` para que inserte blancos al inicio y ajuste el cabezal a cero de forma transparente? Además, haz que la carga del archivo `.tm` funcione sin importar si se ejecuta desde la raíz o dentro de la subcarpeta `ANTLR`."*
