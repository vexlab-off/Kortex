#!/usr/bin/env bash
# ==============================================================================
# Kortex System Setup - Script d'installation automatisé
# Configuration complète pour Omarchy / Arch Linux + Hyprland + Quickshell
# ==============================================================================

set -euo pipefail

# Couleurs & Formatage
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"
PACKAGES_DIR="${SCRIPT_DIR}/packages"
ASSETS_DIR="${SCRIPT_DIR}/assets"
BOOTLOADER_DIR="${SCRIPT_DIR}/bootloader"
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="${HOME}/.config/kortex-backups/backup_${BACKUP_TIMESTAMP}"

# Auto-bootstrap si exécuté directement (ex: curl -fsSL ... | bash)
if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo -e "\033[0;34m\033[1m[INFO]\033[0m Dépôt Kortex non trouvé localement. Clonage automatique..."
  REPO_URL="https://github.com/vexlab-off/Kortex.git"
  BOOTSTRAP_DIR="${HOME}/.local/share/kortex-system"
  mkdir -p "$(dirname "$BOOTSTRAP_DIR")"
  if [[ -d "$BOOTSTRAP_DIR/.git" ]]; then
    git -C "$BOOTSTRAP_DIR" pull --ff-only 2>/dev/null || true
  else
    rm -rf "$BOOTSTRAP_DIR"
    git clone "$REPO_URL" "$BOOTSTRAP_DIR"
  fi
  exec bash "$BOOTSTRAP_DIR/install.sh" "$@"
fi

# Flags par défaut
OPT_CONFIGS=false
OPT_PACKAGES=false
OPT_PLUGINS=false
OPT_BOOTLOADER=false
OPT_ESSENTIAL_ONLY=false
OPT_COPY=false
OPT_YES=false
OPT_DRY_RUN=false

info() {
  echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}${BOLD}[OK]${NC} $1"
}

warn() {
  echo -e "${YELLOW}${BOLD}[ATTENTION]${NC} $1"
}

error() {
  echo -e "${RED}${BOLD}[ERREUR]${NC} $1" >&2
}

banner() {
  cat <<'EOF'
  _  ______  _____ _____ _______   __
 | |/ / __ \|  __ \_   _| ____\ \ / /
 | ' / |  | | |__) || | | |__   \ V / 
 |  <| |  | |  _  / | | |  __|   > <  
 | . \ |__| | | \ \_| |_| |____ / . \ 
 |_|\_\____/|_|  \_\_____|_____/_/ \_\
                                      
  Environnement Hyprland & Omarchy Shell personnalisé
EOF
  echo -e "${CYAN}------------------------------------------------------------${NC}\n"
}

confirm() {
  if [[ "$OPT_YES" == "true" ]]; then
    return 0
  fi
  local prompt_msg="${1:-Voulez-vous continuer ?}"
  read -r -p "$(echo -e "${YELLOW}${prompt_msg} [O/n] : ${NC}")" response
  case "$response" in
    [nN][oO]|[nN])
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

show_help() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Options :
  -a, --all             Installation complète (configs, paquets essentiels, plugins, wallpaper)
  -c, --configs         Installer uniquement les dotfiles et scripts (~/.config, ~/.local/bin)
  -p, --packages        Installer les paquets système (pacman et AUR)
      --essential-only  Avec --packages : installe uniquement les paquets essentiels
      --plugins         Installer et activer les thèmes et plugins Omarchy
  -b, --bootloader      Lancer la migration du bootloader vers GRUB (Thème Tartarus)
      --copy            Copier les fichiers au lieu de créer des liens symboliques
  -y, --yes             Mode non interactif (répond automatiquement 'Oui')
  -n, --dry-run         Simuler les actions sans modifier le système
  -h, --help            Afficher cette aide

Exemples :
  ./install.sh                  # Lance le menu interactif
  ./install.sh --all            # Installation complète
  ./install.sh -c -y            # Déploie les configs en mode automatique
  ./install.sh --plugins        # Installe uniquement les plugins de la barre
