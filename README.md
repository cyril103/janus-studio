# Janus Studio

Prototype d'IDE natif écrit en Janus pour développer des programmes Janus.

Cette première version fournit :

- un buffer éditable avec curseur et défilement vertical automatique ;
- l'ouverture d'un fichier passé en argument ;
- une sauvegarde atomique avec `Ctrl+S` ;
- le rechargement du fichier avec `Ctrl+O` ;
- l'exécution de `janus check` avec `F5` ;
- un panneau affichant les diagnostics du compilateur ;
- une édition modale inspirée de Vim avec modes NORMAL, INSERT et COMMAND ;
- un historique local de 100 états avec annulation et rétablissement ;
- la saisie Unicode respectant la disposition active du clavier, notamment AZERTY ;
- DejaVu Sans pour l'interface et Consolas pour le code lorsque la police est
  disponible sous Windows ou WSL ; DejaVu Sans Mono est embarquée comme police
  de repli portable ;
- des tests natifs pour les opérations essentielles du buffer.

## Prérequis

- la version de développement de Janus contenant `characterPressed` (présente
  dans le dépôt frère `../janus`) ;
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

Janus Studio démarre en mode **NORMAL**. `Esc` revient toujours dans ce mode.

### Mode NORMAL

| Raccourci | Action |
| --- | --- |
| `i`, `a` | passer en mode INSERT avant ou après le curseur |
| `o`, `O` | ouvrir une ligne dessous ou dessus et passer en INSERT |
| `h`, `j`, `k`, `l` | déplacer le curseur |
| `w`, `b` | aller au mot suivant ou précédent |
| `0`, `$` | aller au début ou à la fin de la ligne |
| `gg`, `G` | aller au début ou à la fin du fichier |
| `x`, `dd` | supprimer un caractère ou la ligne courante |
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
| `Ctrl+O` | recharger depuis le disque |
| `F5` | enregistrer puis lancer `janus check` |
| `Backspace`, `Delete`, `Tab` | éditer en mode INSERT |

## Limites connues du MVP

Le chargement des fichiers reste actuellement effectué octet par octet. La saisie
interactive suit en revanche la disposition du clavier et accepte Unicode. Les
prochaines étapes prévues sont :

1. décoder le contenu UTF-8 des fichiers en caractères Unicode ;
2. ajouter des processus persistants avec pipes pour parler à `janus-lsp` ;
3. implémenter la coloration syntaxique et la sélection de texte ;
4. ajouter l'arbre complet du projet, plusieurs onglets et la recherche ;
5. consommer les diagnostics JSON structurés plutôt que leur rendu humain.
