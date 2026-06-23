
# ESPOL - ORGANIZACION DE COMPUTADORES - CCPG1049
# PROYECTO PRIMER PARCIAL
# Simulador de Fase de Grupos del Mundial 2026
#
# Ensamblador : MIPS
# Entorno     : Mipsy Online (mipsy.cse.unsw.edu.au)


# ---- Syscalls ----
# 1  = imprimir entero
# 4  = imprimir string
# 5  = leer entero
# 8  = leer string
# 10 = salir
# 11 = imprimir caracter

.data

# ---- Lista de paises del Mundial 2026 (16 paises) ----
p00: .asciiz "Argentina"
p01: .asciiz "Brasil"
p02: .asciiz "Francia"
p03: .asciiz "Alemania"
p04: .asciiz "Espana"
p05: .asciiz "Inglaterra"
p06: .asciiz "Portugal"
p07: .asciiz "Italia"
p08: .asciiz "Uruguay"
p09: .asciiz "Colombia"
p10: .asciiz "Mexico"
p11: .asciiz "Estados Unidos"
p12: .asciiz "Canada"
p13: .asciiz "Japon"
p14: .asciiz "Corea del Sur"
p15: .asciiz "Marruecos"

# tabla de punteros a los nombres
listaPaises:
    .word p00, p01, p02, p03, p04, p05, p06, p07
    .word p08, p09, p10, p11, p12, p13, p14, p15

# ---- Grupo seleccionado ----
# 4 indices (0-15) indicando cual pais se eligio
grupoIdx:   .word 0, 0, 0, 0

# ---- Arreglos paralelos ----
GF:  .word 0, 0, 0, 0        # goles a favor
GC:  .word 0, 0, 0, 0        # goles en contra
Pts: .word 0, 0, 0, 0        # puntos FIFA

# ---- Pares de partidos "todos contra todos" ----
# 6 partidos entre 4 equipos (indices dentro del grupo)
pardA: .word 0, 0, 0, 1, 1, 2
pardB: .word 1, 2, 3, 2, 3, 3

# ---- Buffer de entrada ----
bufEntrada: .space 32

# ---- Mensajes ----
msgBanner1: .asciiz "============================================\n"
msgBanner2: .asciiz "  SIMULADOR FASE DE GRUPOS - MUNDIAL 2026\n"
msgBanner3: .asciiz "============================================\n\n"

msgDisponibles: .asciiz "\nPaises disponibles:\n"
msgPuntoEsp:    .asciiz ". "
msgSalto:       .asciiz "\n"
msgDosPuntos:   .asciiz ": "
msgEsp3:        .asciiz "   "
msgGuion:       .asciiz " - "
msgGuion2:      .asciiz " -- "

msgPedirPais:   .asciiz "\nIngrese el numero del pais para la posicion "
msgGrupoConf:   .asciiz "\nGrupo conformado:\n"
msgPartidos:    .asciiz "\nResultados (todos contra todos):\n"
msgTablaSin:    .asciiz "\nTabla de posiciones (SIN ORDENAR):\n"
msgTablaOrd:    .asciiz "\nTabla de posiciones (ORDENADA):\n"
msgEncabezado:  .asciiz "Pos  Pais              GF   GC   DG   Pts\n"
msgSeparador:   .asciiz "------------------------------------------\n"
msgClasif:      .asciiz "\nEquipos clasificados a la siguiente fase:\n"

msgErrRango:    .asciiz "  >> Numero fuera de rango. Ingrese entre 1 y 16.\n"
msgErrRepetido: .asciiz "  >> Ese pais ya fue seleccionado. Elija otro.\n"

msgNum1:        .asciiz "1. "
msgNum2:        .asciiz "2. "
msgGoles:       .asciiz " goles\n"
msgPosicion:    .asciiz "Posicion "

# ---- Marca de ya seleccionado (1 = usado) ----
yaSelec: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

