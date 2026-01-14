# =============================================
# PARTIE 2 : ENTRÉE SYNCHRONE AU CLAVIER
# Programme qui affiche la valeur de t0 toutes les 500 ms
# Contrôles :
# - Touche 'i' : décrémente t0
# - Touche 'p' : incrémente t0  
# - Touche 'o' : arrête le programme
# - Autres touches : ignorées
# =============================================

.text
.globl main

main:
    # =============================================
    # INITIALISATION DE LA VARIABLE PRINCIPALE
    # t0 = valeur numérique à modifier via le clavier
    # =============================================
    li t0, 0                # Initialiser t0 à 0

boucle_principale:
    # =============================================
    # AFFICHAGE DE LA VALEUR COURANTE
    # Affiche la valeur de t0 à chaque itération
    # =============================================
    mv a0, t0               # Copier la valeur de t0 dans a0
    li a7, 1                # Code d'appel système : print integer
    ecall                   # Afficher la valeur entière

    # =============================================
    # LECTURE DU REGISTRE DE CONTRÔLE DU CLAVIER (RCR)
    # Adresse 0xffff0000 - Indique si une touche est disponible
    # =============================================
    lw t1, 0xffff0000       # Charger la valeur du registre RCR dans t1

    # =============================================
    # VÉRIFICATION SI UNE TOUCHE EST DISPONIBLE
    # Si RCR == 0, aucune touche n'a été pressée
    # =============================================
    beq t1, zero, pause     # Si pas de touche, aller directement à la pause

    # =============================================
    # LECTURE DU REGISTRE DE DONNÉES DU CLAVIER (RDR)
    # Adresse 0xffff0004 - Contient le code ASCII de la touche
    # Note : La lecture de RDR remet automatiquement RCR à 0
    # =============================================
    lw t2, 0xffff0004       # Charger le code ASCII de la touche dans t2

    # =============================================
    # TRAITEMENT DE LA TOUCHE 'i' (décrémentation)
    # Code ASCII : 105
    # =============================================
    li t3, 105              # Charger le code ASCII de 'i'
    beq t2, t3, touche_i    # Si touche == 'i', aller à touche_i

    # =============================================
    # TRAITEMENT DE LA TOUCHE 'p' (incrémentation)
    # Code ASCII : 112
    # =============================================
    li t3, 112              # Charger le code ASCII de 'p'
    beq t2, t3, touche_p    # Si touche == 'p', aller à touche_p

    # =============================================
    # TRAITEMENT DE LA TOUCHE 'o' (quitter)
    # Code ASCII : 111
    # =============================================
    li t3, 111              # Charger le code ASCII de 'o'
    beq t2, t3, quitter     # Si touche == 'o', aller à quitter

    # =============================================
    # TOUCHE NON RECONNUE - IGNORER
    # Si ce n'est pas i/p/o, on ignore la touche
    # =============================================
    j pause                 # Aller directement à la pause

touche_i:
    # =============================================
    # DÉCRÉMENTATION DE t0
    # =============================================
    addi t0, t0, -1         # t0 = t0 - 1
    j pause                 # Aller à la pause

touche_p:
    # =============================================
    # INCRÉMENTATION DE t0
    # =============================================
    addi t0, t0, 1          # t0 = t0 + 1
    j pause                 # Aller à la pause

quitter:
    # =============================================
    # ARRÊT PROPRE DU PROGRAMME
    # =============================================
    li a7, 10               # Code d'appel système : exit
    ecall                   # Quitter le programme

pause:
    # =============================================
    # PAUSE DE 500 MILLISECONDES
    # Crée un intervalle entre chaque vérification
    # =============================================
    li a0, 500              # Durée de la pause en millisecondes
    li a7, 32               # Code d'appel système : sleep
    ecall                   # Exécuter la pause

    # =============================================
    # RETOUR À LA BOUCLE PRINCIPALE
    # =============================================
    j boucle_principale     # Recommencer la boucle
