# ==============================================================================
# Makefile - Simulador de Máquina de Turing con ANTLR v4 y Python
# Certamen 1 - Lenguajes de Programación
# ==============================================================================

PYTHON ?= python
JAVA ?= java
ANTLR_JAR ?= ANTLR/antlr-4.13.1-complete.jar
GRAMMAR ?= ANTLR/lexico.g4
MAIN ?= ANTLR/main.py
SPEC ?= ANTLR/maquina.tm

.PHONY: all help run run-generador run-duplicador simular antlr clean test

# Objetivo por defecto: muestra la ayuda de comandos
all: help

help:
	@echo ==============================================================================
	@echo               SIMULADOR DE MAQUINA DE TURING (ANTLR + PYTHON)
	@echo ==============================================================================
	@echo Comandos disponibles:
	@echo   make run               - Ejecuta la simulacion por defecto (Generador con '_')
	@echo   make run-generador     - Ejecuta la maquina 'Generador'
	@echo   make run-duplicador    - Ejecuta la maquina 'Duplicador' con entrada '101'
	@echo   make test              - Ejecuta pruebas automatizadas de ambas maquinas
	@echo   make simular MAQ=X CINTA=Y - Simula maquina especifica (ej: make simular MAQ=Duplicador CINTA=110)
	@echo   make antlr             - Recompila la gramatica lexico.g4 con ANTLR 4
	@echo   make clean             - Limpia archivos temporales y cache (__pycache__)
	@echo ==============================================================================

# Ejecutar simulación por defecto
run:
	$(PYTHON) $(MAIN)

# Ejecutar máquina Generador (usa subrutinas escribir_unos(4) y moverhastablanco(IZQ))
run-generador:
	$(PYTHON) $(MAIN) $(SPEC) Generador _

# Ejecutar máquina Duplicador (duplica la cadena dada, por defecto '101')
run-duplicador:
	$(PYTHON) $(MAIN) $(SPEC) Duplicador 101

# Ejecutar simulación parametrizada: make simular MAQ=Duplicador CINTA=110
simular:
	$(PYTHON) $(MAIN) $(SPEC) $(MAQ) $(CINTA)

# Ejecutar suite de pruebas de validación
test:
	@echo [1/2] Probando maquina Generador...
	$(PYTHON) $(MAIN) $(SPEC) Generador _
	@echo.
	@echo [2/2] Probando maquina Duplicador con entrada 101...
	$(PYTHON) $(MAIN) $(SPEC) Duplicador 101

# Recompilar gramática ANTLR
antlr:
	$(JAVA) -jar $(ANTLR_JAR) -Dlanguage=Python3 -o ANTLR $(GRAMMAR)

# Limpiar archivos compilados y cache de Python
clean:
	$(PYTHON) -c "import pathlib, shutil; [shutil.rmtree(p, ignore_errors=True) for p in pathlib.Path('.').rglob('__pycache__')]; [p.unlink() for p in pathlib.Path('.').rglob('*.pyc') if p.exists()]"
	@echo Limpieza completada.