# ---- Variable temporal para Bubble Sort ----
tmpWord: .word 0

# ============================================================
.text
.globl main

# ============================================================
# MAIN
# ============================================================
main:
    # Mostrar banner
    la   $a0, msgBanner1
    li   $v0, 4
    syscall
    la   $a0, msgBanner2
    syscall
    la   $a0, msgBanner3
    syscall

    jal  mostrarDisponibles    # Fase 0: lista de paises
    jal  seleccionarGrupo      # Fase 0: elegir 4 paises
    jal  simularPartidos       # Fase 1: generar partidos y llenar GF/GC/Pts

    # Fase 1.3: tabla sin ordenar
    la   $a0, msgTablaSin
    li   $v0, 4
    syscall
    jal  mostrarTabla

    jal  ordenarTabla          # Fase 2: Bubble Sort

    # Fase 2.2: tabla ordenada
    la   $a0, msgTablaOrd
    li   $v0, 4
    syscall
    jal  mostrarTabla

    jal  mostrarClasificados   # Fase 3

    la   $a0, msgSalto
    li   $v0, 4
    syscall

    li   $v0, 10
    syscall


# ============================================================
# mostrarDisponibles
# Imprime lista numerada de los 16 paises disponibles
# ============================================================
mostrarDisponibles:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)

    la   $a0, msgDisponibles
    li   $v0, 4
    syscall

    li   $s0, 0                 # indice i = 0
dispLoop:
    bge  $s0, 16, dispFin

    # imprimir numero (i+1)
    addiu $a0, $s0, 1
    li   $v0, 1
    syscall

    la   $a0, msgPuntoEsp
    li   $v0, 4
    syscall

    # imprimir nombre del pais
    la   $t0, listaPaises
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 4
    syscall

    la   $a0, msgSalto
    li   $v0, 4
    syscall

    addiu $s0, $s0, 1
    j    dispLoop
dispFin:
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addiu $sp, $sp, 8
    jr   $ra


# ============================================================
# seleccionarGrupo
# Pide al usuario 4 numeros (1-16) validando rango y repeticion
# Guarda los indices (0-15) en grupoIdx
# ============================================================
seleccionarGrupo:
    addiu $sp, $sp, -12
    sw    $ra, 8($sp)
    sw    $s0, 4($sp)           # posicion del grupo (0..3)
    sw    $s1, 0($sp)

    li   $s0, 0
selLoop:
    bge  $s0, 4, selFin

    la   $a0, msgPedirPais
    li   $v0, 4
    syscall

    addiu $a0, $s0, 1
    li   $v0, 1
    syscall

    la   $a0, msgDosPuntos
    li   $v0, 4
    syscall

    # leer numero
    li   $v0, 5
    syscall
    move $s1, $v0              # numero ingresado (1-16)

    # validar rango
    blt  $s1, 1,  errRango
    bgt  $s1, 16, errRango
    j    rangoOk
errRango:
    la   $a0, msgErrRango
    li   $v0, 4
    syscall
    j    selLoop
rangoOk:
    # convertir a indice 0-15
    addiu $s1, $s1, -1

    # validar que no este repetido
    la   $t0, yaSelec
    add  $t0, $t0, $s1
    lb   $t1, 0($t0)
    bne  $t1, $zero, errRepetido
    j    libreOk
errRepetido:
    la   $a0, msgErrRepetido
    li   $v0, 4
    syscall
    j    selLoop
libreOk:
    # marcar como usado
    la   $t0, yaSelec
    add  $t0, $t0, $s1
    li   $t1, 1
    sb   $t1, 0($t0)

    # guardar indice en grupoIdx[s0]
    la   $t0, grupoIdx
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    sw   $s1, 0($t0)

    addiu $s0, $s0, 1
    j    selLoop
selFin:
    # mostrar grupo conformado
    la   $a0, msgGrupoConf
    li   $v0, 4
    syscall

    li   $s0, 0
