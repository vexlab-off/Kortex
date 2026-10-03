#!/usr/bin/env bash
# ==============================================================================
# Script de migration complète de Limine vers GRUB avec le thème Tartarus
# Adapté spécialement pour Omarchy (Arch Linux + LUKS2 + Btrfs + NVMe / SATA)
# ==============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}${BOLD}[*]${NC} $1"
}

success() {
    echo -e "${GREEN}${BOLD}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}${BOLD}[!]${NC} $1"
}

error() {
    echo -e "${RED}${BOLD}[✗]${NC} $1" >&2
}

if [[ $EUID -ne 0 ]]; then
   error "Ce script doit être exécuté avec les privilèges root (sudo)."
   exit 1
fi

echo -e "${BOLD}======================================================${NC}"
echo -e "${BOLD}   Migration de Limine vers GRUB (Thème Tartarus)     ${NC}"
echo -e "${BOLD}======================================================${NC}\n"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="${SCRIPT_DIR}/tartarus-grub/tartarus"
DUMMY_PKG="${SCRIPT_DIR}/limine-dummy/limine-dummy-99.0-1-any.pkg.tar.zst"

# 1. Vérification des prérequis
info "1. Vérification de l'environnement..."
if ! [ -d /sys/firmware/efi ]; then
    error "Le système n'est pas démarré en mode UEFI !"
    exit 1
fi

if ! [ -f "$DUMMY_PKG" ]; then
    error "Le paquet dummy $DUMMY_PKG n'a pas été trouvé."
    exit 1
fi

if ! [ -d "$THEME_SRC" ]; then
    error "Le dossier du thème Tartarus ($THEME_SRC) n'a pas été trouvé."
    exit 1
fi
success "Environnement UEFI validé."

# 2. Remplacement propre des paquets Limine par le paquet dummy
info "2. Désinstallation des paquets Limine (limine, limine-mkinitcpio-hook, limine-snapper-sync)..."
pacman -Rdd --noconfirm limine limine-mkinitcpio-hook limine-snapper-sync 2>/dev/null || true
pacman -U --noconfirm "$DUMMY_PKG"
success "Paquets Limine désinstallés avec succès et dépendances satisfaites."

# 3. Installation de GRUB, efibootmgr, os-prober et grub-btrfs
info "3. Installation de GRUB et des outils nécessaires..."
pacman -S --needed --noconfirm grub efibootmgr os-prober grub-btrfs
success "GRUB et outils installés."

# 4. Suppression complète des résidus de Limine
info "4. Suppression des fichiers et hooks restants de Limine..."
# Hooks pacman
rm -f /etc/pacman.d/hooks/99-omarchy-limine.hook
rm -f /etc/pacman.d/hooks/90-mkinitcpio-install.hook

# Configurations Limine
rm -f /etc/default/limine
rm -rf /etc/limine-entry-tool.d /etc/limine-entry-tool.conf /etc/limine-snapper-sync.conf /var/lib/limine
rm -f /etc/xdg/autostart/limine-*.desktop
rm -f /etc/boot/hooks/post.d/89-warn-missing-file-hashes

# Fichiers Limine dans /boot
rm -rf /boot/EFI/limine
rm -f /boot/limine.conf /boot/limine.sys /boot/limine*

# Nettoyage des entrées Limine dans les variables UEFI NVRAM
info "Nettoyage des entrées UEFI Limine dans la NVRAM..."
for bootnum in $(efibootmgr | grep -i limine | sed -E 's/^Boot([0-9A-Fa-f]{4})\*?.*/\1/'); do
    if [[ -n "$bootnum" ]]; then
        info "Suppression de l'entrée UEFI Limine Boot${bootnum}..."
        efibootmgr -b "$bootnum" -B || true
    fi
done
success "Résidus de Limine éliminés."

# 5. Configuration de mkinitcpio pour Omarchy
info "5. Configuration de mkinitcpio pour le noyau linux-omarchy..."
cat << 'EOF' > /etc/mkinitcpio.d/linux-omarchy.preset
# mkinitcpio preset file for the 'linux-omarchy' package

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux-omarchy"

PRESETS=('default' 'fallback')

#default_config="/etc/mkinitcpio.conf"
default_image="/boot/initramfs-linux-omarchy.img"

#fallback_config="/etc/mkinitcpio.conf"
fallback_image="/boot/initramfs-linux-omarchy-fallback.img"
fallback_options="-S autodetect"
EOF

