.data

.text
.globl main

main:
    # Adresse de base
    li t0, 0x10010000
    
    # Avec Units 8×8 sur image 256×256 :
    # - Largeur en Units : 256/8 = 32
    # - Hauteur en Units : 256/8 = 32
    # - Moitié supérieure : 16 lignes × 32 Units/ligne = 512 Units
    
    li t1, 512       # Nombre d'Units à colorier
    li t2, 0x00FF0000 # Rouge

boucle:
    beqz t1, fin
    
    # Colorier une Unit
    sw t2, 0(t0)
    
    # Prochaine Unit
    addi t0, t0, 4
    addi t1, t1, -1
    
    j boucle

fin:
    li a7, 10
    ecall