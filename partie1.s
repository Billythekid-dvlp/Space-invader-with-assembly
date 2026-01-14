.text
.globl main

main:
    # =============================================
    # INITIALISATION DES VARIABLES
    # t0 = compteur qui commence à 1
    # t1 = limite supérieure (on s'arrête à 10)
    # =============================================
    li t0, 1                # Initialiser le compteur à 1
    li t1, 11               # Définir la limite à 11 (exclusif)

boucle:
    # =============================================
    # CONDITION DE SORTIE DE BOUCLE
    # Si le compteur atteint ou dépasse la limite, on sort
    # =============================================
    bge t0, t1, fin         # Si t0 >= 11, aller à 'fin'

    # =============================================
    # AFFICHAGE DE LA VALEUR DU COMPTEUR
    # Utilise l'appel système pour afficher un entier
    # =============================================
    mv a0, t0               # Copier la valeur du compteur dans a0
    li a7, 1                # Code de l'appel système : print integer
    ecall                   # Exécuter l'appel système

    # =============================================
    # AFFICHAGE D'UN SAUT DE LIGNE
    # Pour séparer les nombres affichés
    # =============================================
    li a0, 10               # Code ASCII du caractère newline ('\n')
    li a7, 11               # Code de l'appel système : print character
    ecall                   # Exécuter l'appel système

    # =============================================
    # PAUSE DE 500 MILLISECONDES
    # Crée un délai entre chaque affichage
    # =============================================
    li a0, 500              # Durée de la pause en millisecondes
    li a7, 32               # Code de l'appel système : sleep
    ecall                   # Exécuter l'appel système

    # =============================================
    # INCREMENTATION DU COMPTEUR
    # Préparation pour l'itération suivante
    # =============================================
    addi t0, t0, 1          # Incrémenter le compteur : t0 = t0 + 1
    j boucle                # Retour au début de la boucle

fin:
    # =============================================
    # FIN DU PROGRAMME
    # Arrêt propre du programme
    # =============================================
    li a7, 10               # Code de l'appel système : exit
    ecall                   # Exécuter l'appel système