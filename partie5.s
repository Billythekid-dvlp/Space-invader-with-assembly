.data
    J_old_x: .word 14   # ancienne position X
    J_old_y: .word 28   # ancienne position Y
    KEYBOARD_CTRL: .word 0xffff0000
    KEYBOARD_DATA: .word 0xffff0004
    KEY_I:   .word 105
    KEY_P:   .word 112
    KEY_O:   .word 111
    KEY_ESC: .word 27
    game_running: .word 1
    frame_delay:  .word 100
    # Données pour les missiles
    missile_count: .word 0
    missile_x: .space 20   # 5 missiles max
    missile_y: .space 20
    missile_dir: .space 20 # 1=haut, -1=bas
    
    # Données pour les envahisseurs  
    invader_dir: .word 1   # 1=droite, -1=gauche
    invader_speed: .word 1

.text
.globl main

main:

 # DEBUG: Message de début
    li a7, 4
    la a0, debug_start
    ecall
    
    li s1, 14   # pos_x
    li s2, 28   # pos_y
    
    # DEBUG: Après init positions
    li a7, 4
    la a0, debug_after_init
    ecall
    
    jal effacer_ecran
    # DEBUG: Après effacer_ecran
    li a7, 4
    la a0, debug_after_clear
    ecall
    
    jal dessiner_scene_complete
    # DEBUG: Après dessin
    li a7, 4
    la a0, debug_after_draw
    ecall
    
    j boucle_jeu
    # Initialisation des positions dans les registres
    li s1, 14   # pos_x
    li s2, 28   # pos_y
    
    li a7, 4
    la a0, msg_debut
    ecall
    
    jal effacer_ecran
    jal dessiner_scene_complete
    
    li a7, 4
    la a0, msg_pret
    ecall

boucle_jeu:
    lw t0, game_running
    beqz t0, fin_jeu
    
    # SAUVEGARDER l'ancienne position AVANT de la changer
    la t1, J_old_x
    sw s1, 0(t1)
    la t1, J_old_y  
    sw s2, 0(t1)
    
    jal gerer_clavier    # Met à jour s1 et s2
    
    # EFFACER l'ANCIENNE position
    la t1, J_old_x
    lw a0, 0(t1)
    la t1, J_old_y
    lw a1, 0(t1)
    li a2, 4
    li a3, 2
    li a4, 0x00000000  # Noir
    jal dessiner_rectangle
    
    # DESSINER la NOUVELLE position
    mv a0, s1   # nouvelle position X
    mv a1, s2   # nouvelle position Y
    li a2, 4
    li a3, 2
    li a4, 0x0000ff00  # Vert
    jal dessiner_rectangle
    
    lw a0, frame_delay
    li a7, 32
    ecall
    j boucle_jeu

fin_jeu:
    li a7, 4
    la a0, msg_fin
    ecall
    li a7, 10
    ecall
    
    
gerer_tirs:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    # Vérifier si espace est pressé pour créer un missile
    # (À implémenter)
    
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

M_deplacer:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    # Pour chaque missile: y = y + direction
    # (À implémenter)
    
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

E_deplacer:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    
    # Déplacer tous les envahisseurs
    # Si bord atteint: changer direction et descendre
    # (À implémenter)
    
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra


dessiner_scene_complete:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    # s1 et s2 ne sont pas sauvegardés car ce sont nos variables!
    
    # Utiliser s1 et s2 directement
    mv a0, s1   # pos_x
    mv a1, s2   # pos_y
    li a2, 4
    li a3, 2
    li a4, 0x0000ff00
    jal dessiner_rectangle
    
    # ... reste du code pour envahisseurs et obstacles
    li s0, 0
boucle_env:
    li t0, 24
    bge s0, t0, fin_env
    li t0, 8
    div t1, s0, t0
    rem t2, s0, t0
    slli t3, t2, 2
    addi a0, t3, 1
    li t4, 3
    mul t5, t1, t4
    addi a1, t5, 2
    li a2, 3
    li a3, 2
    li a4, 0x00ff0000
    jal dessiner_rectangle
    addi s0, s0, 1
    j boucle_env
fin_env:
    
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
    
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

gerer_clavier:
    lw t1, 0xffff0000
    beqz t1, fin_clavier
    
    lw t2, 0xffff0004
    
    li t3, 27
    beq t2, t3, quitter
    
    li t3, 105
    beq t2, t3, gauche
    
    li t3, 112
    beq t2, t3, droite
    
    j fin_clavier

quitter:
    la t0, game_running    # ✅ Charger l'adresse
    sw zero, 0(t0)         # ✅ Stocker 0
    j fin_clavier

gauche:
    blez s1, fin_clavier
    addi s1, s1, -1
    j fin_clavier

droite:
    li t0, 31
    bge s1, t0, fin_clavier
    addi s1, s1, 1
    j fin_clavier

fin_clavier:
    jr ra

effacer_ecran:
    li t0, 0x10004000
    li t1, 0x00FF0000
    li t2, 1024
    li t3, 0
    
boucle_effacer:
    bge t3, t2, fin_effacer
    
    # DEBUG: Afficher quelques pixels
    li t5, 100
    beq t3, t5, debug_pixel
    li t5, 200  
    beq t3, t5, debug_pixel
    j pas_debug
    
debug_pixel:
    mv a0, t3
    li a7, 1
    ecall
    li a7, 11
    li a0, ' '
    ecall
    
pas_debug:
    slli t4, t3, 2
    add t5, t0, t4
    sw t1, 0(t5)
    addi t3, t3, 1
    j boucle_effacer
    
fin_effacer:
    jr ra

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
    
boucle_ligne:
    bge s5, s3, fin_rect
    li t0, 0
    
boucle_colonne:
    bge t0, s2, ligne_suivante
    add a0, s0, t0
    add a1, s1, s5
    mv a2, s4
    jal dessiner_pixel
    addi t0, t0, 1
    j boucle_colonne
ligne_suivante:
    addi s5, s5, 1
    j boucle_ligne

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

dessiner_pixel:
    blt a0, zero, skip_pixel
    blt a1, zero, skip_pixel
    li t0, 32
    bge a0, t0, skip_pixel
    bge a1, t0, skip_pixel
    slli t1, a1, 5
    add t1, t1, a0
    li t2, 0x10010000
    slli t3, t1, 2
    add t2, t2, t3
    sw a2, 0(t2)
skip_pixel:
    jr ra

.data
msg_debut: .string "=== SPACE INVADERS ===\n"
msg_pret:  .string "i=Gauche, p=Droite, ESC=Quitter\n"
msg_fin:   .string "Jeu termine.\n"


.data
debug_start: .string "DEBUT main\n"
debug_after_init: .string "Apres init positions\n"
debug_after_clear: .string "Apres effacer_ecran\n"
debug_after_draw: .string "Apres dessin scene\n"