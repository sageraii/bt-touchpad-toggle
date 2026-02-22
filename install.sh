#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check dependencies
for cmd in bluetoothctl gdbus gsettings; do
    command -v "$cmd" >/dev/null 2>&1 || error "'$cmd' not found. Please install it first."
done

# Check GNOME desktop
if [[ "${XDG_CURRENT_DESKTOP:-}" != *"GNOME"* ]] && ! gsettings list-schemas 2>/dev/null | grep -q "org.gnome.desktop.peripherals.touchpad"; then
    warn "GNOME desktop not detected. This tool is designed for GNOME."
    read -rp "Continue anyway? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || exit 0
fi

# Install script
install -Dm755 touchpad-bt-toggle.sh "$HOME/.local/bin/touchpad-bt-toggle.sh"
info "Installed script to ~/.local/bin/touchpad-bt-toggle.sh"

# Install service
install -Dm644 touchpad-bt-toggle.service "$HOME/.config/systemd/user/touchpad-bt-toggle.service"
info "Installed service to ~/.config/systemd/user/touchpad-bt-toggle.service"

# Enable and start service
systemctl --user daemon-reload
systemctl --user enable --now touchpad-bt-toggle.service
info "Service enabled and started."

echo ""
info "Installation complete!"
echo "  Check status: systemctl --user status touchpad-bt-toggle"
echo "  View logs:    journalctl --user -u touchpad-bt-toggle -f"