mostrarGrupoLoop:
    bge  $s0, 4, mostrarGrupoFin

    addiu $a0, $s0, 1
    li   $v0, 1
    syscall

    la   $a0, msgPuntoEsp
    li   $v0, 4
    syscall

    # nombre del pais
    la   $t0, grupoIdx
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)           # indice global del pais

    la   $t0, listaPaises
    sll  $t1, $t2, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 4
    syscall

    la   $a0, msgSalto
    li   $v0, 4
    syscall

    addiu $s0, $s0, 1
    j    mostrarGrupoLoop
mostrarGrupoFin:
    lw   $s1, 0($sp)
    lw   $s0, 4($sp)
    lw   $ra, 8($sp)
    addiu $sp, $sp, 12
    jr   $ra


# ============================================================
# aleatorio6
# Retorna en $v0 un numero entre 0 y 5 (inclusive)
# Usa syscall 42 de MARS (Random Int Range)
#   $a0 = ID del generador (0)
#   $a1 = limite superior (6 -> genera 0..5)
# Resultado en $a0
# ============================================================
aleatorio6:
    li   $a0, 0                # ID generador
    li   $a1, 6                # rango: 0..5
    li   $v0, 42               # syscall Random Int Range
    syscall
    move $v0, $a0              # resultado queda en $a0
    jr   $ra


# ============================================================
# simularPartidos
# Genera los 6 partidos, muestra resultados y llena GF/GC/Pts
# ============================================================
simularPartidos:
    addiu $sp, $sp, -24
    sw    $ra,  20($sp)
    sw    $s0,  16($sp)        # indice partido (0..5)
    sw    $s1,  12($sp)        # indice equipo A en grupo
    sw    $s2,   8($sp)        # indice equipo B en grupo
    sw    $s3,   4($sp)        # goles A
    sw    $s4,   0($sp)        # goles B

    la   $a0, msgPartidos
    li   $v0, 4
    syscall

    li   $s0, 0
partLoop:
    bge  $s0, 6, partFin

    # obtener indices del partido
    la   $t0, pardA
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $s1, 0($t0)

    la   $t0, pardB
    add  $t0, $t0, $t1
    lw   $s2, 0($t0)

    # generar goles A
    jal  aleatorio6
    move $s3, $v0

    # generar goles B
    jal  aleatorio6
    move $s4, $v0

    # mostrar: NombreA  golesA - golesB  NombreB
    jal  imprimirNombreGrupo_s1    # nombre equipo A (usa $s1)

    la   $a0, msgEsp3
    li   $v0, 4
    syscall

    move $a0, $s3
    li   $v0, 1
    syscall

    la   $a0, msgGuion
    li   $v0, 4
    syscall

    move $a0, $s4
    li   $v0, 1
    syscall

    la   $a0, msgEsp3
    li   $v0, 4
    syscall

    jal  imprimirNombreGrupo_s2    # nombre equipo B (usa $s2)

    la   $a0, msgSalto
    li   $v0, 4
    syscall

    # actualizar GF y GC del equipo A
    la   $t0, GF
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    add  $t2, $t2, $s3
    sw   $t2, 0($t0)

    la   $t0, GC
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    add  $t2, $t2, $s4
    sw   $t2, 0($t0)

    # actualizar GF y GC del equipo B
    la   $t0, GF
    sll  $t1, $s2, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    add  $t2, $t2, $s4
    sw   $t2, 0($t0)

    la   $t0, GC
    sll  $t1, $s2, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    add  $t2, $t2, $s3
    sw   $t2, 0($t0)

    # puntos FIFA
    beq  $s3, $s4, esEmpate
    bgt  $s3, $s4, ganaA
    # gana B
    la   $t0, Pts
    sll  $t1, $s2, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    addiu $t2, $t2, 3
    sw   $t2, 0($t0)
    j    sigPartido
ganaA:
    la   $t0, Pts
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    addiu $t2, $t2, 3
    sw   $t2, 0($t0)
    j    sigPartido
