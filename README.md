# Plantilla-TP (Estructura Mejorada)

Este proyecto está preparado para gestionar de forma dinámica ejercicios y librerías de programación 1.

Este proyecto, está pensado para ser utilizado dentro del [INGCOM-UNRN-P1/entorno](https://github.com/INGCOM-UNRN-P1/entorno)
al utilizar bash y algunas otras herramientas solo presentes en el mismo.

Pueden consultar el manual detallado del entorno en el [repositorio oficial del entorno](https://github.com/INGCOM-UNRN-P1/entorno) y la ayuda del gestor de consola ejecutando `./tp.sh help`.

---

## 📘 Diferencia entre Librería y Ejercicio

Para mantener el código ordenado y modular, el proyecto se divide estrictamente en dos conceptos:

### 1. Librería (ubicadas en `libs/`)
* **Qué es:** Un módulo con funciones y estructuras reutilizables (por ejemplo, utilidades de cadenas o arreglos).
* **Cómo compila:** No produce un programa ejecutable independiente. Se compila como una biblioteca estática (`lib<nombre>.a`).
* **Uso:** Está pensada para ser consumida por uno o varios ejercicios. 
* **Formatos Soportados:**
  * **Librerías Planas (Locales):** Creadas localmente con `./tp.sh add-lib <nombre>`. Tienen sus archivos fuentes `.c` y `.h` sueltos en la raíz de su carpeta y compilan su biblioteca estática directamente allí.
  * **Librerías Estructuradas (Remotas):** Clonadas de repositorios basados en **plantilla-libreria** usando `./tp.sh add-lib <nombre> <url_git>`. Mantienen su estructura compleja (`src/`, `include/`, `tests/`), su especificación en `library.spec` y su propio `Makefile` autónomo. Los ejercicios resuelven automáticamente los directorios de headers y biblioteca apuntando a `include/` y `build/` respectivamente.


### 2. Ejercicio (ubicados en `ejercicios/`)
* **Qué es:** Un programa ejecutable autónomo que resuelve una consigna concreta del trabajo práctico.
* **Cómo compila:** Produce un binario ejecutable (`programa`) que contiene la función `main` en `main.c`.
* **Uso:** Puede importar y enlazar dinámicamente las librerías ubicadas en `libs/`.
* **Pruebas:** Contiene su propio `prueba.c` (compila a `test_bin`) para validar la resolución específica de la consigna.
* **Origen:** Se crean y gestionan únicamente de forma local (no se permiten desde repositorios remotos).

---

## 🛠️ Uso del Gestor de Consola (`tp.sh`)

Podés gestionar todo el TP de forma dinámica usando el script de Bash `./tp.sh`. 

### Comandos Comunes

* **Sincronizar y generar Makefiles:**
  ```bash
  ./tp.sh sync
  ```
  Escanea el proyecto y regenera los `Makefile` de la raíz, de las librerías y de los ejercicios. Esto permite usar `make` de forma nativa sin intermediar con el script.

* **Listar estado del proyecto:**
  ```bash
  ./tp.sh list
  ```
  Muestra qué librerías y ejercicios tenés instalados, junto con sus dependencias declaradas.

* **Agregar una Librería Local (crea plantilla):**
  ```bash
  ./tp.sh add-lib mi_libreria
  ```

* **Agregar una Librería desde un Repositorio Remoto:**
  ```bash
  ./tp.sh add-lib mi_libreria https://github.com/usuario/repo-libreria.git
  ```

* **Agregar un Ejercicio Local indicando dependencias:**
  ```bash
  ./tp.sh add-ex ejercicio4 cadenas,arreglos
  ```

* **Compilar todo el proyecto:**
  ```bash
  ./tp.sh build
  ```

* **Ejecutar un ejercicio:**
  ```bash
  ./tp.sh run ejercicio1
  ```

* **Ejecutar todos los tests:**
  ```bash
  ./tp.sh test
  ```

* **Ejecutar tests de una librería o ejercicio específico:**
  ```bash
  ./tp.sh test cadenas
  ./tp.sh test ejercicio1
  ```

* **Eliminar un ejercicio o librería:**
  ```bash
  ./tp.sh remove-ex ejercicio4
  ./tp.sh remove-lib mi_libreria
  ```

---

## 🎨 Personalización de los Makefiles (`local.mk`)

Todos los `Makefile` generados (raíz, librerías y ejercicios) usan asignaciones débiles (`?=`) para variables clave como `CC` y `CFLAGS`, e incluyen de forma opcional un archivo llamado `local.mk`.

Si querés personalizar la compilación de un módulo sin modificar su `Makefile` principal (evitando que tus cambios se sobrescriban al sincronizar), podés crear un archivo `local.mk` al lado del `Makefile` respectivo:

* **Ejemplo en un ejercicio (`ejercicios/ejercicio1/local.mk`)**:
  ```makefile
  # Forzar el compilador clang y optimización -O3
  CC = clang
  CFLAGS += -O3
  ```
  El gestor ignora los archivos `local.mk`, por lo que tus configuraciones de compilación personalizadas se mantendrán intactas.

---

## ⚠️ Limpieza y Repositorio

Evitá subir archivos compilados (`.o`, `.a`, ejecutables). Antes de subir tus cambios al repositorio, corré:
```bash
make clean
```
O simplemente:
```bash
./tp.sh build
```
*(El gestor se encarga de limpiar todo lo que no va si corrés `make clean`)*
