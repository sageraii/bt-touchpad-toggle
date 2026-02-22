#!/bin/bash

is_any_mouse_connected() {
    while IFS= read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        if echo "$info" | grep -q "Icon: input-mouse" && echo "$info" | grep -q "Connected: yes"; then
            return 0
        fi
    done < <(bluetoothctl devices)
    return 1
}

toggle_touchpad() {
    if is_any_mouse_connected; then
        gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled
    else
        gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled
    fi
}

# Set initial state
toggle_touchpad

# Monitor Bluetooth property changes via gdbus
gdbus monitor --system --dest org.bluez 2>/dev/null | while IFS= read -r line; do
    if echo "$line" | grep -q "Connected"; then
        sleep 1
        toggle_touchpad
    fi
done
