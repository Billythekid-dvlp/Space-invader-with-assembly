.data
        # ===== VARIABLES DE POSITION DU JOUEUR =====
        J_old_x: .word 14   # ancienne position X
        J_old_y: .word 28   # ancienne position Y
        
        # ===== CONFIGURATION CLAVIER (MAPPAGE MÉMOIRE) =====
        KEYBOARD_CTRL: .word 0xffff0000
        KEYBOARD_DATA: .word 0xffff0004
        
        # ===== ÉTAT ET CONFIGURATION DU JEU =====
        game_running: .word 1
        frame_delay:  .word 100

.text
.globl main

main:
        # ===== PHASE D'INITIALISATION =====
        li s1, 14   # s1 = position X initiale joueur (registre conservé)
        li s2, 28   # s2 = position Y initiale joueur (registre conservé)
        
        # Initialisation affichage
        jal effacer_ecran # Remplir écran de noir
        jal dessiner_scene_complete # Dessiner éléments initiaux
        
        # ===== LANCEMENT BOUCLE PRINCIPALE =====
        j boucle_jeu # ===== LANCEMENT BOUCLE PRINCIPALE =====
        
boucle_jeu:
	# ===== BOUCLE PRINCIPALE - EXÉCUTÉE 10 FOIS/SECONDE =====
        lw t0, game_running # Charger état du jeu
        beqz t0, fin_jeu # Si game_running=0, quitter le jeu
        
	# === ÉTAPE 1: SAUVEGARDE POSITION ===
    	# But: Mémoriser position actuelle avant modification
        la t1, J_old_x # Charger adresse variable J_old_x
        sw s1, 0(t1) # Sauvegarder position X actuelle
        la t1, J_old_y # Charger adresse variable J_old_y
        sw s2, 0(t1) # Sauvegarder position Y actuelle
        
        # === ÉTAPE 2: GESTION CLAVIER ===
        jal gerer_clavier       # Lire entrées et mettre à jour s1,s2
        
	# === ÉTAPE 3: AFFICHAGE ===
    	# Effacer ancienne position (rectangle noir)
        la t1, J_old_x 	
        lw a0, 0(t1) # a0 = ancien X à effacer
        la t1, J_old_y 
        lw a1, 0(t1) # a1 = ancien Y à effacer
        li a2, 4  # a2 = largeur joueur
        li a3, 2  # a3 = hauteur joueur
        li a4, 0x00000000  # a4 = couleur noire (effacement)
        jal dessiner_rectangle
        
        # Dessiner nouvelle position du joueur (rectangle vert)			
        mv a0, s1   # a0 = nouvelle position X
        mv a1, s2   # a1 = nouvelle position Y
        li a2, 4    # a2 = largeur
        li a3, 2    # a3 = hauteur 
        li a4, 0x0000ff00  # a4 = couleur verte								
        jal dessiner_rectangle			 								  
        
        
        # === ÉTAPE 4: RÉGULATION VITESSE ===
        lw a0, frame_delay # Charger délai entre frames
        li a7, 32 # Appel système sleep (pause)
        ecall
        
        j boucle_jeu

fin_jeu:
	# ===== POINT DE SORTIE DU PROGRAMME =====
        li a7, 10 # Appel système exit
        ecall
        
dessiner_scene_complete:
	# ===== DESSIN DE TOUS LES ÉLÉMENTS GRAPHIQUES =====
        addi sp, sp, -16 # Réserver espace pile
        sw ra, 12(sp) # Sauvegarder adresse retour
        sw s0, 8(sp) # Sauvegarder s0 (registre temporaire)
        
        
        # --- Dessin joueur ---
        mv a0, s1   # Position X depuis s1
        mv a1, s2   # Position Y depuis s2
        li a2, 4    # Largeur 4 pixels
        li a3, 2    # Hauteur 2 pixels
        li a4, 0x0000ff00  # Couleur verte
        jal dessiner_rectangle
        
        # --- Dessin envahisseurs (24 en formation) ---
        li s0, 0
boucle_env:
        li t0, 24
        bge s0, t0, fin_env  # Si 24 envahisseurs dessinés → fin
        
        # Calcul position envahisseur [s0]
        li t0, 8 
        div t1, s0, t0  # t1 = ligne (0-2) = s0 / 8
        rem t2, s0, t0  # t2 = colonne (0-7) = s0 % 8
        
        slli t3, t2, 2 # t3 = colonne × 4 (espacement horizontal)
        addi a0, t3, 1 # a0 = X = (colonne×4) + 1
        
        li t4, 3
        mul t5, t1, t4 # t5 = ligne × 3 (espacement vertical)
        addi a1, t5, 2 # a1 = Y = (ligne×3) + 2
        
        li a2, 3 # Largeur envahisseur
        li a3, 2 # Hauteur envahisseur
        li a4, 0x00ff0000 # Couleur rouge
        jal dessiner_rectangle
        
        addi s0, s0, 1
        j boucle_env
fin_env:
        
        # --- Dessin obstacles (4 barrières) ---
        li s0, 0 # s0 = compteur obstacles (0-3)
boucle_obs:
        li t0, 4
        bge s0, t0, fin_obs # Si 4 obstacles dessinés → fin
        
        # Calcul position obstacle [s0]
        li t1, 6
        mul t2, s0, t1 # t2 = index × 6 (espacement)
        addi a0, t2, 5 # a0 = X = (index×6) + 5
        
        
        li a1, 22 # a1 = Y fixe (près du bas)
        li a2, 4 # Largeur obstacle
        li a3, 3 # Hauteur obstacle
        li a4, 0x0000ffff # Couleur cyan
        jal dessiner_rectangle
        
        addi s0, s0, 1
        j boucle_obs
