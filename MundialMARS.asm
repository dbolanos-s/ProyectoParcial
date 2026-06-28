# ESPOL - ORGANIZACION DE COMPUTADORES - CCPG1049
# PROYECTO PRIMER PARCIAL
# Simulador de Fase de Grupos del Mundial 2026
#
# Ensamblador : MIPS
# Entorno     : MARS 4.5 (MIPS Assembler and Runtime Simulator)

.data

# ---- 48 paises clasificados al Mundial 2026 ----
# CONMEBOL (6)
p00: .asciiz "Argentina"
p01: .asciiz "Brasil"
p02: .asciiz "Colombia"
p03: .asciiz "Ecuador"
p04: .asciiz "Paraguay"
p05: .asciiz "Uruguay"
# UEFA (16)
p06: .asciiz "Alemania"
p07: .asciiz "Austria"
p08: .asciiz "Belgica"
p09: .asciiz "Bosnia y Herzegovina"
p10: .asciiz "Croacia"
p11: .asciiz "España"
p12: .asciiz "Escocia"
p13: .asciiz "Francia"
p14: .asciiz "Paises Bajos"
p15: .asciiz "Noruega"
p16: .asciiz "Portugal"
p17: .asciiz "Republica Checa"
p18: .asciiz "Suecia"
p19: .asciiz "Suiza"
p20: .asciiz "Turquia"
p21: .asciiz "Inglaterra"
# CAF (10)
p22: .asciiz "Argelia"
p23: .asciiz "Cabo Verde"
p24: .asciiz "Costa de Marfil"
p25: .asciiz "Egipto"
p26: .asciiz "Ghana"
p27: .asciiz "Marruecos"
p28: .asciiz "RD del Congo"
p29: .asciiz "Senegal"
p30: .asciiz "Sudafrica"
p31: .asciiz "Tunez"
# AFC (9)
p32: .asciiz "Arabia Saudita"
p33: .asciiz "Australia"
p34: .asciiz "Catar"
p35: .asciiz "Corea del Sur"
p36: .asciiz "Irak"
p37: .asciiz "Iran"
p38: .asciiz "Japon"
p39: .asciiz "Jordania"
p40: .asciiz "Uzbekistan"
# CONCACAF (6)
p41: .asciiz "Canada"
p42: .asciiz "Curazao"
p43: .asciiz "Estados Unidos"
p44: .asciiz "Haiti"
p45: .asciiz "Mexico"
p46: .asciiz "Panama"
# OFC (1)
p47: .asciiz "Nueva Zelanda"

listaPaises:
    .word p00,p01,p02,p03,p04,p05,p06,p07
    .word p08,p09,p10,p11,p12,p13,p14,p15
    .word p16,p17,p18,p19,p20,p21,p22,p23
    .word p24,p25,p26,p27,p28,p29,p30,p31
    .word p32,p33,p34,p35,p36,p37,p38,p39
    .word p40,p41,p42,p43,p44,p45,p46,p47

# ---- Grupo seleccionado (4 indices 0-47) ----
grupoIdx: .word 0, 0, 0, 0

# ---- Arreglos paralelos ----
GF:  .word 0, 0, 0, 0
GC:  .word 0, 0, 0, 0
Pts: .word 0, 0, 0, 0

# ---- Pares de partidos todos contra todos ----
pardA: .word 0, 0, 0, 1, 1, 2
pardB: .word 1, 2, 3, 2, 3, 3

# ---- Mensajes ----
msgBanner1: .asciiz "\n"
msgBanner2: .asciiz "==============================\n  SIMULADOR FASE DE GRUPOS - MUNDIAL 2026\n==============================\n"
msgBanner3: .asciiz "\n\n"

msgConmeb:  .asciiz "\n-- CONMEBOL (Sudamerica) --\n"
msgUefa:    .asciiz "\n-- UEFA (Europa) --\n"
msgCaf:     .asciiz "\n-- CAF (Africa) --\n"
msgAfc:     .asciiz "\n-- AFC (Asia) --\n"
msgConcacaf:.asciiz "\n-- CONCACAF (Norte/Centro America) --\n"
msgOfc:     .asciiz "\n-- OFC (Oceania) --\n"

msgDisp:    .asciiz "Paises participantes del Mundial 2026:\n"
msgPuntoEsp:.asciiz ". "
msgSalto:   .asciiz "\n"
msgDosPuntos:.asciiz ": "
msgEsp3:    .asciiz "   "
msgGuion:   .asciiz " - "

