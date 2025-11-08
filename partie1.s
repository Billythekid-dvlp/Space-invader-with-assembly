# Partie 1 : La pause
# Affiche les entiers de 1 a 10, un toutes les 500 ms

.data
    newline: .asciiz "\n"

.text
.globl main

main:
    li t0, 1          # t0 = compteur, commence a 1
    li t1, 11         # t1 = limite (on va jusqu'� 10)

boucle:
    bge t0, t1, fin   # si t0 >= 11, on arr�te

    # Afficher t0
    mv a0, t0         # a0 = valeur a afficher
    li a7, 1          # appel syst�me "print integer"
    ecall

    # Afficher un retour � la ligne
    la a0, newline
    li a7, 4          # appel syst�me "print string"
    ecall

    # Attendre 500 ms
    li a0, 500        # a0 = dur�e en ms
    li a7, 32         # appel syst�me "sleep"
    ecall

    addi t0, t0, 1    # t0++
    j boucle

fin:
    li a7, 10         # appel syst�me "exit"
    ecall