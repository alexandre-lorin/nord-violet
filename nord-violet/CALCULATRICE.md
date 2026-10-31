# Calculatrice A scientifique — 7 octobre 2026

## Intégration native — 8 octobre 2026 (prioritaire)

Validation utilisateur : Toubi confirme « la calc est parfaite, tout marche ». Ne plus la considérer comme maquette à choisir ou en attente de validation globale.

Calculatrice intégrée à Quickshell avec Calculator.qml, type inscrit dans qmldir et IPC `calculator`. Pas de navigateur ni terminal nécessaire. Fenêtre flottante centrée 880×720, panneau repliable vers 430 px, contenu défilant pour ne pas dépasser la hauteur. La commande `calc` et les touches XF86Calculator du RK et du portable affichent/masquent cette fenêtre. `calc 'W(1)'` ouvre puis calcule l'expression. Entrée calcule, Échap efface, Super+Q ferme la fenêtre ; fermeture via hide conservant la mémoire de cette instance. Entrée de lanceur Calculatrice Nord Violet ajoutée. qalc reste installé et directement utilisable.

Moteur HTML/Qt identique, partagé par symlink CalculatorEngine.js vers le moteur du paquet nord-violet. API JS rendue compatible Qt sans changer les calculs (déclaration exportée, hasOwnProperty, remplacement regex). Le symlink est absolu pour cette installation /home/toubi ; adapter si le dépôt est déplacé.

Validation : qmllint, desktop-file-validate, sh -n, configerrors et diff --check sans erreur ; 101 tests numériques Node et 50 tests Python passent. Huit calculs/domaines vérifiés dans le moteur Qt réel (W0, W−1, Gamma, PGCD, combinatoire, trigo, factorielle, division par zéro). Évaluation depuis l'interface IPC, masquage et réouverture avec résultat conservé vérifiés. Fenêtre réellement flottante 880×720 et rendu capturé. Erreurs transitoires lors du premier chargement corrigées ; dernier rechargement Quickshell réussi. Vérification physique des touches calculatrice et appréciation du rendu par Toubi encore attendues.

Les sections de maquette ci-dessous restent l'historique.

Direction A terminal choisie par Toubi. Maquette enrichie : `maquettes/calculatrice-a-scientifique.html`. Pas encore intégrée à Quickshell ; qalc et ses raccourcis conservés.

## Fonctionnalités présentes

- Panneau scientifique repliable, saisie libre et boutons insérés au curseur, Entrée calculer / Échap effacer.
- Trigonométrie, inverses et atan2 en RAD/DEG ; hyperboliques et inverses (indépendantes de l'unité angulaire).
- Racines, puissances associatives à droite, exponentielle, logarithmes, expm1/log1p ; constantes pi/e/tau/phi.
- W/w0 pour Lambert W principal ; wm1 pour la branche réelle −1. W accepte x ≥ −1/e ; wm1 accepte −1/e ≤ x < 0. Point −1/e traité explicitement, expansion locale près du point de branchement, bissection en domaine logarithmique ailleurs, série pour W0 près de zéro. Itérations bornées ; échec explicite si convergence insuffisante.
- Gamma par approximation de Lanczos et réflexion, pôles rejetés. Débordement de Gamma rejeté aussi à l'intérieur de la réflexion pour ne pas retourner un faux zéro.
- Factorielle entière 0…170, nCr/nPr, modulo, arrondis, min/max/hypot, PGCD/PPCM avec contrôle des entiers représentables.
- Variables a,b,c,h,n,r,t,x,y,z et x0…x99 par affectation `x = 12`. ans et mémoire conservés sans arrondi d'affichage. Journal réutilisable, 40 calculs en mémoire / 6 lignes affichées ; historique avec unité angulaire.

Moteur sans eval ni Function, longueur d'expression bornée à 500 caractères, noms inconnus et domaines invalides rejetés. Double précision réelle, pas précision arbitraire ni calcul symbolique. Les 14 chiffres affichés ne constituent pas une garantie universelle d'exactitude. Les très petites/grandes valeurs et singularités restent soumises aux limites Float64.

## Validation

21 tests historiques + 80 tests scientifiques/domaines/entiers passent. Références numériques pour W et Gamma, identités de Lambert W sur deux branches et plages jusqu'à 1e300, conventions de puissance, inverses trigonométriques et conversion des angles. Deux valeurs également comparées à qalc installé : W(1), Gamma(0.5).

Scripts JS des pages analysés avec vm.Script ; rendu complet dans Firefox headless contrôlé, dont génération des boutons. Aucun paquet ajouté ni téléchargement de bibliothèque. Pas de simulation des fonctions non implémentées.

Sources mathématiques : [NIST DLMF Lambert W](https://dlmf.nist.gov/4.13), [NIST DLMF Gamma / réflexion](https://dlmf.nist.gov/5.5).

## À venir après validation

Intégration native et remplacement des raccourcis calculatrice. Nombres complexes, solveur d'équations, dérivées et intégrales numériques ne sont pas présents dans cette version ; ne pas les annoncer comme fonctionnels. Validation utilisateur attendue sur densité, panneau scientifique et journal.
