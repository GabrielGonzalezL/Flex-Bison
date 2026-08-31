# Flex-Bison
Pasos para ejecucion de prueba en analizador lexico

Todo ejecutado desde la carpeta Flex-Bison

  1.  flex +- scannerlexico.l
  2.  g++ ./Example/parsers/lex.yy.cc -o exec
  3.  ./Example/parsers/exec.exe < ./Example/maquinas/maquinas.tm