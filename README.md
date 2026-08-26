# Janus Studio

Prototype d'IDE natif écrit en Janus pour développer des programmes Janus.

Cette première version fournit :

- l'ouverture de plusieurs fichiers dans des onglets indépendants, avec
  indicateur de modification et fermeture protégée ;
- une interface sombre modernisée avec onglet actif, panneaux hiérarchisés,
  états de survol et dialogues visuellement distincts ;
- un buffer éditable avec curseur et défilement vertical automatique ;
- une gouttière avec numéros de ligne et marqueurs de diagnostics précis après
  vérification du fichier ;
- le défilement vertical indépendant de l'éditeur à la molette, avec une barre
  indiquant la position dans le fichier ;
- le défilement horizontal des longues lignes avec `Maj` + molette ou en
  faisant glisser la barre située au bas de l'éditeur ;
- le placement du curseur à la souris dans l'éditeur, borné à la fin de la ligne
  sélectionnée ;
- le redimensionnement à la souris de l'explorateur et du panneau de sortie,
  avec un pointeur adapté au survol de chaque séparateur ;
- une fenêtre native redimensionnable et maximisable sur Linux, Windows et WSL ;
- l'ouverture d'un fichier passé en argument ;
- l'ouverture et la création de fichiers depuis l'interface, ainsi que
  l'enregistrement sous un nouveau chemin ;
- une sauvegarde atomique avec `Ctrl+S` ;
- l'exécution de `janus check` avec `F5` ;
- un panneau affichant les diagnostics du compilateur ;
- une arborescence de projet chargée à la demande, navigable à la souris ;
- un menu Fichier permettant d'ouvrir ou de fermer le dossier affiché dans
  l'explorateur ;
- une édition modale inspirée de Vim avec modes NORMAL, INSERT et COMMAND ;
- une coloration syntaxique Janus pour les mots-clés, types, chaînes, nombres,
  commentaires et opérateurs ;
- une autocomplétion typée fournie par une session `janus-lsp` persistante,
  notamment pour le workspace, les membres de `Array` et les classes du fichier
  courant ;
- un historique local de 100 états avec annulation et rétablissement ;
- la saisie Unicode respectant la disposition active du clavier, notamment AZERTY ;
- DejaVu Sans pour l'interface et DejaVu Sans Mono pour le code, toutes deux
  embarquées afin de conserver le même rendu et la même couverture Unicode sur
  les plateformes prises en charge ;
- des tests natifs pour les opérations essentielles du buffer.

## Prérequis

- Janus 0.21.0 ou plus récent, avec `janus-lsp` ;
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

## Installer

Sous Linux ou WSL, l'installateur construit l'application en mode production,
copie le binaire et ses ressources dans `~/.local`, puis crée la commande
`janus-studio` :

```bash
./scripts/install.sh
janus-studio .
janus-studio /chemin/vers/un-projet
```

Le préfixe peut être personnalisé avec `JANUS_STUDIO_PREFIX`. Sous Windows,
l'équivalent PowerShell installe l'application dans
`%LOCALAPPDATA%\JanusStudio` et ajoute son dossier `bin` au `PATH` utilisateur :

Si plusieurs versions de Janus sont installées, `JANUS` permet de choisir le
compilateur sans modifier le `PATH` :

```bash
JANUS=/chemin/vers/janus ./scripts/install.sh
```

```powershell
$env:JANUS = "C:\chemin\vers\janus.exe"
.\scripts\install.ps1
janus-studio C:\chemin\vers\un-projet
```

Sous PowerShell, le même chemin peut aussi être fourni avec le paramètre
`-Janus`.

Pour désinstaller uniquement les fichiers créés par ces scripts :

```bash
janus-studio-uninstall
```

```powershell
janus-studio-uninstall
```

Utilisez le même `JANUS_STUDIO_PREFIX` (ou le paramètre PowerShell `-Prefix`)
que lors de l'installation. Sous Windows, le dossier ajouté au `PATH` est
également retiré. Les scripts `./scripts/uninstall.sh` et
`.\scripts\uninstall.ps1` peuvent aussi être lancés directement depuis le dépôt.

## Organisation du code

- `src/main.janus` initialise la session et orchestre la boucle de l'application ;
- `src/studio/files.janus` gère les documents et le dossier de projet ;
- `src/studio/input.janus` traduit les entrées en actions d'édition ;
- `src/studio/view.janus` contient la géométrie, le défilement et le rendu ;
- `src/editor/` regroupe les modèles d'édition indépendants de l'interface ;
- `src/tooling/` contient les intégrations avec le compilateur et le LSP.

