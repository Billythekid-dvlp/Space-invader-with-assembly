.data
    # Couleurs
    noir:    .word 0x00000000
    rouge:   .word 0x00ff0000

.text
.globl main

main:
    # =============================================
    # ÉTAPE 1: Dessiner un grand rectangle rouge
    # qui occupe la moitié supérieure de l'écran
    # =============================================
    li a0, 0      # x = 0 (coin haut-gauche)
    li a1, 0      # y = 0 (coin haut-gauche)  
    li a2, 32     # largeur = 32 (pleine largeur écran)
    li a3, 16     # hauteur = 16 (moitié de la hauteur 32)
    lw a4, rouge  # couleur rouge
    jal rectangle # Appel de la fonction rectangle
    
    # =============================================
    # FIN DU PROGRAMME - Le rectangle reste affiché
    # =============================================
    li a7, 10      # Appel système pour quitter
    ecall

# =============================================
# FONCTION: effacer_ecran
# Remet tout l'écran en noir
# =============================================
effacer_ecran:
    li t0, 0x10010000  # Adresse de base du display bitmap
    lw t1, noir        # Charger la couleur noire
    li t2, 0           # Initialiser le compteur à 0
    li t3, 1024        # Nombre total de pixels (32x32 = 1024)
    
boucle_effacer:
    beq t2, t3, fin_effacer  # Si compteur = 1024, fin de la boucle
    slli t4, t2, 2           # Multiplier l'index par 4 (car 4 bytes par pixel)
    add t5, t0, t4           # Calculer l'adresse du pixel
    sw t1, 0(t5)             # Écrire la couleur noire à cette adresse
    addi t2, t2, 1           # Incrémenter le compteur
    j boucle_effacer          # Recommencer la boucle
    
fin_effacer:
    jr ra                    # Retour à l'appelant

# =============================================
# FONCTION: xy_vers_adresse
# Convertit des coordonnées (x,y) en adresse mémoire
# Entrée: a0 = x (0-31), a1 = y (0-31)
# Sortie: a0 = adresse mémoire ou 0 si hors limites
# =============================================
xy_vers_adresse:
    # Vérification que x et y sont dans les limites [0, 31]
    blt a0, zero, erreur_adresse  # Si x < 0, erreur
    blt a1, zero, erreur_adresse  # Si y < 0, erreur
    li t0, 32
    bge a0, t0, erreur_adresse    # Si x >= 32, erreur
    bge a1, t0, erreur_adresse    # Si y >= 32, erreur
    
    # Calcul de l'index: index = y * 32 + x
    li t1, 32
    mul t2, a1, t1      # y * 32
    add t2, t2, a0      # + x
    
    # Calcul de l'adresse: adresse = 0x10010000 + index * 4
    slli t2, t2, 2      # Multiplier l'index par 4 (taille d'un pixel)
    li t3, 0x10010000   # Adresse de base du display
    add a0, t3, t2      # Adresse finale du pixel
    
    jr ra               # Retourner l'adresse

erreur_adresse:
    li a0, 0            # Retourner 0 en cas d'erreur
    jr ra

# =============================================
# FONCTION: plot_pixel
# Dessine un pixel à la position (x,y)
# Entrée: a0 = x, a1 = y, a2 = couleur
# =============================================
plot_pixel:
    addi sp, sp, -12     # Sauvegarder les registres sur la pile
    sw ra, 8(sp)         # Sauvegarder l'adresse de retour
    sw a0, 4(sp)         # Sauvegarder x
    sw a1, 0(sp)         # Sauvegarder y
    
    jal xy_vers_adresse  # Convertir (x,y) en adresse
    beqz a0, fin_plot    # Si adresse = 0 (hors limites), ignorer
    
    sw a2, 0(a0)         # Écrire la couleur à l'adresse calculée
    
fin_plot:
    # Restaurer les registres depuis la pile
    lw a1, 0(sp)
    lw a0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra

# =============================================
# FONCTION: rectangle
# Dessine un rectangle plein
# Entrée: a0 = x, a1 = y, a2 = largeur, a3 = hauteur, a4 = couleur
# =============================================
rectangle:
    addi sp, sp, -28     # Sauvegarder les registres sur la pile
    sw ra, 24(sp)        # Adresse de retour
    sw s0, 20(sp)        # x de départ
    sw s1, 16(sp)        # y de départ
    sw s2, 12(sp)        # largeur
    sw s3, 8(sp)         # hauteur
    sw s4, 4(sp)         # couleur
    sw s5, 0(sp)         # compteur pour les lignes (y)
    
    # Sauvegarder les paramètres dans les registres s
    mv s0, a0    # x
    mv s1, a1    # y
    mv s2, a2    # largeur
    mv s3, a3    # hauteur
    mv s4, a4    # couleur
    
    li s5, 0     # Initialiser le compteur de lignes à 0

boucle_y:
    bge s5, s3, fin_rectangle  # Si on a traité toutes les lignes, fin
    li t0, 0                   # Initialiser le compteur de colonnes à 0

boucle_x:
    bge t0, s2, suivant_y      # Si on a traité toutes les colonnes, ligne suivante
    
    # Calculer la position du pixel actuel
    add a0, s0, t0             # x_pixel = x_départ + colonne_actuelle
    add a1, s1, s5             # y_pixel = y_départ + ligne_actuelle
    mv a2, s4                  # couleur du rectangle
    
    # Sauvegarder le compteur de colonnes temporairement
    addi sp, sp, -4
    sw t0, 0(sp)
    
    jal plot_pixel             # Dessiner le pixel
    
    # Restaurer le compteur de colonnes
    lw t0, 0(sp)
    addi sp, sp, 4
    
    addi t0, t0, 1             # Colonne suivante
    j boucle_x

suivant_y:
    addi s5, s5, 1             # Ligne suivante
    j boucle_y

fin_rectangle:
    # Restaurer tous les registres sauvegardés  (free les registres dans l'ordre inverse)
    lw s5, 0(sp)
    lw s4, 4(sp)
    lw s3, 8(sp)
    lw s2, 12(sp)
    lw s1, 16(sp)
    lw s0, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
    jr ra