msgPedirPais:  .asciiz "\nIngrese el numero del pais para la posicion "
msgGrupoConf:  .asciiz "\nGrupo conformado:\n"
msgPartidos:   .asciiz "\nResultados (todos contra todos):\n"
msgTablaSin:   .asciiz "\n==============================\nTABLA DE POSICIONES (SIN ORDENAR)\n==============================\n"
msgTablaOrd:   .asciiz "\n==============================\nTABLA DE POSICIONES (ORDENADA)\n==============================\n"
msgEncabezado: .asciiz "Pos  Pais                    GF   GC   DG   Pts\n"
msgSeparador:  .asciiz "------------------------------------------------\n"
msgClasif:     .asciiz "\n==============================\nEQUIPOS CLASIFICADOS\n==============================\n"
msgErrRango:   .asciiz "  >> Numero fuera de rango. Ingrese entre 1 y 48.\n"
msgErrRepetido:.asciiz "  >> Ese pais ya fue seleccionado. Elija otro.\n"
msgNum1:    .asciiz "1. "
msgNum2:    .asciiz "2. "
msgPtos:    .asciiz " pts\n"

# ---- Marcas de ya seleccionado ----
yaSelec: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
         .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.text
.globl main

main:
    la   $a0, msgBanner1
    li   $v0, 4
    syscall
    la   $a0, msgBanner2
    syscall
    la   $a0, msgBanner3
    syscall

    jal  mostrarDisponibles
    jal  seleccionarGrupo
    jal  simularPartidos

    la   $a0, msgTablaSin
    li   $v0, 4
    syscall
    jal  mostrarTabla

    jal  ordenarTabla

    la   $a0, msgTablaOrd
    li   $v0, 4
    syscall
    jal  mostrarTabla

    jal  mostrarClasificados

    la   $a0, msgSalto
    li   $v0, 4
    syscall
    li   $v0, 10
    syscall


# mostrarDisponibles: lista los 48 paises por confederacion
mostrarDisponibles:
    addiu $sp, $sp, -8
    sw    $ra, 4($sp)
    sw    $s0, 0($sp)

    la   $a0, msgDisp
    li   $v0, 4
    syscall

    # CONMEBOL 0-5
    la   $a0, msgConmeb
    li   $v0, 4
    syscall
    li   $s0, 0
    li   $t9, 6
    jal  imprimirRango

    # UEFA 6-21
    la   $a0, msgUefa
    li   $v0, 4
    syscall
    li   $s0, 6
    li   $t9, 22
    jal  imprimirRango

    # CAF 22-31
    la   $a0, msgCaf
    li   $v0, 4
    syscall
    li   $s0, 22
    li   $t9, 32
    jal  imprimirRango

    # AFC 32-40
    la   $a0, msgAfc
    li   $v0, 4
    syscall
    li   $s0, 32
    li   $t9, 41
    jal  imprimirRango

    # CONCACAF 41-46
    la   $a0, msgConcacaf
    li   $v0, 4
    syscall
    li   $s0, 41
    li   $t9, 47
    jal  imprimirRango

    # OFC 47
    la   $a0, msgOfc
    li   $v0, 4
    syscall
    li   $s0, 47
    li   $t9, 48
    jal  imprimirRango

    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addiu $sp, $sp, 8
    jr   $ra

# imprimirRango: imprime paises desde $s0 hasta $t9-1
imprimirRango:
    addiu $sp, $sp, -4
    sw    $ra, 0($sp)
rangoLoop:
    bge  $s0, $t9, rangoFin
    addiu $a0, $s0, 1
    li   $v0, 1
    syscall
    la   $a0, msgPuntoEsp
    li   $v0, 4
    syscall
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
    j    rangoLoop
rangoFin:
    lw   $ra, 0($sp)
    addiu $sp, $sp, 4
    jr   $ra


# seleccionarGrupo
seleccionarGrupo:
    addiu $sp, $sp, -12
    sw    $ra, 8($sp)
    sw    $s0, 4($sp)
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

    li   $v0, 5
    syscall
    move $s1, $v0

    blt  $s1, 1,  errRango48
    bgt  $s1, 48, errRango48
    j    rangoOk48
errRango48:
    la   $a0, msgErrRango
    li   $v0, 4
    syscall
    j    selLoop
rangoOk48:
    addiu $s1, $s1, -1
    la   $t0, yaSelec
    add  $t0, $t0, $s1
    lb   $t1, 0($t0)
    bne  $t1, $zero, errRep48
    j    libreOk48
errRep48:
    la   $a0, msgErrRepetido
    li   $v0, 4
    syscall
    j    selLoop
libreOk48:
    la   $t0, yaSelec
    add  $t0, $t0, $s1
    li   $t1, 1
    sb   $t1, 0($t0)
    la   $t0, grupoIdx
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    sw   $s1, 0($t0)
    addiu $s0, $s0, 1
    j    selLoop