esEmpate:
    la   $t0, Pts
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    addiu $t2, $t2, 1
    sw   $t2, 0($t0)

    la   $t0, Pts
    sll  $t1, $s2, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    addiu $t2, $t2, 1
    sw   $t2, 0($t0)

sigPartido:
    addiu $s0, $s0, 1
    j    partLoop
partFin:
    lw   $s4,   0($sp)
    lw   $s3,   4($sp)
    lw   $s2,   8($sp)
    lw   $s1,  12($sp)
    lw   $s0,  16($sp)
    lw   $ra,  20($sp)
    addiu $sp, $sp, 24
    jr   $ra


# ============================================================
# imprimirNombreGrupo_s1
# Imprime el nombre del equipo en posicion $s1 del grupo
# ============================================================
imprimirNombreGrupo_s1:
    la   $t0, grupoIdx
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t0, listaPaises
    sll  $t1, $t2, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 4
    syscall
    jr   $ra


# ============================================================
# imprimirNombreGrupo_s2
# Imprime el nombre del equipo en posicion $s2 del grupo
# ============================================================
imprimirNombreGrupo_s2:
    la   $t0, grupoIdx
    sll  $t1, $s2, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t0, listaPaises
    sll  $t1, $t2, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 4
    syscall
    jr   $ra


# ============================================================
# imprimirNombrePorIdx
# $a0 = indice (0..3) dentro del grupo
# Imprime el nombre correspondiente
# ============================================================
imprimirNombrePorIdx:
    la   $t0, grupoIdx
    sll  $t1, $a0, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t0, listaPaises
    sll  $t1, $t2, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 4
    syscall
    jr   $ra


# ============================================================
# mostrarTabla
# Imprime encabezado y 4 filas con GF, GC, DG, Pts
# ============================================================
mostrarTabla:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)

    la   $a0, msgEncabezado
    li   $v0, 4
    syscall
    la   $a0, msgSeparador
    syscall

    li   $s0, 0
tablaLoop:
    bge  $s0, 4, tablaFin

    # numero de posicion
    addiu $a0, $s0, 1
    li   $v0, 1
    syscall

    la   $a0, msgPuntoEsp
    li   $v0, 4
    syscall

    # nombre del equipo
    move $a0, $s0
    jal  imprimirNombrePorIdx

    la   $a0, msgEsp3
    li   $v0, 4
    syscall

    # GF
    la   $t0, GF
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    la   $a0, msgEsp3
    li   $v0, 4
    syscall

    # GC
    la   $t0, GC
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    la   $a0, msgEsp3
    li   $v0, 4
    syscall

    # DG = GF - GC
    la   $t0, GF
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)

    la   $t0, GC
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $t3, 0($t0)

    sub  $a0, $t2, $t3
    li   $v0, 1
    syscall

    la   $a0, msgEsp3
    li   $v0, 4
    syscall

    # Pts
    la   $t0, Pts
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall

    la   $a0, msgSalto
    li   $v0, 4
    syscall

    addiu $s0, $s0, 1
    j    tablaLoop
tablaFin:
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addiu $sp, $sp, 8
    jr   $ra


# ============================================================
# ordenarTabla
# Bubble Sort DESCENDENTE por Pts; desempate por DG (GF-GC)
# Ordena los arreglos paralelos: grupoIdx, GF, GC, Pts
# ============================================================
ordenarTabla:
    addiu $sp, $sp, -16
    sw    $ra, 12($sp)
    sw    $s0,  8($sp)    # i (pasada exterior)
    sw    $s1,  4($sp)    # j (pasada interior)
    sw    $s2,  0($sp)    # limite = 3 - i

    li   $s0, 0
outerLoop:
    bge  $s0, 3, outerFin

    li   $s1, 0
    li   $t9, 3
    sub  $s2, $t9, $s0    # limite = 3 - i

