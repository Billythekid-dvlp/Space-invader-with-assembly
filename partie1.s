.text
.globl main

main:
    li t0, 1                # t0 = compteur, commence à 1
    li t1, 11               # t1 = limite (on s'arrête à 10)

boucle:
    bge t0, t1, fin         # si t0 >= 11, on arrête

    # Afficher t0 (valeur entière)
    mv a0, t0
    li a7, 1                # print integer
    ecall

    # Afficher un saut de ligne
    li a0, 10               # code ASCII de \n
    li a7, 11               # print character
    ecall

    # Attendre 500 ms
    li a0, 500
    li a7, 32               # sleep
    ecall

    addi t0, t0, 1          # t0++
    j boucle

fin:
    li a7, 10               # exit
    ecall