fin_obs:
        
        lw s0, 8(sp) # Restaurer s0
        lw ra, 12(sp) # Restaurer adresse retour
        addi sp, sp, 16 # Libérer pile
        jr ra

gerer_clavier:
	# ===== GESTION DES ENTREES CLAVIER =====
        lw t1, 0xffff0000 # Lire registre contrôle clavier
        beqz t1, fin_clavier # Si bit 0=0, pas de touche → sorti
        
        lw t2, 0xffff0004 # Lire code ASCII touche appuyée
        
        # --- Vérification touche ESC (quitter) ---
        li t3, 27 # code ascii de : ESC
        beq t2, t3, quitter # Si ESC, aller à routine quitter
        
        # --- Vérification touche i (déplacer à gauche) ---
        li t3, 105 # code ascii de : i
        beq t2, t3, gauche # Si 'i', aller à routine gauche
        
        # --- Vérification touche p (déplacer à droite) ---
        li t3, 112 # code ascii de : p
        beq t2, t3, droite # Si 'p', aller à routine droite
        
        j fin_clavier # Autre touche → ignorer

quitter:
	# ===== ROUTINE ARRÊT DU JEU =====
        la t0, game_running # Charger adresse variable game_running
        sw zero, 0(t0) # Mettre à 0 pour signaler arrêt
        j fin_clavier

gauche:
	# ===== DÉPLACEMENT VERS LA GAUCHE =====
        blez s1, fin_clavier # Si position X déjà à 0, ne pas bouger
        addi s1, s1, -1 # Décrémenter position X
        j fin_clavier 

droite:
	# ===== DÉPLACEMENT VERS LA DROITE =====
        li t0, 63 # Limite droite (32 - largeur 1)
        bge s1, t0, fin_clavier # Si position X à limite, ne pas bouger
        addi s1, s1, 1 # Incrémenter position X
        j fin_clavier

fin_clavier:
        jr ra # Retour à l'appelant


effacer_ecran:
	# ===== REMPLISSAGE COMPLET DE L'ECRAN =====
        li t0, 0x10004000 # Adresse de base mémoire vidéo 
        li t1, 0x00FF0000 # Couleur noire
        li t2, 1024 # Nombre total pixels (32×32)
        li t3, 0 # Compteur de pixels
        
boucle_effacer:
    bge t3, t2, fin_effacer    # Si tous pixels traités → fin
    
    # Calcul adresse pixel courant
    slli t4, t3, 2             # Offset = index × 4 (car mots 32 bits)
    add t5, t0, t4             # Adresse pixel = base + offset
    
    sw t1, 0(t5)               # Écrire noir à cette adresse
    
    addi t3, t3, 1             # Incrémenter compteur
    j boucle_effacer
    
fin_effacer:
    jr ra

dessiner_rectangle:
	# ===== DESSIN D'UN RECTANGLE PLEIN =====
	# Entrées: a0=X, a1=Y, a2=largeur, a3=hauteur, a4=couleur
        addi sp, sp, -28 # Réserver pile pour 7 registres
        sw ra, 24(sp) # Sauvegarder registres
        sw s0, 20(sp) # s0 = position X
        sw s1, 16(sp) # s1 = position Y  
        sw s2, 12(sp) # s2 = largeur
        sw s3, 8(sp) # s3 = hauteur
        sw s4, 4(sp) # s4 = couleur
        sw s5, 0(sp) # s5 = compteur lignes
        
        # Sauvegarde paramètres dans registres conservés
        mv s0, a0
        mv s1, a1
        mv s2, a2
        mv s3, a3
        mv s4, a4
        li s5, 0 # Initialiser compteur lignes
        
boucle_ligne:
        bge s5, s3, fin_rect  # Si toutes lignes traitées → fin
        li t0, 0  # Compteur colonnes
        
boucle_colonne:
        bge t0, s2, ligne_suivante  # Si toutes colonnes traitées → ligne suivante
        
        # Calcul coordonnées pixel
    	add a0, s0, t0   # a0 = X + colonne
    	add a1, s1, s5  # a1 = Y + ligne
   	 mv a2, s4 # a2 = couleur
    
    	jal dessiner_pixel # Dessiner ce pixel
    
    	addi t0, t0, 1  # Colonne suivante
	j boucle_colonne
	
ligne_suivante:
    addi s5, s5, 1             # Ligne suivante
    j boucle_ligne

fin_rect:
    	# Restauration registres
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
    	# ===== DESSIN D'UN PIXEL INDIVIDUEL =====
    	# Entrées: a0=X, a1=Y, a2=couleur
    	# Vérification limites écran (0-31)
    	blt a0, zero, skip_pixel   # Si X < 0 → ignorer
    	blt a1, zero, skip_pixel   # Si Y < 0 → ignorer
    	li t0, 32
    	bge a0, t0, skip_pixel     # Si X ≥ 32 → ignorer
    	bge a1, t0, skip_pixel     # Si Y ≥ 32 → ignorer
    
    	# Calcul adresse mémoire pixel
   	 slli t1, a1, 5             # t1 = Y × 32 (car 32 pixels/ligne)
    	add t1, t1, a0             # t1 = (Y×32) + X (index linéaire)
    
    	li t2, 0x10010000          # Adresse base mémoire vidéo
   	slli t3, t1, 2             # t3 = index × 4 (car mots 32 bits)
    	add t2, t2, t3             # t2 = adresse finale pixel
    
    	sw a2, 0(t2)               # Écrire couleur en mémoire

skip_pixel:
    	jr ra                      # Retour même si pixel ignoré

