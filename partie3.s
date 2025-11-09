# ===================================================================
# VERSION FINALE - Problème de saut résolu
# ===================================================================

.data
    IMG_WIDTH:   .word 256
    IMG_HEIGHT:  .word 256
    UNIT_WIDTH:  .word 8
    UNIT_HEIGHT: .word 8

    noir:         .word 0x00000000
    rouge:        .word 0x00ff0000
    vert:         .word 0x0000ff00
    bleu:         .word 0x000000ff

    .align 2
    display_buffer: .space 4096

.text
.globl main

main:
    # Test simple sans animation complexe
    jal test_simple_horizontal
    li a7, 10
    ecall

# --- Fonction I_xy_to_addr ---
I_xy_to_addr:
    # Vérification des limites
    li t0, 32
    bge a0, t0, addr_erreur
    bge a1, t0, addr_erreur
    blt a0, zero, addr_erreur
    blt a1, zero, addr_erreur
    
    # Calcul direct
    slli t1, a1, 5    # y * 32
    add t1, t1, a0    # + x
    slli t1, t1, 2    # * 4
    la t0, display_buffer
    add a0, t0, t1
    ret
    
addr_erreur:
    li a0, 0
    ret

# --- Fonction I_plot ---  
I_plot:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    jal I_xy_to_addr
    beqz a0, plot_fin
    sw a2, 0(a0)
    
plot_fin:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# --- Fonction I_effacer ---
I_effacer:
    la t0, display_buffer
    lw t1, noir
    li t2, 0
effacer_loop:
    li t3, 1024
    beq t2, t3, effacer_fin
    sw t1, 0(t0)
    addi t0, t0, 4
    addi t2, t2, 1
    j effacer_loop
effacer_fin:
    ret

# --- FONCTION RECTANGLE COMPLÈTEMENT RÉÉCRITE ---
I_rectangle:
    # Sauvegarde de TOUS les registres utilisés
    addi sp, sp, -36
    sw ra, 32(sp)
    sw s0, 28(sp)    # x
    sw s1, 24(sp)    # y
    sw s2, 20(sp)    # largeur  
    sw s3, 16(sp)    # hauteur
    sw s4, 12(sp)    # couleur
    sw s5, 8(sp)     # i
    sw s6, 4(sp)     # j
    sw s7, 0(sp)     # temp

    mv s0, a0  # x
    mv s1, a1  # y
    mv s2, a2  # largeur
    mv s3, a3  # hauteur
    mv s4, a4  # couleur

    li s5, 0   # i = 0

rect_y_loop:
    bge s5, s3, rect_fin
    
    li s6, 0   # j = 0
rect_x_loop:
    bge s6, s2, rect_y_next

    # Calcul position
    add a0, s0, s6
    add a1, s1, s5
    
    # Vérification stricte des limites
    li s7, 32
    bge a0, s7, rect_x_next
    bge a1, s7, rect_x_next
    blt a0, zero, rect_x_next
    blt a1, zero, rect_x_next
    
    # Appel I_plot avec préservation des registres
    mv a2, s4
    addi sp, sp, -16
    sw s5, 12(sp)
    sw s6, 8(sp) 
    sw s7, 4(sp)
    sw ra, 0(sp)
    
    jal I_plot
    
    lw ra, 0(sp)
    lw s7, 4(sp)
    lw s6, 8(sp)
    lw s5, 12(sp)
    addi sp, sp, 16

rect_x_next:
    addi s6, s6, 1
    j rect_x_loop

rect_y_next:
    addi s5, s5, 1
    j rect_y_loop

rect_fin:
    # Restauration dans l'ordre inverse
    lw s7, 0(sp)
    lw s6, 4(sp)
    lw s5, 8(sp)
    lw s4, 12(sp)
    lw s3, 16(sp)
    lw s2, 20(sp)
    lw s1, 24(sp)
    lw s0, 28(sp)
    lw ra, 32(sp)
    addi sp, sp, 36
    ret

# --- TEST SIMPLE SANS BUG ---
test_simple_horizontal:
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)  # x
    sw s1, 0(sp)  # y (TOUJOURS 10)

    li s0, 0      # x start
    li s1, 10     # y fixed

animation_loop:
    # Étape 1: Effacer
    jal I_effacer
    
    # Étape 2: Dessiner point de référence (vert) à (0,10)
    li a0, 0
    li a1, 10
    lw a2, vert
    jal I_plot
    
    # Étape 3: Dessiner rectangle (rouge) à (s0,10)
    mv a0, s0
    mv a1, s1
    li a2, 5
    li a3, 5
    lw a4, rouge
    jal I_rectangle
    
    # Étape 4: Pause
    li a0, 200
    li a7, 32
    ecall
    
    # Étape 5: Déplacer x seulement
    addi s0, s0, 1
    
    # Étape 6: Vérifier limites
    li t0, 27
    ble s0, t0, animation_loop
    
    # Reset x seulement, y reste à 10
    li s0, 0
    j animation_loop

    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    ret
