.text
.globl main

main:
    # ===== INITIALISATION DE LA SCÈNE =====
    # Effacer l'écran (fond noir)
    jal effacer_ecran
    
    # Dessiner le joueur (vaisseau spatial)
    # Position: (14,28), Taille: 4x2 pixels, Couleur: vert
    li a0, 14          # a0 = position X (14/32)
    li a1, 28          # a1 = position Y (28/32) - près du bas
    li a2, 4           # a2 = largeur (4 pixels)
    li a3, 2           # a3 = hauteur (2 pixels)  
    li a4, 0x0000ff00  # a4 = couleur (vert)
    jal dessiner_rectangle
    
    # Dessiner les 24 envahisseurs en formation
    jal dessiner_envahisseurs
    
    # Dessiner les 4 obstacles (barrières de protection)
    jal dessiner_obstacles
    
    # Attendre 15 secondes pour observation
    li a0, 100       # 15000 ms = 15 secondes
    li a7, 32          # Appel système sleep
    ecall
    
    # Terminer le programme
    li a7, 10
    ecall

# =================================================================
# FONCTION EFFACER ÉCRAN
# Remplit toute la mémoire vidéo avec la couleur noire
# =================================================================
effacer_ecran:
    li t0, 0x10010000  # t0 = adresse de base mémoire vidéo
    li t1, 0x00000000  # t1 = couleur noire
    li t2, 1024        # t2 = nombre total pixels (32×32 = 1024)
    li t3, 0           # t3 = compteur de pixels
    
boucle_eff:
    bge t3, t2, fin_eff  # Si tous pixels traités → fin
    slli t4, t3, 2       # t4 = offset (index × 4 bytes)
    add t5, t0, t4       # t5 = adresse pixel (base + offset)
    sw t1, 0(t5)         # Écrire noir à l'adresse
    addi t3, t3, 1       # Pixel suivant
    j boucle_eff
    
fin_eff:
    jr ra

# =================================================================
# FONCTION DESSINER PIXEL
# Dessine un pixel unique aux coordonnées (x,y)
# Entrées: a0=x, a1=y, a2=couleur
# =================================================================
dessiner_pixel:
    # Vérification des limites de l'écran (0-31)
    blt a0, zero, skip_pix   # Si x < 0 → ignorer
    blt a1, zero, skip_pix   # Si y < 0 → ignorer
    li t0, 32
    bge a0, t0, skip_pix     # Si x ≥ 32 → ignorer
    bge a1, t0, skip_pix     # Si y ≥ 32 → ignorer
    
    # Calcul de l'adresse mémoire du pixel:
    # Formule: adresse = base + ((y × 32 + x) × 4)
    slli t1, a1, 5           # t1 = y × 32 (car 32 pixels par ligne)
    add t1, t1, a0           # t1 = (y×32) + x (index linéaire)
    li t2, 0x10010000        # t2 = adresse base mémoire vidéo
    slli t3, t1, 2           # t3 = index × 4 (car 4 bytes par pixel)
    add t2, t2, t3           # t2 = adresse finale
    sw a2, 0(t2)             # Écrire la couleur en mémoire
    
skip_pix:
    jr ra

# =================================================================
# FONCTION DESSINER RECTANGLE
# Dessine un rectangle plein
# Entrées: a0=x, a1=y, a2=largeur, a3=hauteur, a4=couleur
# =================================================================
dessiner_rectangle:
    addi sp, sp, -28      # Réserver espace pile pour 7 registres
    sw ra, 24(sp)         # Sauvegarder adresse retour
    sw s0, 20(sp)         # s0 = position x
    sw s1, 16(sp)         # s1 = position y
    sw s2, 12(sp)         # s2 = largeur
    sw s3, 8(sp)          # s3 = hauteur
    sw s4, 4(sp)          # s4 = couleur
    sw s5, 0(sp)          # s5 = compteur de lignes
    
    # Sauvegarde des paramètres dans des registres conservés
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    li s5, 0               # Initialiser compteur lignes (i=0)
    
