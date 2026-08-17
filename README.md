# Janus Studio

Prototype d'IDE natif écrit en Janus pour développer des programmes Janus.

Cette première version fournit :

- un buffer éditable avec curseur et défilement vertical automatique ;
- l'ouverture d'un fichier passé en argument ;
- l'ouverture et la création de fichiers depuis l'interface, ainsi que
  l'enregistrement sous un nouveau chemin ;
- une sauvegarde atomique avec `Ctrl+S` ;
- l'exécution de `janus check` avec `F5` ;
- un panneau affichant les diagnostics du compilateur ;
- une arborescence de projet chargée à la demande, navigable à la souris ;
- une édition modale inspirée de Vim avec modes NORMAL, INSERT et COMMAND ;
- une coloration syntaxique Janus pour les mots-clés, types, chaînes, nombres,
  commentaires et opérateurs ;
- une autocomplétion typée fournie par une session `janus-lsp` persistante,
  notamment pour le workspace, les membres de `Array` et les classes du fichier
  courant ;
- un historique local de 100 états avec annulation et rétablissement ;
- la saisie Unicode respectant la disposition active du clavier, notamment AZERTY ;
- DejaVu Sans pour l'interface et Consolas pour le code lorsque la police est
  disponible sous Windows ou WSL ; DejaVu Sans Mono est embarquée comme police
  de repli portable ;
- des tests natifs pour les opérations essentielles du buffer.

## Prérequis

- la version de développement de Janus contenant `characterPressed` (présente
  dans le dépôt frère `../janus`) ;
- la version de développement de `janus-lsp` contenant la complétion typée des
  membres ;
- raylib 6 disponible pour l'exécution de l'interface graphique.

Le compilateur peut construire l'application sans raylib. Le backend graphique
est chargé dynamiquement au lancement et produit une erreur propre s'il manque.

## Construire et tester

```bash
janus fmt --check
janus check
janus test
janus build
```

## Lancer

Depuis ce répertoire :

```bash
janus run
janus run -- samples/welcome.janus
janus run -- /chemin/vers/un-fichier.janus
```

Le chemin par défaut est `samples/welcome.janus`.

## Raccourcis

Janus Studio démarre en mode **NORMAL**. Le mode courant et la position du
curseur restent visibles dans la barre d'état en bas de la fenêtre. `Esc`
revient toujours dans ce mode.

### Explorateur de projet

- un clic sur un dossier le déplie ou le replie ;
- un clic sur un fichier le sélectionne ;
- un double-clic sur un fichier l'ouvre dans l'éditeur ;
- la molette fait défiler les entrées lorsque l'arborescence dépasse la fenêtre.

L'ouverture est refusée tant que le fichier courant contient des modifications
non enregistrées, afin d'éviter toute perte de travail.

### Mode NORMAL

| Raccourci | Action |
| --- | --- |
| `i`, `a` | passer en mode INSERT avant ou après le curseur |
| `o`, `O` | ouvrir une ligne dessous ou dessus et passer en INSERT |
| `h`, `j`, `k`, `l` | déplacer le curseur |
| `w`, `b` | aller au mot suivant ou précédent |
| `0`, `$` | aller au début ou à la fin de la ligne |
| `gg`, `G` | aller au début ou à la fin du fichier |
| `x`, `dd` | supprimer un caractère ou couper la ligne courante |
| `yy` | copier la ligne courante dans le registre interne |
| `p`, `P` | coller la ligne du registre dessous ou dessus |
| `u`, `Ctrl+R` | annuler ou rétablir |
| `:` | passer en mode COMMAND |
| flèches, `Home`, `End` | déplacer le curseur |

### Mode INSERT et commandes

| Raccourci | Action |
| --- | --- |
| `Esc` | revenir en mode NORMAL |
| `:w` | enregistrer |
| `:q` | quitter si le fichier n'est pas modifié |
| `:q!` | quitter sans enregistrer |
| `:wq`, `:x` | enregistrer puis quitter |
| `Ctrl+S` | enregistrer le fichier actif |
| `Ctrl+O` | saisir le chemin d'un fichier à ouvrir |
| `Ctrl+N` | saisir le chemin d'un nouveau fichier |
| `Ctrl+Shift+S` | enregistrer le fichier sous un nouveau chemin |
| `F5` | enregistrer puis lancer `janus check` |
| `Backspace`, `Delete`, `Tab` | éditer en mode INSERT |
| `.` ou `Ctrl+Espace` | ouvrir les propositions d'autocomplétion |
| `↑`, `↓` | sélectionner une proposition |
| `Entrée`, `Tab` | insérer la proposition sélectionnée |
| `Esc` | fermer les propositions |

En mode NORMAL, `:` ouvre la ligne de commande en bas de la fenêtre, comme
dans Vim. Les commandes `:w`, `:q`, `:q!`, `:wq` et `:x` y sont disponibles.

Les commandes de fichier ouvrent une fenêtre de saisie de chemin intégrée.
`Entrée` valide le chemin et `Esc` annule l'opération. Les chemins relatifs sont
résolus depuis le répertoire dans lequel Janus Studio a été lancé. Pour éviter
une perte de travail, `Ctrl+O` et `Ctrl+N` demandent d'abord d'enregistrer les
modifications éventuelles.

## Limites connues du MVP

Le chargement des fichiers et la saisie interactive prennent en charge Unicode.
Les séquences UTF-8 invalides sont remplacées par U+FFFD. Les prochaines étapes
prévues sont :

1. implémenter la sélection de texte ;
2. ajouter plusieurs onglets et la recherche dans le projet ;
3. consommer les diagnostics JSON structurés plutôt que leur rendu humain.
