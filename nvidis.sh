#!/bin/bash

# Exit on error
set -e

echo "[+] Installing NVIDIA and VA-API related packages..."
sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings libva-mesa-driver libva-utils

echo "[+] Creating pacman hook to auto-regenerate initramfs on NVIDIA changes..."
sudo mkdir -p /etc/pacman.d/hooks
sudo tee /etc/pacman.d/hooks/nvidia.hook > /dev/null <<'EOF'
[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
Exec=/usr/bin/mkinitcpio -P
EOF

echo "[+] Blacklisting nouveau driver..."
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nvidia-nouveau.conf > /dev/null

echo "[+] Setting up X11 OutputClass for NVIDIA and Intel..."
sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf > /dev/null <<'EOF'
Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "yes"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF

echo "[+] Adding NVIDIA modules to mkinitcpio.conf..."
# Ensure the MODULES line is properly set in mkinitcpio.conf
sudo sed -i '/^MODULES=/c\MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)' /etc/mkinitcpio.conf

echo "[+] Creating .xinitrc to use NVIDIA GPU with xrandr..."
tee "$HOME/.xinitrc" > /dev/null <<'EOF'
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
EOF

echo "[+] Creating autostart entries for GNOME (GDM greeter and user session)..."
sudo tee /usr/share/gdm/greeter/autostart/optimus.desktop > /dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF

sudo tee /etc/xdg/autostart/optimus.desktop > /dev/null <<'EOF'
[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c "xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
EOF

echo "[+] (Optional) Enable VA-API support in Chromium-based browsers"
echo "# Uncomment the following lines to enable hardware acceleration for Chrome/Edge:"
echo "# --enable-features=VaapiVideoDecoder,VaapiVideoEncoder" > "$HOME/.config/chrome-flags.conf"
echo "# --enable-zero-copy" >> "$HOME/.config/chrome-flags.conf"
echo "# --disable-features=UseChromeOSDirectVideoDecoder" >> "$HOME/.config/chrome-flags.conf"

echo "[+] Regenerating initramfs with mkinitcpio..."
sudo mkinitcpio -P

echo "[✓] NVIDIA setup complete. Reboot to apply changes."

