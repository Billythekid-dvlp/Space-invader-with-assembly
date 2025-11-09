# Partie 2 : Entrée synchrone au clavier
# Affiche la valeur de t0 toutes les 500 ms
# 'i' ? t0--
# 'p' ? t0++
# 'o' ? arrêter le programme
# Autres touches ? ignorées

.text
.globl main

main:
    li t0, 0                # t0 = valeur à modifier

boucle_principale:
    # Afficher la valeur de t0
    mv a0, t0
    li a7, 1                # print integer
    ecall


    # Lire le registre RCR (0xffff0000)
    lw t1, 0xffff0000       # t1 = valeur de RCR

    # Si RCR == 0, pas de touche appuyée ? on va à la pause
    beq t1, zero, pause

    # Sinon, une touche a été appuyée ? lire RDR (0xffff0004)
    lw t2, 0xffff0004       # t2 = code ASCII de la touche (RCR passe automatiquement à 0)

    # Comparer avec 'i' (ASCII = 105)
    li t3, 105
    beq t2, t3, touche_i

    # Comparer avec 'p' (ASCII = 112)
    li t3, 112
    beq t2, t3, touche_p

    # Comparer avec 'o' (ASCII = 111)
    li t3, 111
    beq t2, t3, quitter

    # Si ce n’est pas i/p/o ? on ignore la touche et on va à la pause
    j pause

touche_i:
    addi t0, t0, -1         # t0--
    j pause

touche_p:
    addi t0, t0, 1          # t0++
    j pause

quitter:
    li a7, 10               # exit
    ecall

pause:
    # Attendre 500 ms
    li a0, 500
    li a7, 32               # sleep
    ecall

    # Retourner à la boucle principale
    j boucle_principale