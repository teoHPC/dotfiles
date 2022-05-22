#!/bin/bash

# ------------------------------
# Pre-Installation

# Update the system clock
timedatectl set-ntp true

# Use `fdisk /dev/sdx` to partition the disk
#
# /dev/sdx1 : partition for booting
# - size: 512M
# - type: EFI System
#
# /dev/sdx2 : Arch OS partition
# - size: remaining
# - type: Linux Filesystem

# Format the partitions
#
# mkfs.fat -F32 /dev/sdx1
# mkfs.ext4 /dev/sdx2

# Mount partitions:
#
# mount /dev/sdx2 /mnt
# mkdir /mnt/boot
# mount /dev/sdx1 /mnt/boot

# TODO: edit mirrorlist

# Install base packages
packages=(
  linux           # linux kernel and modules
  linux-firmware  # firmware files

  base         # bundle: bash, file, grep, gzip, iproute2, pacman, sed, shadow, systemd, tar, util-linux
  util-linux   # bundle: chsh, cal, column, fdisk, hwclock, kill, lsblk, lscpu, mkfs, mount, su, umount
  base-devel   # bundle: autoconf, automake, binutils, make, which, gcc, sudo, pkgconf

  grub        # boot loader
  efibootmgr  # EFI boot manager

  cronie  # time-based job scheduler

  #sddm                  # display manager
  sway                  # window manager
  xorg-server-xwayland  # wayland xorg support
  kanshi                # monitors setup manager
  swaylock              # screen locker
  swayidle              # desktop dimming manager
  wl-clipboard          # clipboard
  wofi                  # app launcher
  grim                  # screenshot utility
  swappy                # screenshot editting tool
  slurp                 # select region on screen
  mako libnotify        # notifications
  waybar                # bar
  #wev                   # debugging Wayland events
  xdg-desktop-portal-wlr # screen sharing
  wf-recorder            # screen recording

  lsof                  # list open files

  # terminal emulator
  #alacritty
  #konsole
  foot

  xdg-utils             # provides default applications (xdg-open, xdg-mime, ...)
  at                    # schedule commands
  hexyl                 # command line hex viewer

  zsh            # shell
  gvim           # editor
  neovim
  ninja          # alternative to make
  gdb            # debugger
  git            # version control management
  cmake          # build tool
  diff-so-fancy  # better diff
  clang          # compiler
  openmp         # clang's opnemp support

  # monitoring
  perf
  htop
  glances

  networkmanager  # network manager
  nethogs         # net top tool
  mtr             # traceroute alternative

  gnupg        # encryption and signing tool
  age
  pass         # password store
  #passage
  minisign
  lastpass-cli # LastPass CLI password store
  pwgen        # generate passwords from the command line

  # vpn
  networkmanager-openconnect
  networkmanager-openvpn
  networkmanager-vpnc

  openssh # ssh
  wget
  curl
  aria2
  youtube-dl
  newsboat
  github-cli

  # latex
  texlive-bin
  texlive-core
  texlive-science
  biber

  # fonts
  ttf-liberation
  ttf-font-awesome
  ttf-roboto
  powerline-fonts

  # qt
  qt5-wayland
  qt5ct

  # python
  python-black # formatting
  python-parse # the reverse of `format()`, like scanf() in `C`
  python-numpy
  python-scipy
  python-pandas
  python-matplotlib
  python-seaborn
  ipython
  jupyter

  # chat
  weechat
  weechat-matrix

  neomutt # email client
  notmuch # index and search mail
  w3m     # view HTML email
  msmtp   # SMTP client
  isync   # sync IMAP and Maildir mailboxes
  khal    # calendar and events

  # sound server & bluetooth
  pipewire-pulse
  pipewire-alsa
  bluez
  bluez-utils
  #pulseaudio-bluetooth

  pavucontrol                       # volume control
  light                             # brightness

  # printing
  cups
  foomatic-db-engine
  foomatic-db

  translate-shell  # language translation in the terminal

  borg          # backup
  syncthing     # sync continuously
  rclone        # sync to cloud storage
  rsync         # sync to remote

  neofetch                    # system info
  onefetch                    # git repo info

  zip unzip unrar             # archives
  jq                          # json
  fzf the_silver_searcher fd  # search
  ncdu                        # disk: du alternative
  tree                        # files & folders
  pacman-contrib pacgraph     # arch
  asp                         # utility to retrieve PKGBUILD files
  man man-db man-pages        # man pages
  tldr                        # alternative to man pages
  playerctl                   # media player controller

  # pdf
  pdf2svg               # pdf to svg converter
  zathura-pdf-mupdf     # pdf viewer
  xournalpp             # pdf editor
  pdfarranger           # pdf merge/split/arrange
  #okular

  # browser
  chromium
  #firefox
  #qutebrowser

  # image viewer
  imv
  #gwenview
  #feh

  nm-connection-editor  # network manager GUI
  keepassxc             # password manager
  vlc                   # media player
  thunderbird           # mail client
  libreoffice-still     # office suite
  inkscape              # vector graphics editor
  gimp                  # raster graphics editor

  # no longer used: texstudio dolphin rofi
)
#pacman --noconfirm --needed -S  ${packages[@]}
pacstrap /mnt ${packages[@]}

# Generate the fstab file
genfstab -U /mnt >> /mnt/etc/fstab



# ------------------------------
# Post install

# Change root
arch-chroot /mnt

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
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg



# Set pacman's Color option
sed -i '/Color/s/^#//g' /etc/pacman.conf

# Services
systemctl enable NetworkManager.service \
                 bluetooth.service \
                 org.cups.cupsd.service \
                 atd.service \
                 syncthing@teonnik.service \
                 borg-backup.timer \
                 cronie.service
#                sddm.service

# Root password
passwd

# Add a user
useradd -m -a -G wheel,video -s /usr/bin/zsh teonnik
passwd teonnik
# TODO: edit /etc/sudoers to allow for the wheel group

# AUR package manager
git clone https://aur.archlinux.org/yay.git
(cd yay; makepkg -si)

# AUR packages
aur_pkgs=(
  skypeforlinux-stable-bin
  #mendeleydesktop
  slack-desktop
  #zoom
  direnv
  gcalcli
  ripgrep-all
  navi-bin
  #tuir fork of rtv
  #procs-bin       # ps replacement
  #stdman
  #rusty-man
  pandoc-bin
  wlsunset   # blue light filter for night reading
  vcal       # view .ics and calendar files
  swayimg    # image viewer
  libtree
)
yay --noconfirm --needed -S ${aur_pkgs[@]}




# ------------------------------
# Local install

# Create local folders
mkdir -p ~/code ~/build ~/downloads ~/bin #~/install

# spack
git clone https://github.com/spack/spack.git ~/code/spack

# dotfiles
git clone --bare https://github.com/teonnik/dotfiles.git ~/code/dots
git --git-dir=${HOME}/code/dots status.showUntrackedFiles no
git --git-dir=${HOME}/code/dots --work-tree=${HOME} checkout -f

# Add-ons: LastPass, Bypass Paywalls, Ublock Origin

# ssh keys
ssh-keygen -t ed25519 -C "teodor.nikolov22@gmail.com"

# neovim
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qall
curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/keymap/bulgarian-phonetic.vim --create-dirs http://www.math.bas.bg/bantchev/vim/bulgarian-phonetic.vim

# make zsh default shell : FIXME: doesn't work ??
#chsh -s $(which zsh)
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}"/zsh

# install powerlevel10k: `p10k configure`
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${HOME}/code/powerlevel10k

# install zsh autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${HOME}/code/zsh-autosuggestions