## Lancer

Depuis ce répertoire :

```bash
janus run
janus run -- samples/welcome.janus
janus run -- /chemin/vers/un-fichier.janus
janus run -- /chemin/vers/un-dossier
```

Sans fichier en argument, Janus Studio démarre sans onglet ouvert. Lorsqu'un
dossier est passé en argument, il devient la racine de l'explorateur. Un chemin
de fichier ouvre directement ce document dans un onglet.

## Raccourcis

Janus Studio démarre en mode **NORMAL**. Le mode courant et la position du
curseur restent visibles dans la barre d'état en bas de la fenêtre. `Esc`
revient toujours dans ce mode.

Dans l'éditeur, `Maj` + molette déplace les longues lignes horizontalement. La
barre inférieure peut également être saisie à la souris. Un déplacement du
curseur ramène automatiquement la colonne active dans la zone visible.

Les fichiers ouverts restent disponibles dans la barre d'onglets. Cliquez sur
un onglet pour l'activer ou sur son `x` pour le fermer. `Ctrl+Tab` passe à
l'onglet suivant, `Ctrl+Maj+Tab` au précédent et `Ctrl+W` ferme l'onglet actif.
Un onglet contenant des modifications non enregistrées ne peut pas être fermé.
Lorsque la barre est pleine, la molette au-dessus des onglets ou la barre de
défilement située sous ceux-ci permet de parcourir tous les documents ouverts.

Le panneau de sortie possède son propre défilement : la molette parcourt les
messages verticalement, `Maj` + molette les déplace horizontalement, et les deux
barres peuvent être saisies à la souris.

L'explorateur suit les mêmes commandes pour parcourir une grande arborescence
ou révéler des noms de fichiers et dossiers plus larges que le panneau.

### Explorateur de projet

- le menu `Fichier` permet d'ouvrir un dossier par son chemin ou de fermer le
  dossier courant ;
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
| `/` | rechercher dans le fichier courant |
| `n`, `N` | résultat de recherche suivant ou précédent |
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
| `F5` | enregistrer puis lancer `janus check` sans bloquer l'interface |
| `Backspace`, `Delete`, `Tab` | éditer en mode INSERT |
| `.` ou `Ctrl+Espace` | ouvrir les propositions d'autocomplétion |
| `↑`, `↓` | sélectionner une proposition |
| `Entrée`, `Tab` | insérer la proposition sélectionnée |
| `Esc` | fermer les propositions |

En mode NORMAL, `:` ouvre la ligne de commande en bas de la fenêtre, comme
dans Vim. Les commandes `:w`, `:q`, `:q!`, `:wq` et `:x` y sont disponibles.
La touche `/` réutilise cette ligne pour saisir une recherche. `Entrée` place
le curseur sur la première occurrence à partir de sa position actuelle, puis
`n` et `N` parcourent les résultats dans les deux directions.

Les commandes de fichier ouvrent une fenêtre de saisie de chemin intégrée.
`Entrée` valide le chemin et `Esc` annule l'opération. Les chemins relatifs sont
résolus depuis le répertoire dans lequel Janus Studio a été lancé. Pour éviter
une perte de travail, `Ctrl+O` et `Ctrl+N` demandent d'abord d'enregistrer les
modifications éventuelles.
Le curseur du champ de chemin se déplace avec les flèches, `Home` et `End` ;
`Retour arrière` et `Suppr` modifient le texte autour de sa position.
`Tab` complète le nom de fichier ou de dossier comme dans un shell : un dossier
unique reçoit automatiquement un `/`, et plusieurs résultats avancent jusqu'à
leur préfixe commun.

## Limites connues du MVP

Le chargement des fichiers et la saisie interactive prennent en charge Unicode ;
les séquences UTF-8 invalides sont remplacées par U+FFFD. Les fins de ligne sont
normalisées en `LF` lors du chargement.

L'historique conserve au plus 100 états et limite aussi le volume cumulé des
instantanés. Sur un document très volumineux, les états les plus anciens peuvent
donc être abandonnés plus tôt. Une modification externe du fichier est détectée
avant l'enregistrement : Studio refuse alors l'écrasement, mais ne propose pas
encore d'outil de comparaison ou de fusion.

La recherche porte actuellement sur le document actif. La recherche dans tout
le projet, le débogage et les configurations personnalisées de construction ou
d'exécution restent à ajouter.
