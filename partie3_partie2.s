.data
    # =============================================
    # CONFIGURATION DE L'AFFICHAGE
    # =============================================
    IMG_WIDTH:   .word 256     # Largeur totale de l'image en pixels
    IMG_HEIGHT:  .word 256     # Hauteur totale de l'image en pixels
    UNIT_WIDTH:  .word 8       # Largeur d'une unité graphique en pixels
    UNIT_HEIGHT: .word 8       # Hauteur d'une unité graphique en pixels

    # =============================================
    # VARIABLES GLOBALES CALCULÉES
    # =============================================
    I_largeur:   .word 0       # Largeur en nombre d'unités (calculée)
    I_hauteur:   .word 0       # Hauteur en nombre d'unités (calculée)
    I_buff:      .word 0       # Adresse du buffer de dessin
    I_visu:      .word 0       # Adresse du buffer d'affichage

    # =============================================
    # PALETTE DE COULEURS
    # =============================================
    noir:         .word 0x00000000   # Couleur noire
    rouge:        .word 0x00ff0000   # Couleur rouge
    bleu:         .word 0x000000ff   # Couleur bleue
    vert:         .word 0x0000ff00   # Couleur verte
    jaune:        .word 0x00ffff00   # Couleur jaune
    blanc:        .word 0x00ffffff   # Couleur blanche

    # =============================================
    # BUFFERS STATIQUES POUR BITMAP DISPLAY
    # =============================================
    display_buffer: .space 4096  # Buffer de dessin (32x32x4)
    visual_buffer:  .space 4096  # Buffer d'affichage (32x32x4)

.text
.globl main

main:
    # =============================================
    # INITIALISATION DU SYSTÈME GRAPHIQUE
    # =============================================
    jal I_creer              # Initialiser les buffers et variables (ligne 76)
    
    # =============================================
    # TEST SIMPLE : DESSINER UN RECTANGLE FIXE
    # =============================================
    jal I_effacer # on appel la fonction a la ligne 180
    
    # Dessiner un rectangle rouge fixe
    li a0, 0      # x = 5,   x = 0
    li a1, 10      # y = 5  y = 10
    li a2, 8     # largeur = 10   larg = 8
    li a3, 6      # hauteur = 8   haut = 6
    lw a4, rouge  # couleur rouge
    jal I_rectangle  # ligne 213
    
    # Transférer vers le buffer d'affichage
    jal I_buff_to_visu
    
    # Attendre pour voir le résultat
    li a0, 1000    # pause apres premiere affichage
    li a7, 32
    ecall
    
    # =============================================
    # DÉMONSTRATION ANIMATION
    # =============================================
    jal animation_rectangle_double_buffer
    
    li a7, 10                # Appel système pour quitter
    ecall

# =============================================
# FONCTION: I_creer
# Initialise les variables globales et buffers
# =============================================
I_creer:
    # =============================================
    # CALCUL DES DIMENSIONS EN UNITÉS
    # I_largeur = IMG_WIDTH / UNIT_WIDTH
    # I_hauteur = IMG_HEIGHT / UNIT_HEIGHT
    # =============================================
    lw t0, IMG_WIDTH
    lw t1, UNIT_WIDTH
    div t2, t0, t1
    sw t2, I_largeur, t3
    
    lw t0, IMG_HEIGHT
    lw t1, UNIT_HEIGHT
    div t2, t0, t1
    sw t2, I_hauteur, t3  #on prends l'adresse de I_hauteur, on la stock dans t3 et on passe par cette derniere pour mettre la valeur de t2 dans le label I_hauteur
    # =============================================
    # INITIALISATION DES ADRESSES DES BUFFERS
    # Utilisation de buffers statiques pour RARS
    # =============================================
    la t0, display_buffer
    sw t0, I_buff, t1
    
    la t0, visual_buffer
    sw t0, I_visu, t1
    
    jr ra  #retour a la ligne 46
# =============================================
# FONCTION: I_xy_to_addr
# Convertit coordonnées (x,y) en adresse mémoire
# Entrée: a0 = x, a1 = y
# Sortie: a0 = adresse mémoire (0 si hors limites)
# =============================================
I_xy_to_addr:
    # Vérification des limites
    lw t0, I_largeur
    lw t1, I_hauteur
    
    blt a0, zero, erreur_addr
    blt a1, zero, erreur_addr
    bge a0, t0, erreur_addr
    bge a1, t1, erreur_addr
    
    # Calcul: adresse = I_buff + (y * I_largeur + x) * 4
    lw t2, I_buff
    mul t3, a1, t0          # y * I_largeur
    add t3, t3, a0          # + x
    slli t3, t3, 2          # × 4 octets
    add a0, t2, t3          # + adresse base
    
    jr ra

erreur_addr:
    li a0, 0
    jr ra

# =============================================
# FONCTION: I_addr_to_xy
# Convertit adresse mémoire en coordonnées (x,y)
# Entrée: a0 = adresse mémoire
# Sortie: a0 = x, a1 = y
# =============================================
I_addr_to_xy:
    lw t0, I_buff
    lw t1, I_largeur
    
    # Calcul offset depuis l'adresse de base
    sub t2, a0, t0          # offset = adresse - I_buff
    srli t2, t2, 2          # offset / 4 (index linéaire)
    
    # Calcul y = index / I_largeur
    div a1, t2, t1          # y = index / I_largeur
    
    # Calcul x = index % I_largeur
    rem a0, t2, t1          # x = index % I_largeur
    
    jr ra

