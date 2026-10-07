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

* **Auditar con el motor Ripley (análisis AST, reglas P1 y AddressSanitizer):**
  ```bash
  ./tp.sh ripley                  # audita todas las librerías y ejercicios
  ./tp.sh ripley ejercicio1       # audita un módulo específico
  ./tp.sh ripley main.c           # audita un archivo suelto
  ```

* **Eliminar un ejercicio o librería:**
  ```bash
  ./tp.sh remove-ex ejercicio4
  ./tp.sh remove-lib mi_libreria
  ```

---

## 🧪 Pruebas

| Comando         | Qué hace                                                                                       |
| :-------------- | :--------------------------------------------------------------------------------------------- |
| `make test`     | Corre el `prueba.c` de cada librería y ejercicio. No corta en la primera suite que falla: al final lista las que fallaron. |
| `make memcheck` | Lo mismo, bajo Valgrind.                                                                       |
| `make fallos`   | Corre cada `test_bin` bajo [vasquez](https://github.com/INGCOM-UNRN-P1/vasquez) (fallos de `malloc`, `fopen`…). Si vasquez no está instalado, avisa y sigue. |

Con [p1_test](https://github.com/INGCOM-UNRN-P1/treadstone) en `libs/p1_test`, los `prueba.c`
nuevos (`./tp.sh add-lib`, `./tp.sh add-ex`) usan sus aserciones; sin p1_test usan `assert`.
`P1_FALLAR_EN(malloc, n)` hace fallar la llamada `n` a `malloc` (también `fopen`, `fread`,
`fwrite` y `fclose`) con los mocks de [holden](https://github.com/INGCOM-UNRN-P1/holden): el
Makefile los genera solo si holden está instalado; si no, ese test se saltea.

Una librería compila solo su `.a` con `make`: si su `prueba.c` no compila, falla su suite,
pero los ejercicios que la usan se siguen compilando y probando.

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

## Devolución automática en GitHub

`.github/workflows/devolucion.yml` llama al workflow `evaluar.yml` de
[sulaco](https://github.com/INGCOM-UNRN-P1/sulaco) en cada push: instala las herramientas del
perfil estudiante con mother, corre `ripley` sobre `ejercicios/` y deja la devolución en el resumen
de la ejecución (pestaña *Actions*) y, en el pull request de feedback de GitHub Classroom, como
comentario. No bloquea la entrega. Para cambiar la rigurosidad, editá `perfil_ripley` (`strict`,
`relaxed` o `exam`).

