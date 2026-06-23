#  Simulador de Fase de Grupos — Mundial 2026

> Proyecto #1 — Organización de Computadores (CCPG1049)  
> Escuela Superior Politécnica del Litoral (ESPOL) — PAO I 2026

---

##  Descripción

Programa en lenguaje ensamblador **MIPS** que simula la fase de grupos de la Copa Mundial de la FIFA 2026.

El usuario selecciona 4 países de una lista de 16 participantes. El sistema genera automáticamente los resultados de los 6 partidos del formato "todos contra todos", construye la tabla de posiciones, la ordena con **Bubble Sort** y determina los 2 equipos clasificados.

---

##  Tecnologías utilizadas

| Herramienta | Versión | Descripción |
|-------------|---------|-------------|
| **MIPS Assembly** | 32 bits | Lenguaje de programación utilizado |
| **MARS** | 4.5 | MIPS Assembler and Runtime Simulator |
| **Java** | 17 LTS | Requerido para ejecutar MARS |

---

##  Requisitos de instalación

### 1. Java JDK 17

MARS necesita Java para funcionar.

- Descarga Java 17 desde: https://adoptium.net/temurin/releases/?version=17
- Selecciona: **Windows → x64 → JDK → .msi**
- Instala normalmente y asegúrate de marcar **"Add to PATH"**
- Verifica la instalación abriendo `cmd` y ejecutando:

```bash
java -version
```

Debe mostrar algo como: `openjdk version "17.x.x"`

### 2. MARS 4.5

- Descarga `Mars4_5.jar` desde: https://courses.missouristate.edu/KenVollmar/MARS/download.htm
- No requiere instalación — es un archivo `.jar` ejecutable directamente

---

##  Cómo ejecutar el proyecto

1. Descarga el archivo `MundialMARS.asm` de este repositorio

2. Abre MARS con doble clic en `Mars4_5.jar`  
   *(Si no abre, ejecuta en cmd: `java -jar Mars4_5.jar`)*

3. En MARS: **File → Open** → selecciona `MundialMARS.asm`

4. Ensambla el programa presionando **F3**  
   Debe aparecer: `Assemble: operation completed successfully`

5. Haz clic en la pestaña **"Run I/O"** en el panel inferior

6. Ejecuta con **F5** (o **Run → Go**)

7. El programa mostrará la lista de 16 países y pedirá ingresar **4 números** (del 1 al 16)

8. El sistema simula los partidos y muestra los resultados automáticamente

---

##  Estructura del repositorio

```
CCPG1049-2026-P1/
│
├── MundialMARS.asm               ← Código fuente en ensamblador MIPS
├── EspecificacionesProyecto.docx ← Documento de especificaciones
└── README.md                     ← Este archivo
```

---

##  Fases del programa

| Fase | Descripción |
|------|-------------|
| **Fase 0** | Selección y validación de 4 países del grupo |
| **Fase 1** | Simulación de 6 partidos con goles aleatorios (0–5) y llenado de arreglos GF, GC y Pts |
| **Fase 2** | Ordenamiento de la tabla con Bubble Sort (por puntos y diferencia de goles) |
| **Fase 3** | Muestra los 2 equipos clasificados |

---

##  Funciones implementadas

- `main` — Punto de entrada, coordina todas las fases
- `mostrarDisponibles` — Lista numerada de los 16 países
- `seleccionarGrupo` — Solicita y valida la selección del usuario
- `aleatorio6` — Genera números aleatorios 0–5 (syscall 42 de MARS)
- `simularPartidos` — Genera partidos y llena arreglos GF, GC, Pts
- `mostrarTabla` — Imprime la tabla de posiciones
- `ordenarTabla` — Bubble Sort descendente por puntos y diferencia de goles
- `mostrarClasificados` — Muestra los 2 equipos clasificados

---
## Autores
-Domenica Bolaños
-Samuel Echeverría
