#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }

# Stop and disable service
if systemctl --user is-active --quiet touchpad-bt-toggle.service 2>/dev/null; then
    systemctl --user stop touchpad-bt-toggle.service
    info "Service stopped."
fi

if systemctl --user is-enabled --quiet touchpad-bt-toggle.service 2>/dev/null; then
    systemctl --user disable touchpad-bt-toggle.service
    info "Service disabled."
fi

# Remove files
rm -f "$HOME/.local/bin/touchpad-bt-toggle.sh"
rm -f "$HOME/.config/systemd/user/touchpad-bt-toggle.service"
systemctl --user daemon-reload
info "Files removed."

# Restore touchpad
if command -v gsettings >/dev/null 2>&1; then
    gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
    info "Touchpad re-enabled."
fi

echo ""
info "Uninstall complete!"
