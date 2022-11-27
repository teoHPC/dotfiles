#!/bin/bash

# Guide: https://wiki.archlinux.org/title/Installation_guide

# Burn live ISO to USB
#
dd bs=4M if=<path/to/archlinux-version-x86_64.iso> of=</dev/sdx> conv=fsync oflag=direct status=progress

# 0. Remove annoying speaker (if beeping) : https://wiki.archlinux.org/title/PC_speaker
#
rmmod pcspkr

# 1. Connect to WiFi : https://wiki.archlinux.org/title/Iwd#iwctl
# 
iwctl
[iwd] device list
[iwd] station <device_name> get_networks
[iwd] station <device_name> connect <network_name>

# 2. Update the system clock
#
timedatectl set-ntp true

# 3. List and partition disks
#
# Example layout:
#
# /dev/sdx1 : partition for booting
# - size: 512M
# - type: EFI System
#
# /dev/sdx2 : Arch OS partition
# - size: remaining
# - type: Linux Filesystem
#
fdisk -l /dev/sdx
fdisk /dev/sdx

# 4. Format the partitions
#
mkfs.fat -F32 /dev/sdx1
mkfs.ext4 /dev/sdx2

# 5. Mount partitions:
#
mount /dev/sdx2 /mnt
mount --mkdir /dev/sdx1 /mnt/boot

# Edit pacman's mirrorlist : /etc/pacman.d/mirrorlist

# Install essential packages
#
pacstrap -K /mnt base linux linux-firmware

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# Change root
arch-chroot /mnt

# Install all my pacman packages: ~/.config/arch/my_packages.txt
wget -O my_packages.txt pastebin.com/<link> 
pacman -Syu $(sed 's:#.*$::g' my_packages.txt | tr '\n' ' ' | tr -s ' ')

# Time zone
ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime
hwclock --systohc

# Localization
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Network
echo "teonnik" >> /etc/hostname
echo "127.0.1.1 teonnik.localdomain teonnik" >> /etc/hosts

# Bootloader
#
# Note: make sure to `arch-chroot` first!
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Set pacman's Color option
sed -i '/Color/s/^#//g' /etc/pacman.conf

# Set the root password
passwd

# Add a user
useradd -m -a -G wheel,video -s /usr/bin/zsh teonnik
passwd teonnik

# Edit /etc/sudoers to allow for the wheel group
visudo /etc/sudoers

# Services
systemctl enable NetworkManager.service \
                 bluetooth.service \
                 cups.service \
                 atd.service
                 #borg-backup.timer

systemctl --user enable xdg-desktop-portal.service \
                        syncthing.service
                        #pipewire-pulse.service ??

# AUR package manager
git clone https://aur.archlinux.org/yay.git
(cd yay; makepkg -si)

# Install all my AUR packages: ~/config/arch/my_aur_packages.txt
wget -O my_aur_packages.txt pastebin.com/<link> 
yay -Syu $(sed 's:#.*$::g' my_aur_packages.txt | tr '\n' ' ' | tr -s ' ')

# ------------------------------
# Local install

# Create local folders
mkdir -p ~/code ~/build ~/downloads ~/bin

# spack
git clone https://github.com/spack/spack.git ~/code/spack

# dotfiles in $HOME directory
git init
git remote add origin git@github.com:teonnik/dotfiles.git
git config status.showUntrackedFiles no
git fetch
git checkout -f master

# ssh keys
ssh-keygen -t ed25519 -C "teodor.nikolov22@gmail.com"

# neovim
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/keymap/bulgarian-phonetic.vim --create-dirs http://www.math.bas.bg/bantchev/vim/bulgarian-phonetic.vim

# zsh config dirs
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"/zsh

# install powerlevel10k: `p10k configure`
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/code/powerlevel10k

# install zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/code/zsh-autosuggestions

# TODO: chromium extensions - uBlock Origin, LastPass, BypassPaywalls, PrivacyBadger, Cookie AutoDelete
