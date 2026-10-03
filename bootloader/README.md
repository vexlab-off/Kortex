# 🚀 Migration Bootloader : Limine vers GRUB (Thème Tartarus)

Ce dossier contient les outils nécessaires pour migrer un système **Omarchy** (initialement installé avec le chargeur d'amorçage **Limine**) vers **GRUB** en intégrant le thème graphique haute définition **Tartarus**.

---

## 📋 Prérequis et Prise en charge

- **Système** : Arch Linux / Omarchy démarré en mode **UEFI** (`/sys/firmware/efi`).
- **Partitionnement supporté** :
  - Standard EFI + ext4 / btrfs
  - Chiffrement complet **LUKS2** avec sous-volumes **Btrfs**
  - Disques NVMe et SATA

---

## 🛠️ Contenu du dossier

| Fichier / Dossier | Rôle |
|---|---|
| `switch_to_grub.sh` | Script d'automatisation de la migration, détection des disques et UUIDs LUKS, configuration de `/etc/default/grub` et regénération de `grub.cfg`. |
| `tartarus-grub/` | Fichiers graphiques, polices et assets du thème GRUB Tartarus. |
| `limine-dummy/` | Paquet dummy Arch Linux qui fournit virtuellement les dépendances Limine d'Omarchy pour éviter les blocages lors des mises à jour système (`pacman -Syu`). |

---

## ⚡ Exécution

```bash
sudo ./switch_to_grub.sh
```

Le script effectue automatiquement :
1. La vérification de l'environnement UEFI.
2. Le remplacement des paquets `limine` par `limine-dummy`.
3. L'installation de `grub`, `efibootmgr`, `os-prober` et `grub-btrfs`.
4. Le nettoyage complet des anciens fichiers et entrées NVRAM Limine.
5. La détection du chiffrement LUKS et l'ajout de `cryptdevice` dans `GRUB_CMDLINE_LINUX`.
6. L'installation du thème Tartarus et la génération de `grub.cfg`.