EOF
}

# ------------------------------------------------------------------------------
# Sauvegarde sécurisée
# ------------------------------------------------------------------------------
backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$OPT_DRY_RUN" == "true" ]]; then
      info "[DRY-RUN] Sauvegarde de $target vers $BACKUP_DIR"
      return 0
    fi
    mkdir -p "$BACKUP_DIR"
    local rel_name
    rel_name="$(basename "$target")"
    mv "$target" "${BACKUP_DIR}/${rel_name}"
    warn "Sauvegarde effectuée : $target -> ${BACKUP_DIR}/${rel_name}"
  fi
}

# ------------------------------------------------------------------------------
# Déploiement des Dotfiles
# ------------------------------------------------------------------------------
install_configs() {
  info "Déploiement des configurations et dotfiles..."

  mkdir -p "${HOME}/.config" "${HOME}/.local/bin" "${HOME}/Pictures"

  # Liste des répertoires et fichiers de configuration à déployer
  local configs=(
    "hypr"
    "kortex"
    "fastfetch"
    "kitty"
    "ghostty"
    "alacritty"
    "tmux"
    "environment.d"
    "wireplumber"
    "starship.toml"
  )

  for item in "${configs[@]}"; do
    local src="${DOTFILES_DIR}/.config/${item}"
    local dest="${HOME}/.config/${item}"

    if [[ ! -e "$src" ]]; then
      continue
    fi

    # Vérification si le lien existe déjà et pointe au bon endroit
    if [[ -L "$dest" && "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
      info "Déjà lié : $dest"
      continue
    fi

    backup_path "$dest"

    if [[ "$OPT_DRY_RUN" == "true" ]]; then
      info "[DRY-RUN] Liaison de $src -> $dest"
    elif [[ "$OPT_COPY" == "true" ]]; then
      cp -r "$src" "$dest"
      success "Copié : $item -> $dest"
    else
      ln -sfn "$src" "$dest"
      success "Lié : $src -> $dest"
    fi
  done

  # Symlink de compatibilité Omarchy -> Kortex
  local omarchy_config_link="${HOME}/.config/omarchy"
  if [[ ! -e "$omarchy_config_link" ]]; then
    if [[ "$OPT_DRY_RUN" == "false" ]]; then
      ln -sfn "${HOME}/.config/kortex" "$omarchy_config_link"
      success "Lien de compatibilité créé : ~/.config/omarchy -> ~/.config/kortex"
    fi
  fi

  # Scripts personnalisés dans ~/.local/bin
  info "Installation des scripts dans ~/.local/bin..."
  for script_path in "${DOTFILES_DIR}/.local/bin"/*; do
    if [[ -f "$script_path" ]]; then
      local script_name
      script_name="$(basename "$script_path")"
      local dest="${HOME}/.local/bin/${script_name}"

      if [[ "$OPT_DRY_RUN" == "true" ]]; then
        info "[DRY-RUN] Installation de $script_name -> $dest"
      elif [[ "$OPT_COPY" == "true" ]]; then
        cp "$script_path" "$dest"
        chmod +x "$dest"
        success "Script copié : $dest"
      else
        ln -sfn "$script_path" "$dest"
        chmod +x "$script_path"
        success "Script lié : $dest"
      fi
    fi
  done

  # Génération des alias Kortex pour les binaires Omarchy existants
  if [[ -d "/usr/share/omarchy/bin" ]]; then
    info "Génération des commandes kortex-* correspondantes..."
    if [[ "$OPT_DRY_RUN" == "false" ]]; then
      for bin in /usr/share/omarchy/bin/omarchy-*; do
        if [[ -f "$bin" ]]; then
          local base_name
          base_name="$(basename "$bin")"
          local kortex_name="kortex-${base_name#omarchy-}"
          local target_link="${HOME}/.local/bin/${kortex_name}"
          if [[ ! -e "$target_link" ]]; then
            ln -sfn "$bin" "$target_link"
          fi
        fi
      done
      success "Commandes kortex-* prêtes dans ~/.local/bin"
    fi
  fi

  # Configuration du shell (~/.bashrc et ~/.zshrc)
  info "Configuration de l'environnement Shell..."
  if [[ "$OPT_DRY_RUN" == "false" ]]; then
    if [[ -f "${HOME}/.bashrc" ]] && ! grep -q "Kortex environment and aliases" "${HOME}/.bashrc"; then
      echo "" >> "${HOME}/.bashrc"
      cat "${DOTFILES_DIR}/shell/bashrc-kortex.sh" >> "${HOME}/.bashrc"
      success "Ajouts Kortex intégrés à ~/.bashrc"
    fi

    if [[ -f "${HOME}/.zshrc" ]] && ! grep -q "Kortex Environment" "${HOME}/.zshrc"; then
      echo "" >> "${HOME}/.zshrc"
      cat "${DOTFILES_DIR}/shell/zshrc-kortex.sh" >> "${HOME}/.zshrc"
      success "Ajouts Kortex intégrés à ~/.zshrc"
    fi
  fi

  # Installation du fond d'écran
  local wp_src="${ASSETS_DIR}/wallpapers/mon-fond-starwatch.jpg"
  local wp_dest="${HOME}/Pictures/mon-fond-starwatch.jpg"
  if [[ -f "$wp_src" ]]; then
    if [[ "$OPT_DRY_RUN" == "false" ]]; then
      cp "$wp_src" "$wp_dest"
      success "Fond d'écran installé dans ~/Pictures/mon-fond-starwatch.jpg"
    fi
  fi

  success "Configurations et dotfiles déployés avec succès !"
}

# ------------------------------------------------------------------------------
# Installation des Paquets Système
# ------------------------------------------------------------------------------
install_packages() {
  info "Installation des paquets logiciels..."

  if ! command -v pacman &>/dev/null; then
    error "Pacman n'est pas détecté. Ce script est conçu pour Arch Linux / Omarchy."
    return 1
  fi

  # Choix du fichier de paquets
  local pkg_file="${PACKAGES_DIR}/pacman-essential.txt"
  if [[ "$OPT_ESSENTIAL_ONLY" == "false" && -f "${PACKAGES_DIR}/pacman-all.txt" ]]; then
    if confirm "Voulez-vous installer l'ensemble des paquets du système (180+ paquets) ou seulement les essentiels ?"; then
      pkg_file="${PACKAGES_DIR}/pacman-all.txt"
    fi
  fi

  if [[ "$OPT_DRY_RUN" == "true" ]]; then
    info "[DRY-RUN] Installation des paquets depuis $pkg_file"
    return 0
  fi

  # Lecture et filtrage des paquets
  local pkgs=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -n "$line" ]] && pkgs+=("$line")
  done < "$pkg_file"

  if ((${#pkgs[@]} > 0)); then
    info "Installation de ${#pkgs[@]} paquets officiels avec pacman..."
    sudo pacman -S --needed --noconfirm "${pkgs[@]}" || warn "Certains paquets pacman n'ont pas pu être installés."
  fi

  # Paquets AUR
  local aur_file="${PACKAGES_DIR}/aur-packages.txt"
  if [[ -f "$aur_file" ]]; then
    local aur_pkgs=()
    while IFS= read -r line || [[ -n "$line" ]]; do
      line="$(echo "$line" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      # On ignore limine-dummy s'il est listé car c'est un paquet local
      [[ -n "$line" && "$line" != "limine-dummy" ]] && aur_pkgs+=("$line")
    done < "$aur_file"

    if ((${#aur_pkgs[@]} > 0)); then
      local aur_helper=""
      if command -v yay &>/dev/null; then
        aur_helper="yay"
      elif command -v paru &>/dev/null; then
        aur_helper="paru"
      fi

      if [[ -n "$aur_helper" ]]; then
        info "Installation des paquets AUR via $aur_helper : ${aur_pkgs[*]}"
        $aur_helper -S --needed --noconfirm "${aur_pkgs[@]}" || warn "Certains paquets AUR n'ont pas pu être installés."
      else
        warn "Aucun helper AUR (yay/paru) détecté. Veuillez installer manuellement : ${aur_pkgs[*]}"
      fi
    fi
  fi

  # Flatpaks
  local flatpak_file="${PACKAGES_DIR}/flatpak-packages.txt"
  if [[ -f "$flatpak_file" ]] && command -v flatpak &>/dev/null; then
    while IFS= read -r app || [[ -n "$app" ]]; do
      app="$(echo "$app" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      if [[ -n "$app" ]]; then
        info "Installation Flatpak : $app"
        flatpak install -y flathub "$app" || true
      fi
    done < "$flatpak_file"
  fi

  success "Installation des logiciels terminée !"
}

# ------------------------------------------------------------------------------
# Installation des Plugins et Thèmes Omarchy
# ------------------------------------------------------------------------------
install_plugins() {
  info "Installation des plugins et thèmes Omarchy / Kortex..."

  if ! command -v omarchy &>/dev/null; then
    warn "La commande 'omarchy' n'est pas installée. Ignoré."
    return 0
  fi

  local plugins_file="${PACKAGES_DIR}/omarchy-plugins.txt"
  if [[ ! -f "$plugins_file" ]]; then
    warn "Fichier $plugins_file introuvable."
    return 0
  fi

  if [[ "$OPT_DRY_RUN" == "true" ]]; then
    info "[DRY-RUN] Installation des plugins Omarchy depuis $plugins_file"
    return 0
  fi

  while IFS= read -r url || [[ -n "$url" ]]; do
    url="$(echo "$url" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    if [[ -n "$url" ]]; then
      if [[ "$url" =~ theme ]]; then
        info "Installation du thème : $url"
        omarchy theme install "$url" 2>/dev/null || true
      else
        info "Ajout du plugin : $url"
        omarchy plugin add "$url" --enable 2>/dev/null || true
      fi
    fi
  done < "$plugins_file"

  # Application du thème par défaut
  omarchy theme set Vantablack 2>/dev/null || true

  # Rechargement de l'environnement actif
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    info "Rechargement de Hyprland..."
    hyprctl reload >/dev/null 2>&1 || true
  fi

  if command -v omarchy-shell &>/dev/null; then
    info "Rechargement de Omarchy Shell..."
    omarchy-shell shell reload >/dev/null 2>&1 || true
    omarchy-shell -q background setAnimation true 2>/dev/null || true
  fi

  success "Plugins et thèmes Omarchy installés et configurés !"
}

# ------------------------------------------------------------------------------
# Migration Bootloader GRUB
# ------------------------------------------------------------------------------
run_bootloader_migration() {
  info "Préparation de la migration du bootloader vers GRUB..."
  local grub_script="${BOOTLOADER_DIR}/switch_to_grub.sh"

  if [[ ! -f "$grub_script" ]]; then
    error "Script $grub_script introuvable !"
    return 1
  fi

  warn "ATTENTION : Cette étape va remplacer Limine par GRUB et appliquer le thème Tartarus."
  warn "Cette action nécessite les droits administrateur (sudo) et modifiera votre configuration de démarrage."
  if confirm "Êtes-vous absolument certain de vouloir migrer vers GRUB maintenant ?"; then
    sudo chmod +x "$grub_script"
    sudo "$grub_script"
    success "Migration GRUB terminée !"
  else
    info "Migration bootloader annulée."
  fi
}

# ------------------------------------------------------------------------------
# Analyse des arguments
# ------------------------------------------------------------------------------
parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--all)
        OPT_CONFIGS=true
        OPT_PACKAGES=true
        OPT_PLUGINS=true
        shift
        ;;
      -c|--configs)
        OPT_CONFIGS=true
        shift
        ;;
      -p|--packages)
        OPT_PACKAGES=true
        shift
        ;;
      --essential-only)
        OPT_ESSENTIAL_ONLY=true
        shift
        ;;
      --plugins)
        OPT_PLUGINS=true
        shift
        ;;
      -b|--bootloader)
        OPT_BOOTLOADER=true
        shift
        ;;
      --copy)
        OPT_COPY=true
        shift
        ;;
      -y|--yes)
        OPT_YES=true
        shift
        ;;
      -n|--dry-run)
        OPT_DRY_RUN=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        error "Option inconnue : $1"
        show_help
        exit 1
        ;;
    esac
  done
}

# ------------------------------------------------------------------------------
# Menu Interactif
# ------------------------------------------------------------------------------
interactive_menu() {
  banner
  echo -e "${BOLD}Sélectionnez le mode d'installation souhaité :${NC}\n"
  echo -e "  ${GREEN}1)${NC} ${BOLD}Installation Complète${NC} (Configs + Paquets essentiels + Plugins + Fond d'écran)"
  echo -e "  ${GREEN}2)${NC} Configurations & Dotfiles uniquement (~/.config, scripts ~/.local/bin)"
  echo -e "  ${GREEN}3)${NC} Paquets Système uniquement (Pacman + AUR + Flatpak)"
  echo -e "  ${GREEN}4)${NC} Plugins & Thèmes Omarchy Shell uniquement"
  echo -e "  ${GREEN}5)${NC} Migration Bootloader (Limine -> GRUB avec Thème Tartarus)"
  echo -e "  ${RED}6)${NC} Quitter\n"

  read -r -p "Entrez votre choix [1-6] : " choice

  case "$choice" in
    1)
      OPT_CONFIGS=true
      OPT_PACKAGES=true
      OPT_PLUGINS=true
      OPT_ESSENTIAL_ONLY=true
      ;;
    2)
      OPT_CONFIGS=true
      ;;
    3)
      OPT_PACKAGES=true
      ;;
    4)
      OPT_PLUGINS=true
      ;;
    5)
      OPT_BOOTLOADER=true
      ;;
    6|q|Q)
      info "Installation annulée."
      exit 0
      ;;
    *)
      error "Choix invalide."
      exit 1
      ;;
  esac
}

# ------------------------------------------------------------------------------
# Point d'entrée principal
# ------------------------------------------------------------------------------
main() {
  if [[ $# -eq 0 ]]; then
    interactive_menu
  else
    parse_args "$@"
  fi

  banner

  if [[ "$OPT_DRY_RUN" == "true" ]]; then
    warn "MODE SIMULATION (DRY-RUN) ACTIF : Aucune modification ne sera appliquée."
  fi

  if [[ "$OPT_CONFIGS" == "true" ]]; then
    install_configs
  fi

  if [[ "$OPT_PACKAGES" == "true" ]]; then
    install_packages
  fi

  if [[ "$OPT_PLUGINS" == "true" ]]; then
    install_plugins
  fi

  if [[ "$OPT_BOOTLOADER" == "true" ]]; then
    run_bootloader_migration
  fi

  echo -e "\n${GREEN}${BOLD}============================================================${NC}"
  echo -e "${GREEN}${BOLD}   Installation de Kortex terminée avec succès !           ${NC}"
  echo -e "${GREEN}${BOLD}============================================================${NC}\n"
  info "💡 Raccourcis utiles :"
  info "  - Ouvrir le menu Kortex       : SUPER + ESPACE"
  info "  - Éditer les raccourcis live  : SUPER + MAJ + K"
  info "  - Lancer un terminal Ghostty  : SUPER + ENTRÉE"
  info "  - Recharger Hyprland          : hyprctl reload"
  echo ""
}

main "$@"
