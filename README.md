<div align="center">

# 🌌 KORTEX SYSTEM SETUP

### *Environnement Hyprland & Kortex Shell ultra-personnalisé, moderne et performant*

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-00B4D8?style=for-the-badge&logo=hyprland&logoColor=white)](https://hyprland.org/)
[![Lua](https://img.shields.io/badge/Lua-Config-2C2D72?style=for-the-badge&logo=lua&logoColor=white)](https://lua.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

<br/>

```text
  _  ______  _____ _____ _______   __
 | |/ / __ \|  __ \_   _| ____\ \ / /
 | ' / |  | | |__) || | | |__   \ V / 
 |  <| |  | |  _  / | | |  __|   > <  
 | . \ |__| | | \ \_| |_| |____ / . \ 
 |_|\_\____/|_|  \_\_____|_____/_/ \_\
```

<p align="center">
  <b>Un dépôt complet et modulaire pour répliquer ou partager mon système d'exploitation complet : configurations Hyprland, barre Quickshell personnalisée, thèmes, éditeur de raccourcis interactif, scripts utilitaires, et intégration IA.</b>
</p>

---

</div>

## 📑 Sommaire

- [✨ Points Forts](#-points-forts)
- [🚀 Installation Rapide (En 1 Ligne)](#-installation-rapide-en-1-ligne)
- [📦 Installation Manuelle & Modulaire](#-installation-manuelle--modulaire)
- [🎛️ Options du Script d'Installation](#️-options-du-script-dinstallation)
- [⌨️ Principaux Raccourcis Clavier](#️-principaux-raccourcis-clavier)
- [📁 Structure du Répertoire](#-structure-du-répertoire)
- [🛡️ Sécurité & Sauvegarde Automatique](#️-sécurité--sauvegarde-automatique)
- [🎨 Personnalisation](#-personnalisation)
- [📜 Licence](#-licence)

---

## ✨ Points Forts

- 🪟 **Hyprland & Stack Wayland en Lua** : Architecture déclarative en Lua (`~/.config/hypr/`), disposition clavier française AZERTY (`fr`) avec `compose:caps`, correctifs multi-écrans et stabilité matérielle NVIDIA (`no_hardware_cursors = true`).
- 🍸 **Barre Supérieure Kortex / Quickshell** :
  - **Menu Kortex personnalisé (`nezumi.menu`)** avec logo Kortex vectoriel et intégration système.
  - **Widgets intégrés** : Apple Music & Apple Music Mini, contrôle des lumières Govee, statut des AirPods / Omapods, bascule NordVPN directe, gestionnaire multi-écrans `hyprmoncfg`, date & météo, contrôle audio, réseau, bluetooth et statut de mise à jour.
- ⌨️ **Éditeur de Raccourcis Live (`kortex-menu-keybindings`)** :
  - Appuyez sur <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>K</kbd> pour afficher et remapper vos raccourcis graphiquement.
  - Validation syntaxique stricte avec `luac` avant écriture et rechargement atomique dans Hyprland sans redémarrer la session.
- 🤖 **Intégration AI Agent (`kortex-agent`)** :
  - Pont natif avec **Antigravity (`agy`)** intégré dans les menus du système et accessible via la touche raccourci rapide ou le menu principal.
- 💻 **Terminaux & Outils Modernes** :
  - Configurations peaufinées pour **Ghostty**, **Kitty**, et **Alacritty**.
  - Invite de commande élégante et réactive avec **Starship**.
  - Affichage système instantané avec **Fastfetch** aux couleurs Kortex.
- 🚀 **Migration Bootloader GRUB & Thème Tartarus** :
  - Module complet pour remplacer Limine par GRUB avec support complet UEFI, LUKS2 (chiffrement) et sous-volumes Btrfs.

---

## 🚀 Installation Rapide (En 1 Ligne)

Pour installer et lancer l'environnement Kortex directement en une seule commande :

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vexlab-off/Kortex/main/install.sh)
```

Ou en clonant le dépôt :

```bash
git clone https://github.com/vexlab-off/Kortex.git ~/kortex-system && cd ~/kortex-system && ./install.sh
```

> [!TIP]
> Si vous préférez tester sans rien modifier sur votre disque, utilisez le mode simulation :
> ```bash
> ./install.sh --dry-run
> ```

---

## 📦 Installation Manuelle & Modulaire

### 1. Cloner le dépôt

```bash
git clone https://github.com/vexlab-off/Kortex.git ~/kortex-system
cd ~/kortex-system
```

### 2. Lancer l'installateur

Exécutez simplement le script pour ouvrir le menu interactif :

```bash
./install.sh
```

Vous pourrez alors choisir :
1. **Installation Complète** (Configs, paquets essentiels, plugins, fond d'écran)
2. **Configurations & Dotfiles uniquement** (sans toucher aux paquets système)
3. **Paquets Système uniquement** (Pacman, AUR et Flatpak)
4. **Plugins & Thèmes de la barre Kortex uniquement**
5. **Migration Bootloader (Limine -> GRUB)**

---

## 🎛️ Options du Script d'Installation

Le script `install.sh` est entièrement scriptable et accepte de nombreux drapeaux :

| Option | Description |
|---|---|
| `-a`, `--all` | Déploie tout : paquets essentiels, configurations, scripts, plugins et fond d'écran. |
| `-c`, `--configs` | Installe uniquement les dotfiles (`~/.config`, `~/.local/bin`, shell, wallpaper). |
| `-p`, `--packages` | Installe les paquets via `pacman` et votre helper AUR (`yay` / `paru`). |
| `--essential-only` | À combiner avec `-p` : restreint aux logiciels essentiels du bureau. |
| `--plugins` | Installe et active les extensions et thèmes de la barre Kortex. |
| `-b`, `--bootloader` | Lance la migration complète vers GRUB (Thème Tartarus). |
| `--copy` | Copie les fichiers au lieu de créer des liens symboliques. |
| `-y`, `--yes` | Mode sans confirmation (automatisation). |
| `-n`, `--dry-run` | Mode simulation (affiche ce qui serait fait sans toucher au système). |
| `-h`, `--help` | Affiche l'aide détaillée. |

### Exemples pratiques

- **Déployer uniquement les fichiers de configuration sans confirmation :**
  ```bash
  ./install.sh -c -y
  ```

- **Installer tout le système en mode copie physique (sans liens symboliques) :**
  ```bash
  ./install.sh --all --copy
  ```

---

## ⌨️ Principaux Raccourcis Clavier

| Raccourci | Action |
|---|---|
| <kbd>SUPER</kbd> + <kbd>ESPACE</kbd> | Ouvrir le **Menu Kortex** |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>K</kbd> | Ouvrir l'**Éditeur de raccourcis Hyprland** en direct |
| <kbd>SUPER</kbd> + <kbd>ENTRÉE</kbd> | Ouvrir le terminal par défaut (**Ghostty** / Kitty) |
| <kbd>SUPER</kbd> + <kbd>W</kbd> | Fermer la fenêtre active (Scratchpad pour Apple Music) |
| <kbd>SUPER</kbd> + <kbd>S</kbd> | Afficher / Masquer le Scratchpad |
| <kbd>SUPER</kbd> + <kbd>1-9</kbd> | Changer d'espace de travail |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>1-9</kbd> | Déplacer la fenêtre vers l'espace de travail N |
| <kbd>SUPER</kbd> + <kbd>SHIFT</kbd> + <kbd>S</kbd> | Capture d'écran interactive |

---

## 📁 Structure du Répertoire

```text
kortex-system/
├── install.sh                     # Script d'installation principal automatisé
├── README.md                      # Documentation complète
├── LICENSE                        # Licence MIT
├── .gitignore                     # Règles d'exclusion Git
├── .github/
│   └── workflows/lint-check.yml   # Validation CI (syntaxe Bash, Lua, JSON)
├── dotfiles/
│   ├── .config/
│   │   ├── hypr/                  # Configuration Hyprland modulaire (Lua)
│   │   ├── kortex/                # Configuration Kortex Shell (JSON, branding, plugins)
│   │   ├── fastfetch/             # Configuration Fastfetch avec logo ASCII
│   │   ├── kitty/                 # Configuration Kitty Terminal
│   │   ├── ghostty/               # Configuration Ghostty Terminal
│   │   ├── alacritty/             # Configuration Alacritty Terminal
│   │   ├── tmux/                  # Configuration Tmux
│   │   ├── environment.d/         # Variables Wayland Firefox
│   │   ├── wireplumber/           # Profils audio Bluetooth A2DP
│   │   └── starship.toml          # Style du prompt Starship
│   ├── .local/bin/
│   │   ├── kortex                 # Wrapper d'environnement Kortex
│   │   ├── kortex-menu-keybindings# Éditeur interactif de raccourcis
│   │   ├── kortex-agent           # Lanceur de l'agent IA (Antigravity)
│   │   ├── kortex-default-agent   # Sélecteur d'agent par défaut
│   │   └── uname                  # Remplacement cosmétique uname
│   └── shell/
│       ├── bashrc-kortex.sh       # Extensions pour ~/.bashrc
│       └── zshrc-kortex.sh        # Extensions pour ~/.zshrc
├── packages/
│   ├── pacman-essential.txt       # Paquets de base (bureau, audio, shell)
│   ├── pacman-all.txt             # Liste exhaustive des paquets du système
│   ├── aur-packages.txt           # Paquets AUR spécifiques
│   ├── flatpak-packages.txt       # Applications Flatpak
│   └── kortex-plugins.txt         # Dépôts des plugins et thèmes de la barre
├── assets/
│   └── wallpapers/                # Fond d'écran Kortex haute résolution (4K)
└── bootloader/
    ├── switch_to_grub.sh          # Script de migration Limine -> GRUB
    ├── tartarus-grub/             # Thème GRUB Tartarus
    ├── limine-dummy/              # Paquet dummy Arch pour satisfaire les dépendances
    └── README.md                  # Documentation dédiée au bootloader
```

---

## 🛡️ Sécurité & Sauvegarde Automatique

Avant toute modification, `install.sh` effectue automatiquement une **sauvegarde horodatée** de vos configurations existantes dans :

```text
~/.config/kortex-backups/backup_YYYYMMDD_HHMMSS/
```

Aucun de vos anciens fichiers n'est écrasé sans possibilité de restauration immédiate.

---

## 🎨 Personnalisation

- **Changer de thème :**
  ```bash
  kortex theme set lawson-night
  # ou
  kortex theme set mars
  ```
- **Définir un fond d'écran :**
  ```bash
  swww img ~/Pictures/votre_image.jpg
  ```
- **Ajouter un widget ou modifier la barre :**
  Éditez simplement `~/.config/kortex/shell.json`.

---

## 📜 Licence

Ce projet est sous licence **MIT**. Vous êtes libre de l'utiliser, de le modifier et de le redistribuer selon vos besoins.
