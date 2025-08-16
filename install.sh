#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/kgla311/arch.dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

echo "==> pacman sync"
sudo pacman -Syu --noconfirm

echo "==> base packages"
sudo pacman -S --needed --noconfirm \
  git base-devel jq ripgrep fd fastfetch \
  hyprland hyprpaper hypridle hyprlock \
  waybar rofi wl-clipboard grim slurp swappy xdg-desktop-portal-hyprland \
  swaync kitty fish starship \
  nemo \
  pipewire pipewire-pulse wireplumber \
  qt6ct qt5ct qt6-wayland \
  python-pywal swww \
  cava \
  mesa libglvnd mesa-demos \
  sdl2 glew glu \
  noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd

# yay (AUR)
if ! command -v yay >/dev/null; then
  echo "==> installing yay"
  sudo pacman -S --needed --noconfirm go
  tmpdir="$(mktemp -d)"; git clone https://aur.archlinux.org/yay.git "$tmpdir"
  (cd "$tmpdir" && makepkg -si --noconfirm); rm -rf "$tmpdir"
fi

echo "==> AUR packages"
yay -S --needed --noconfirm \
  zafiro-icon-theme \
  bibata-cursor-theme-bin \
  orchis-theme \
  matugen-bin

echo "==> clone/update dotfiles"
if [[ -d "$DOTFILES_DIR/.git" ]]; then
  (cd "$DOTFILES_DIR" && git pull --ff-only)
else
  rm -rf "$DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
fi

echo "==> symlink ~/.config from repo"
mkdir -p "$HOME/.config"
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for src in "$DOTFILES_DIR/.config/"*; do
  name="$(basename "$src")"
  dst="$HOME/.config/$name"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "   backing up $dst -> $backup/$name"
    mv "$dst" "$backup/$name"
  else
    rm -f "$dst"
  fi
  ln -s "$src" "$dst"
done

echo "==> cursor/icons/gtk (user)"
mkdir -p "$HOME/.icons/default"
cat > "$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Inherits=Bibata-Modern-Ice
EOF

# GTK user settings (honored by most apps outside GNOME too)
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for g in 3.0 4.0; do
cat > "$HOME/.config/gtk-$g/settings.ini" <<'EOF'
[Settings]
gtk-theme-name=Orchis-Dark
gtk-icon-theme-name=Zafiro
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-font-name=JetBrainsMono Nerd Font 11
EOF
done

# Qt picks theme/icons via qt6ct/qt5ct; env switches it on
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/qt.conf" <<'EOF'
QT_QPA_PLATFORMTHEME=qt6ct
QT_STYLE_OVERRIDE=
XDG_CURRENT_DESKTOP=Hyprland
XDG_SESSION_DESKTOP=Hyprland
EOF

echo "==> done. relogin to apply env/cursor."