boucle_lig:
    bge s5, s3, fin_rect   # Si i ≥ hauteur → fin rectangle
    li t0, 0               # t0 = compteur colonnes (j=0)
    
boucle_col:
    bge t0, s2, lig_suiv   # Si j ≥ largeur → ligne suivante
    
    # Calcul coordonnées du pixel à dessiner
    add a0, s0, t0         # a0 = x + j (position x du pixel)
    add a1, s1, s5         # a1 = y + i (position y du pixel)
    mv a2, s4              # a2 = couleur
    
    jal dessiner_pixel     # Dessiner le pixel
    
    addi t0, t0, 1         # Colonne suivante
    j boucle_col

lig_suiv:
    addi s5, s5, 1         # Ligne suivante
    j boucle_lig

fin_rect:
    # Restauration des registres sauvegardés
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
# FONCTION DESSINER ENVAHISSEURS
# Dessine 24 envahisseurs en formation (3 lignes × 8 colonnes)
# Positionnement: 
# - Ligne 0: y=2, Ligne 1: y=5, Ligne 2: y=8
# - Colonnes: x=1,5,9,13,17,21,25,29
# =================================================================
dessiner_envahisseurs:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)          # s0 = compteur envahisseurs (0-23)
    sw s1, 4(sp)          # s1 = nombre total envahisseurs (24)
    sw s2, 0(sp)          # s2 = numéro de ligne
    
    li s0, 0              # Initialiser compteur
    li s1, 11             # Nombre total d'envahisseurs
    
boucle_env:
    bge s0, s1, fin_env   # Si compteur ≥ 24 → fin
    
    # Calcul de la position de l'envahisseur [s0]:
    # - Ligne = s0 / 8 (0,1,2)
    # - Colonne = s0 % 8 (0-7)
    li t0, 8
    div s2, s0, t0        # s2 = ligne (0,1,2)
    rem t1, s0, t0        # t1 = colonne (0-7)
    
    # Calcul position X: (colonne × 4) + 1
    # → Espacement: 4 pixels entre envahisseurs
    slli t2, t1, 2        # t2 = colonne × 4
    addi a0, t2, 1        # a0 = x = (colonne×4) + 1
    
    # Calcul position Y: (ligne × 3) + 2  
    # → Espacement: 3 pixels entre lignes
    li t3, 3
    mul t4, s2, t3        # t4 = ligne × 3
    addi a1, t4, 2        # a1 = y = (ligne×3) + 2  (2 pixel en haut de la page) 
    
    # Paramètres de dessin
    li a2, 3              # Largeur envahisseur
    li a3, 2              # Hauteur envahisseur
    li a4, 0x00ff0000     # Couleur rouge
    
    jal dessiner_rectangle
    
    addi s0, s0, 1        # Envahisseur suivant
    j boucle_env

fin_env:
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

# =================================================================
# FONCTION DESSINER OBSTACLES  
# Dessine 4 obstacles (barrières de protection)
# Positionnement: x=5,11,17,23 (espacement régulier)
# =================================================================
dessiner_obstacles:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)          # s0 = compteur obstacles (0-3)
    
    li s0, 0              # Initialiser compteur
    
boucle_obs:
    li t0, 4
    bge s0, t0, fin_obs   # Si 4 obstacles dessinés → fin
    
    # Calcul position X: (index × 6) + 5
    # → Espacement: 6 pixels entre obstacles
    li t1, 6
    mul t2, s0, t1        # t2 = index × 6
    addi a0, t2, 5         # a0 = x = (index×6) + 5
    
    # Position Y fixe près du bas
    li a1, 22             # a1 = y = 22/32
    
    # Paramètres de dessin
    li a2, 4              # Largeur obstacle
    li a3, 3              # Hauteur obstacle  
    li a4, 0x0000ffff     # Couleur cyan
    
    jal dessiner_rectangle
    
    addi s0, s0, 1        # Obstacle suivant
    j boucle_obs

fin_obs:
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8
    jr ra