# Copie du binaire du noyau s'il n'est pas déjà dans /boot
KERNEL_MODULE_DIR=$(ls -d /usr/lib/modules/*-omarchy | tail -n 1)
if [[ -f "${KERNEL_MODULE_DIR}/vmlinuz" ]]; then
    info "Installation du noyau ${KERNEL_MODULE_DIR}/vmlinuz vers /boot/vmlinuz-linux-omarchy..."
    cp -f "${KERNEL_MODULE_DIR}/vmlinuz" /boot/vmlinuz-linux-omarchy
fi

info "Génération des images initramfs avec mkinitcpio..."
mkinitcpio -p linux-omarchy
success "Initramfs généré avec succès."

# 6. Installation du thème Tartarus
info "6. Installation du thème Tartarus..."
mkdir -p /boot/grub/themes/tartarus
mkdir -p /usr/share/grub/themes/tartarus

cp -r "${THEME_SRC}/"* /boot/grub/themes/tartarus/
cp -r "${THEME_SRC}/"* /usr/share/grub/themes/tartarus/

# Ajout de l'icône pour Omarchy dans le thème si absente
if [[ -f /boot/grub/themes/tartarus/icons/arch.png ]] && [[ ! -f /boot/grub/themes/tartarus/icons/omarchy.png ]]; then
    cp /boot/grub/themes/tartarus/icons/arch.png /boot/grub/themes/tartarus/icons/omarchy.png
    cp /boot/grub/themes/tartarus/icons/arch.png /usr/share/grub/themes/tartarus/icons/omarchy.png
fi
success "Thème Tartarus installé."

# 7. Configuration de /etc/default/grub
info "7. Configuration de /etc/default/grub..."
cat << 'EOF' > /etc/default/grub
# GRUB configuration for Omarchy
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Omarchy"
GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=PARTUUID=f7286501-3dd3-4126-a6d9-8f97bae01333:root rootflags=subvol=@ zswap.enabled=0 resume=/dev/mapper/root resume_offset=1939191 initramfs_async=0 quiet splash loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0"
GRUB_CMDLINE_LINUX=""

# Modules de préchargement pour EFI, Btrfs et GPT
GRUB_PRELOAD_MODULES="part_gpt part_msdos fat btrfs"

# Paramètres d'affichage graphique pour le thème
GRUB_TERMINAL_INPUT="console"
GRUB_GFXMODE="auto"
GRUB_GFXPAYLOAD_LINUX="keep"

# Thème Tartarus
GRUB_THEME="/boot/grub/themes/tartarus/theme.txt"

# Activation d'os-prober pour détecter d'autres OS
GRUB_DISABLE_OS_PROBER="false"
GRUB_DISABLE_RECOVERY="false"
EOF
success "Configuration GRUB créée."

# 8. Installation de GRUB sur la partition EFI (/boot)
info "8. Installation de GRUB dans l'ESP UEFI..."
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
# Installer également en tant que binaire amovible fallback (/boot/EFI/BOOT/BOOTX64.EFI)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable --recheck
success "GRUB installé dans l'UEFI."

# 9. Génération du fichier de configuration grub.cfg
info "9. Génération du fichier /boot/grub/grub.cfg..."
grub-mkconfig -o /boot/grub/grub.cfg
success "Fichier grub.cfg généré."

# 10. Synchronisation avec le disque miroir NVMe (/dev/nvme0n1p1)
info "10. Synchronisation de la partition EFI avec le second disque (/dev/nvme0n1p1)..."
if [[ -b /dev/nvme0n1p1 ]]; then
    MNT_NVME_ESP=$(mktemp -d /mnt/nvme_esp_XXXXXX)
    mount /dev/nvme0n1p1 "$MNT_NVME_ESP" || true
    if mountpoint -q "$MNT_NVME_ESP"; then
        rsync -a --delete /boot/ "$MNT_NVME_ESP/"
        # Installer également GRUB amovible sur le disque NVMe
        grub-install --target=x86_64-efi --efi-directory="$MNT_NVME_ESP" --bootloader-id=GRUB --removable --recheck || true
        umount "$MNT_NVME_ESP"
        rmdir "$MNT_NVME_ESP"
        success "ESP synchronisée sur /dev/nvme0n1p1."
    else
        warn "Impossible de monter /dev/nvme0n1p1, étape ignorée."
        rmdir "$MNT_NVME_ESP"
    fi
fi

# 11. Vérifications finales de sécurité
info "11. Vérifications de sécurité..."
if [ ! -f /boot/vmlinuz-linux-omarchy ]; then
    error "ERREUR CRITIQUE : /boot/vmlinuz-linux-omarchy est absent !"
    exit 1
fi

if [ ! -f /boot/initramfs-linux-omarchy.img ]; then
    error "ERREUR CRITIQUE : /boot/initramfs-linux-omarchy.img est absent !"
    exit 1
fi

if [ ! -f /boot/grub/grub.cfg ]; then
    error "ERREUR CRITIQUE : /boot/grub/grub.cfg est absent !"
    exit 1
fi

echo -e "\n${GREEN}${BOLD}======================================================${NC}"
echo -e "${GREEN}${BOLD}   Migration terminée avec succès !                   ${NC}"
echo -e "${GREEN}${BOLD}   GRUB et le thème Tartarus sont opérationnels.      ${NC}"
echo -e "${GREEN}${BOLD}======================================================${NC}"
echo -e "\nEntrées de démarrage actuelles dans la NVRAM :"
efibootmgr
