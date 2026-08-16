# Janus Studio

Prototype d'IDE natif écrit en Janus pour développer des programmes Janus.

Cette première version fournit :

- un buffer éditable avec curseur et défilement vertical automatique ;
- l'ouverture d'un fichier passé en argument ;
- une sauvegarde atomique avec `Ctrl+S` ;
- le rechargement du fichier avec `Ctrl+O` ;
- l'exécution de `janus check` avec `F5` ;
- un panneau affichant les diagnostics du compilateur ;
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

| Raccourci | Action |
| --- | --- |
| `Ctrl+S` | enregistrer le fichier actif |
| `Ctrl+O` | recharger depuis le disque |
| `F5` | enregistrer puis lancer `janus check` |
| flèches, `Home`, `End` | déplacer le curseur |
| `Backspace`, `Delete` | supprimer du texte |
| `Tab` | insérer quatre espaces |
| `Escape` | quitter |

## Limites connues du MVP

Le chargement des fichiers reste actuellement effectué octet par octet. La saisie
interactive suit en revanche la disposition du clavier et accepte Unicode. Les
prochaines étapes prévues sont :

1. décoder le contenu UTF-8 des fichiers en caractères Unicode ;
2. ajouter des processus persistants avec pipes pour parler à `janus-lsp` ;
3. implémenter la coloration syntaxique et la sélection de texte ;
4. ajouter l'arbre complet du projet, plusieurs onglets et la recherche ;
5. consommer les diagnostics JSON structurés plutôt que leur rendu humain.