innerLoop:
    bge  $s1, $s2, innerFin

    # cargar Pts[j] y Pts[j+1]
    la   $t0, Pts
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)       # Pts[j]
    addiu $t3, $s1, 1
    sll  $t3, $t3, 2
    la   $t0, Pts
    add  $t0, $t0, $t3
    lw   $t4, 0($t0)       # Pts[j+1]

    blt  $t2, $t4, hacerSwap   # Pts[j] < Pts[j+1] -> swap
    bgt  $t2, $t4, noSwap

    # puntos iguales: comparar DG
    la   $t0, GF
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t5, 0($t0)
    la   $t0, GC
    add  $t0, $t0, $t1
    lw   $t6, 0($t0)
    sub  $t5, $t5, $t6     # DG[j] = GF[j]-GC[j]

    addiu $t1, $s1, 1
    sll  $t1, $t1, 2
    la   $t0, GF
    add  $t0, $t0, $t1
    lw   $t7, 0($t0)
    la   $t0, GC
    add  $t0, $t0, $t1
    lw   $t8, 0($t0)
    sub  $t7, $t7, $t8     # DG[j+1]

    blt  $t5, $t7, hacerSwap
    j    noSwap

hacerSwap:
    # intercambiar Pts[j] <-> Pts[j+1]
    la   $t0, Pts
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    addiu $t3, $s1, 1
    sll  $t3, $t3, 2
    la   $t4, Pts
    add  $t4, $t4, $t3
    lw   $t5, 0($t4)
    sw   $t5, 0($t0)
    sw   $t2, 0($t4)

    # intercambiar GF[j] <-> GF[j+1]
    la   $t0, GF
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t4, GF
    add  $t4, $t4, $t3
    lw   $t5, 0($t4)
    sw   $t5, 0($t0)
    sw   $t2, 0($t4)

    # intercambiar GC[j] <-> GC[j+1]
    la   $t0, GC
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t4, GC
    add  $t4, $t4, $t3
    lw   $t5, 0($t4)
    sw   $t5, 0($t0)
    sw   $t2, 0($t4)

    # intercambiar grupoIdx[j] <-> grupoIdx[j+1]
    la   $t0, grupoIdx
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t4, grupoIdx
    add  $t4, $t4, $t3
    lw   $t5, 0($t4)
    sw   $t5, 0($t0)
    sw   $t2, 0($t4)

noSwap:
    addiu $s1, $s1, 1
    j    innerLoop

innerFin:
    addiu $s0, $s0, 1
    j    outerLoop

outerFin:
    lw   $s2,  0($sp)
    lw   $s1,  4($sp)
    lw   $s0,  8($sp)
    lw   $ra, 12($sp)
    addiu $sp, $sp, 16
    jr   $ra


# ============================================================
# mostrarClasificados
# Imprime los 2 primeros de la tabla (posiciones 0 y 1)
# ============================================================
mostrarClasificados:
    addiu $sp, $sp, -4
    sw    $ra, 0($sp)

    la   $a0, msgClasif
    li   $v0, 4
    syscall

    # 1er clasificado
    la   $a0, msgNum1
    li   $v0, 4
    syscall
    li   $a0, 0
    jal  imprimirNombrePorIdx
    la   $a0, msgEsp3
    li   $v0, 4
    syscall
    la   $t0, Pts
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall
    la   $a0, msgGoles
    li   $v0, 4
    syscall

    # 2do clasificado
    la   $a0, msgNum2
    li   $v0, 4
    syscall
    li   $a0, 1
    jal  imprimirNombrePorIdx
    la   $a0, msgEsp3
    li   $v0, 4
    syscall
    la   $t0, Pts
    lw   $a0, 4($t0)
    li   $v0, 1
    syscall
    la   $a0, msgGoles
    li   $v0, 4
    syscall

    lw   $ra, 0($sp)
    addiu $sp, $sp, 4
    jr   $ra
