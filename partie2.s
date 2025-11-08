# Partie 2 : Entr�e synchrone au clavier
# Affiche t0 toutes les 500 ms
# 'i' ? t0--
# 'p' ? t0++
# 'o' ? quitte
# Autres touches ? ignor�es

.data
    newline: .asciiz "\n"
    rcr_addr: .word 0xffff0000   # Adresse du RCR
    rdr_addr: .word 0xffff0004   # Adresse du RDR

.text
.globl main

main:
    li t0, 0          # t0 = valeur � modifier

boucle_principale:
    # --- Affichage de t0 ---
    mv a0, t0
    li a7, 1
    ecall

    la a0, newline
    li a7, 4
    ecall

    # --- Lecture du clavier (si une touche est press�e) ---
    la t1, rcr_addr
    lw t2, 0(t1)      # t2 = valeur de RCR

    bne t2, zero, touche_appuyee   # Si RCR != 0 ? il y a une touche

    # Pas de touche ? on va � la pause
    j pause

touche_appuyee:
    la t1, rdr_addr
    lw t3, 0(t1)      # t3 = code ASCII de la touche (et RCR passe � 0)

    # Comparer avec 'i' (ASCII 105)
    li t4, 105
    beq t3, t4, touche_i

    # Comparer avec 'p' (ASCII 112)
    li t4, 112
    beq t3, t4, touche_p

    # Comparer avec 'o' (ASCII 111)
    li t4, 111
    beq t3, t4, quitter

    # Si ce n'est pas i/p/o ? on ignore
    j pause

touche_i:
    addi t0, t0, -1
    j pause

touche_p:
    addi t0, t0, 1
    j pause

quitter:
    li a7, 10
    ecall

pause:
    li a0, 500        # 500 ms
    li a7, 32         # sleep
    ecall

    j boucle_principale