selFin:
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
    la   $t0, grupoIdx
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
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


# aleatorio6: 0-5 usando syscall 42 de MARS
aleatorio6:
    li   $a0, 0
    li   $a1, 6
    li   $v0, 42
    syscall
    move $v0, $a0
    jr   $ra


# simularPartidos
simularPartidos:
    addiu $sp, $sp, -24
    sw    $ra,  20($sp)
    sw    $s0,  16($sp)
    sw    $s1,  12($sp)
    sw    $s2,   8($sp)
    sw    $s3,   4($sp)
    sw    $s4,   0($sp)

    la   $a0, msgPartidos
    li   $v0, 4
    syscall

    li   $s0, 0
partLoop:
    bge  $s0, 6, partFin

    la   $t0, pardA
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $s1, 0($t0)
    la   $t0, pardB
    add  $t0, $t0, $t1
    lw   $s2, 0($t0)

    jal  aleatorio6
    move $s3, $v0
    jal  aleatorio6
    move $s4, $v0

    jal  imprimirNombreGrupo_s1
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
    jal  imprimirNombreGrupo_s2
    la   $a0, msgSalto
    li   $v0, 4
    syscall

    # GF/GC equipo A
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

    # GF/GC equipo B
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

    # Puntos FIFA
    beq  $s3, $s4, esEmpate
    bgt  $s3, $s4, ganaA
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


# Auxiliares de impresion de nombres
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


# mostrarTabla
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
    addiu $a0, $s0, 1
    li   $v0, 1
    syscall
    la   $a0, msgPuntoEsp
    li   $v0, 4
    syscall
    move $a0, $s0
    jal  imprimirNombrePorIdx
    la   $a0, msgEsp3
    li   $v0, 4
    syscall
    la   $t0, GF
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall
    la   $a0, msgEsp3
    li   $v0, 4
    syscall
    la   $t0, GC
    sll  $t1, $s0, 2
    add  $t0, $t0, $t1
    lw   $a0, 0($t0)
    li   $v0, 1
    syscall
    la   $a0, msgEsp3
    li   $v0, 4
    syscall
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


# ordenarTabla: Bubble Sort descendente por Pts y DG
ordenarTabla:
    addiu $sp, $sp, -16
    sw    $ra, 12($sp)
    sw    $s0,  8($sp)
    sw    $s1,  4($sp)
    sw    $s2,  0($sp)

    li   $s0, 0
outerLoop:
    bge  $s0, 3, outerFin
    li   $s1, 0
    li   $t9, 3
    sub  $s2, $t9, $s0
innerLoop:
    bge  $s1, $s2, innerFin
    la   $t0, Pts
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    addiu $t3, $s1, 1
    sll  $t3, $t3, 2
    la   $t0, Pts
    add  $t0, $t0, $t3
    lw   $t4, 0($t0)
    blt  $t2, $t4, hacerSwap
    bgt  $t2, $t4, noSwap
    # desempate por DG
    la   $t0, GF
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t5, 0($t0)
    la   $t0, GC
    add  $t0, $t0, $t1
    lw   $t6, 0($t0)
    sub  $t5, $t5, $t6
    addiu $t1, $s1, 1
    sll  $t1, $t1, 2
    la   $t0, GF
    add  $t0, $t0, $t1
    lw   $t7, 0($t0)
    la   $t0, GC
    add  $t0, $t0, $t1
    lw   $t8, 0($t0)
    sub  $t7, $t7, $t8
    blt  $t5, $t7, hacerSwap
    j    noSwap
hacerSwap:
    # swap Pts
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
    # swap GF
    la   $t0, GF
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t4, GF
    add  $t4, $t4, $t3
    lw   $t5, 0($t4)
    sw   $t5, 0($t0)
    sw   $t2, 0($t4)
    # swap GC
    la   $t0, GC
    sll  $t1, $s1, 2
    add  $t0, $t0, $t1
    lw   $t2, 0($t0)
    la   $t4, GC
    add  $t4, $t4, $t3
    lw   $t5, 0($t4)
    sw   $t5, 0($t0)
    sw   $t2, 0($t4)
    # swap grupoIdx
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


# mostrarClasificados
mostrarClasificados:
    addiu $sp, $sp, -4
    sw    $ra, 0($sp)

    la   $a0, msgClasif
    li   $v0, 4
    syscall

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
    la   $a0, msgPtos
    li   $v0, 4
    syscall

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
    la   $a0, msgPtos
    li   $v0, 4
    syscall

    lw   $ra, 0($sp)
    addiu $sp, $sp, 4
    jr   $ra
