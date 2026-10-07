# Variables generales
CC ?= gcc
CFLAGS ?= -Wall -Wextra -std=c11 -pedantic -g

# Dependencias para las pruebas (separadas por espacio)
TEST_LIB_NAME ?= p1_test
# Solo las que están en libs/ (en TP1 no hay p1_test)
TEST_LIBS ?= $(foreach lib,$(TEST_LIB_NAME),$(if $(wildcard $(LIBS_DIR)/$(lib)),$(lib)))

# Directorio raíz del proyecto para referenciar libs
ROOT_DIR = ../..
LIBS_DIR = $(ROOT_DIR)/libs

# Detección dinámica de los directorios de headers y biblioteca según el esquema (plano o estructurado)
TEST_INCLUDE_DIRS = $(foreach lib,$(TEST_LIBS),$(if $(wildcard $(LIBS_DIR)/$(lib)/include),-I$(LIBS_DIR)/$(lib)/include -I$(LIBS_DIR)/$(lib),-I$(LIBS_DIR)/$(lib)))
TEST_LIBRARY_DIRS = $(foreach lib,$(TEST_LIBS),$(if $(wildcard $(LIBS_DIR)/$(lib)/build),-L$(LIBS_DIR)/$(lib)/build,$(if $(wildcard $(LIBS_DIR)/$(lib)/lib),-L$(LIBS_DIR)/$(lib)/lib,-L$(LIBS_DIR)/$(lib))))
TEST_LIBRARY = $(addprefix -l,$(TEST_LIBS))

# Fallos inyectados (opcionales): P1_FALLAR_EN usa los mocks de holden solo si
# holden está instalado y prueba.c la usa; "make fallos" corre vasquez si está.
HOLDEN_FUNCIONES = malloc fopen fread fwrite fclose
ifneq ($(shell command -v holden 2>/dev/null),)
ifneq ($(shell grep -l P1_FALLAR_EN prueba.c 2>/dev/null),)
TEST_CFLAGS += -DP1_HOLDEN
TEST_EXTRA_OBJS += holden_mocks.o
TEST_LDFLAGS += $(foreach f,$(HOLDEN_FUNCIONES),-Wl,--wrap=$(f))
endif
endif

# Archivos comunes, se autodetectan los .c y .h
SRCS = $(filter-out prueba.c holden_mocks.c, $(wildcard *.c))
HDRS = $(wildcard *.h)

# Nombre de la librería estática (se deduce del nombre de la carpeta)
LIB_NAME := $(notdir $(CURDIR))
LIBRARY_NAME = lib$(LIB_NAME).a

# Archivos para tests
TEST_TARGET = test_bin
TEST_SRCS = $(SRCS) prueba.c
TEST_OBJS = $(TEST_SRCS:.c=.o)

# Archivos objeto de la librería
OBJS = $(SRCS:.c=.o)

# Solo la librería: un prueba.c que no compila no frena a los ejercicios
all: $(LIBRARY_NAME)

# Crear la librería estática .a
$(LIBRARY_NAME): $(OBJS)
	@echo "Generando librería estática $@"
	ar rcs $@ $^

# Compilar el ejecutable de pruebas
$(TEST_TARGET): $(TEST_OBJS) $(TEST_EXTRA_OBJS)
	@for lib in $(TEST_LIBS); do \
		if [ -d "$(LIBS_DIR)/$$lib" ] && [ -f "$(LIBS_DIR)/$$lib/Makefile" ] && [ ! -f "$(LIBS_DIR)/$$lib/lib$$lib.a" ] && [ ! -f "$(LIBS_DIR)/$$lib/build/lib$$lib.a" ]; then \
			echo "Compilando dependencia $$lib..."; \
			$(MAKE) -C "$(LIBS_DIR)/$$lib" >/dev/null 2>&1 || exit 1; \
		fi; \
	done
	@echo "Compilando $@"
	$(CC) $(CFLAGS) -o $@ $(TEST_OBJS) $(TEST_EXTRA_OBJS) $(TEST_LIBRARY_DIRS) $(TEST_LIBRARY) $(TEST_LDFLAGS)

# Regla específica para compilar el archivo de pruebas con sus dependencias
prueba.o: prueba.c $(HDRS)
	@echo "Compilando $<"
	$(CC) $(CFLAGS) $(TEST_CFLAGS) $(TEST_INCLUDE_DIRS) -c $<

# Regla genérica para compilar archivos .o a partir de .c
%.o: %.c $(HDRS)
	@echo "Compilando $<"
	$(CC) $(CFLAGS) -c $<

# Mocks de holden para P1_FALLAR_EN
holden_mocks.c:
	holden generate $(HOLDEN_FUNCIONES) -n 0 -o $@ >/dev/null

# Inyección de fallos con vasquez
.PHONY: fallos
fallos: $(TEST_TARGET)
	@if command -v vasquez >/dev/null 2>&1; then \
		vasquez check ./$(TEST_TARGET); \
	else \
		echo "vasquez no está instalado: se saltea la inyección de fallos"; \
	fi

# Ejecutar las pruebas
.PHONY: test
test: $(TEST_TARGET)
	@echo "Probando librería..."
	./$(TEST_TARGET)

# Verificación con Valgrind
.PHONY: memcheck
memcheck: $(TEST_TARGET)
	@echo "Verificando con Valgrind..."
	valgrind --leak-check=full --show-leak-kinds=all --error-exitcode=1 ./$(TEST_TARGET)

# Limpiar archivos objeto y ejecutables
.PHONY: clean
clean:
	@echo "Limpiando..."
	rm -f *.o holden_mocks.c $(LIBRARY_NAME) $(TEST_TARGET)

# Incluir personalizaciones locales si existen
-include local.mk
