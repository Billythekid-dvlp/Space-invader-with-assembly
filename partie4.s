.data
    msg_ok: .string "\n[OK] Scene Space Invaders affichee!\n\n"

.text
.globl main

main:
    # Effacer l'écran
    jal effacer_ecran
    
    # Dessiner le joueur (14, 28, 4x2, vert)
    li a0, 14
    li a1, 28
    li a2, 4
    li a3, 2
    li a4, 0x0000ff00
    jal dessiner_rectangle
    
    # Dessiner les 24 envahisseurs
    jal dessiner_envahisseurs
    
    # Dessiner les 4 obstacles
    jal dessiner_obstacles
    
    # Message de succès
    li a7, 4
    la a0, msg_ok
    ecall
    
    # Attendre 15 secondes
    li a0, 15000
    li a7, 32
    ecall
    
    # Terminer
    li a7, 10
    ecall

# =================================================================
# EFFACER ÉCRAN
# =================================================================
effacer_ecran:
    li t0, 0x10010000
    li t1, 0x00000000
    li t2, 1024
    li t3, 0
    
boucle_eff:
    bge t3, t2, fin_eff
    slli t4, t3, 2
    add t5, t0, t4
    sw t1, 0(t5)
    addi t3, t3, 1
    j boucle_eff
    
fin_eff:
    jr ra

# =================================================================
# DESSINER PIXEL
# =================================================================
dessiner_pixel:
    blt a0, zero, skip_pix
    blt a1, zero, skip_pix
    li t0, 32
    bge a0, t0, skip_pix
    bge a1, t0, skip_pix
    
    slli t1, a1, 5
    add t1, t1, a0
    li t2, 0x10010000
    slli t3, t1, 2
    add t2, t2, t3
    sw a2, 0(t2)
    
skip_pix:
    jr ra

# =================================================================
# DESSINER RECTANGLE
# =================================================================
dessiner_rectangle:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)
    sw s1, 16(sp)
    sw s2, 12(sp)
    sw s3, 8(sp)
    sw s4, 4(sp)
    sw s5, 0(sp)
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    li s5, 0
    
boucle_lig:
    bge s5, s3, fin_rect
    li t0, 0
    
boucle_col:
    bge t0, s2, lig_suiv
    add a0, s0, t0
    add a1, s1, s5
    mv a2, s4
    jal dessiner_pixel
    addi t0, t0, 1
    j boucle_col

lig_suiv:
    addi s5, s5, 1
    j boucle_lig

fin_rect:
    lw s5, 0(sp)
    lw s4, 4(sp)
    lw s3, 8(sp)
    lw s2, 12(sp)
    lw s1, 16(sp)
    lw s0, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
    jr ra

# =================================================================
# DESSINER ENVAHISSEURS (24 total, 3 lignes x 8 colonnes)
# =================================================================
dessiner_envahisseurs:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    li s0, 0
    li s1, 24
    
boucle_env:
    bge s0, s1, fin_env
    li t0, 8
    div s2, s0, t0
    rem t1, s0, t0
    slli t2, t1, 2
    addi a0, t2, 1
    li t3, 3
    mul t4, s2, t3
    addi a1, t4, 2
    li a2, 3
    li a3, 2
    li a4, 0x00ff0000
    jal dessiner_rectangle
    addi s0, s0, 1
    j boucle_env

fin_env:
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

# =================================================================
# DESSINER OBSTACLES (4 obstacles)
# =================================================================
dessiner_obstacles:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)
    
    li s0, 0
    
boucle_obs:
    li t0, 4
    bge s0, t0, fin_obs
    li t1, 6
    mul t2, s0, t1
    addi a0, t2, 5
    li a1, 22
    li a2, 4
    li a3, 3
    li a4, 0x0000ffff
    jal dessiner_rectangle
    addi s0, s0, 1
    j boucle_obs

fin_obs:
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    jr ra