# =============================================
# FONCTION: I_plot
# Dessine un pixel à la position (x,y)
# Entrée: a0 = x, a1 = y, a2 = couleur
# =============================================
I_plot:
    addi sp, sp, -12
    sw ra, 8(sp)
    sw a0, 4(sp)
    sw a1, 0(sp)
    
    jal I_xy_to_addr        # Convertir (x,y) en adresse
    beqz a0, fin_plot       # Si hors limites, ignorer
    
    sw a2, 0(a0)           # Écrire la couleur
    
fin_plot:
    lw a1, 0(sp)
    lw a0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra

# =============================================
# FONCTION: I_effacer
# Remet tout le buffer en noir
# =============================================
I_effacer:
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)
    sw s1, 0(sp)
    
    lw s0, I_buff           # Adresse du buffer
    lw s1, noir             # Couleur noire
    lw t0, I_largeur
    lw t1, I_hauteur
    mul t2, t0, t1          # Nombre total de pixels
    li t3, 0                # Compteur
    
boucle_effacer:
    beq t3, t2, fin_effacer
    slli t4, t3, 2          # index × 4
    add t5, s0, t4          # adresse pixel
    sw s1, 0(t5)            # écrire noir
    addi t3, t3, 1
    j boucle_effacer
    
fin_effacer:
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra

# =============================================
# FONCTION: I_rectangle
# Dessine un rectangle plein
# Entrée: a0 = x, a1 = y, a2 = largeur, a3 = hauteur, a4 = couleur
# =============================================
I_rectangle:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)  # x
    sw s1, 16(sp)  # y
    sw s2, 12(sp)  # largeur
    sw s3, 8(sp)   # hauteur
    sw s4, 4(sp)   # couleur
    sw s5, 0(sp)   # compteur y
    
    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s4, a4
    li s5, 0
    
boucle_y:
    bge s5, s3, fin_rectangle
    li t0, 0
    
boucle_x:
    bge t0, s2, suivant_y
    
    # Calcul position pixel
    add a0, s0, t0
    add a1, s1, s5
    
    # Vérification limites
    lw t1, I_largeur
    lw t2, I_hauteur
    blt a0, zero, skip_pixel
    blt a1, zero, skip_pixel
    bge a0, t1, skip_pixel
    bge a1, t2, skip_pixel
    
    mv a2, s4
    addi sp, sp, -8
    sw t0, 4(sp)
    sw t1, 0(sp)
    jal I_plot # dessiner le pixel
    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp, sp, 8
    
skip_pixel:
    addi t0, t0, 1
    j boucle_x

suivant_y:
    addi s5, s5, 1
    j boucle_y

fin_rectangle:
    lw s5, 0(sp)
    lw s4, 4(sp)
    lw s3, 8(sp)
    lw s2, 12(sp)
    lw s1, 16(sp)
    lw s0, 20(sp)
    lw ra, 24(sp)
    addi sp, sp, 28
    jr ra

# =============================================
# FONCTION: I_buff_to_visu
# Transfère le contenu de I_buff vers I_visu
# =============================================
I_buff_to_visu:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    lw s0, I_buff           # Source
    lw s1, I_visu           # Destination
    lw t0, I_largeur
    lw t1, I_hauteur
    mul s2, t0, t1          # Nombre total de pixels
    li t2, 0                # Compteur
    
boucle_transfert:
    beq t2, s2, fin_transfert
    slli t3, t2, 2          # index × 4
    add t4, s0, t3          # adresse source
    add t5, s1, t3          # adresse destination
    lw t6, 0(t4)            # lire depuis buffer
    sw t6, 0(t5)            # écrire vers visu
    addi t2, t2, 1
    j boucle_transfert
    
fin_transfert:
    lw s2, 0(sp)
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    jr ra

# =============================================
# ANIMATION AVEC DOUBLE BUFFER
# Rectangle qui se déplace de façon fluide
# =============================================
animation_rectangle_double_buffer:
    addi sp, sp, -12
    sw ra, 8(sp)
    sw s0, 4(sp)  # position x
    sw s1, 0(sp)  # position y
    
    li s0, 0      # x départ
    li s1, 10     # y départ

boucle_animation:
    # Étape 1: Effacer le buffer de dessin
    jal I_effacer
    
    # Étape 2: Dessiner le rectangle dans le buffer
    mv a0, s0
    mv a1, s1
    li a2, 8      # largeur
    li a3, 6      # hauteur
    lw a4, rouge
    jal I_rectangle
    
    # Étape 3: Transférer vers le buffer d'affichage
    jal I_buff_to_visu
    
    # Étape 4: Pause pour l'animation
    li a0, 50    # 100ms pour voir le mouvement
    li a7, 32
    ecall
    
    # Étape 5: Déplacer le rectangle
    addi s0, s0, 1
    
    # Vérifier les limites
    lw t0, I_largeur
    addi t0, t0, -8        # 32 - largeur
    
    # Si on dépasse, recommencer
    blt s0, t0, boucle_animation

reset_position:
    li s0, 0
    j boucle_animation

fin_animation:
    lw s1, 0(sp)
    lw s0, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
    jr ra
