#### Esta primera parte es tecnicamente configurable, pero no se recomienda.

# Nombres de las librerías (sin prefijo 'lib' y sin extensión '.a')
LIB_NAME = cadenas arreglos

# Directorios de los programas
PROG_DIRS = ejercicio1 ejercicio2 ejercicio3

#### A partir de acá el es la parte mágica.

# Compilador
CC = gcc

# Opciones de compilación
CFLAGS = -Wall -Wextra -pedantic -g

# Directorios de las librerías
LIB_DIR = $(addprefix ../,$(LIB_NAME))

# Archivos de las librerías estáticas
LIBRARY = $(addprefix -l,$(LIB_NAME))
LIBRARY_DIRS = $(addprefix -L,$(LIB_DIR))


# Objetivos para compilar todos los programas y las librerías
.PHONY: all
all: librerias $(PROG_DIRS)

# Ejecutar programas para cada directorio en PROG_DIRS
.PHONY: run
run: $(PROG_DIRS)
	@echo "Ejecutando programas..."
	$(foreach prog_dir, $(PROG_DIRS), $(MAKE) -C $(prog_dir) run;)

# Compilar las librerías estáticas
.PHONY: librerias
librerias: 
	@echo "Compilando librerías..."
	@echo "Cadenas Seguras"
	$(MAKE) -C cadenas
	@echo "Arreglos"
	$(MAKE) -C arreglos


# Regla para compilar cada programa
$(PROG_DIRS): librerias
	@echo "Compilando programa en $@"
	$(MAKE) -C $@

# Limpieza generales de todos los programas y librerías
.PHONY: clean
clean:
	@echo "Limpiando todos los programas y librerías..."
	$(MAKE) -C cadenas clean
	$(MAKE) -C arreglos clean
	$(MAKE) -C ejercicio2 clean
	$(MAKE) -C ejercicio3 clean


# Ejecutar pruebas para un programa específico (ejemplo: ejercicio2)
.PHONY: test
test: 
	@echo "Ejecutando pruebas..."
	@echo "Cadenas Seguras"
	$(MAKE) -C cadenas test
	@echo "Arreglos"
	$(MAKE) -C arreglos test
	$(foreach prog_dir, $(PROG_DIRS), $(MAKE) -C $(prog_dir) test;)

