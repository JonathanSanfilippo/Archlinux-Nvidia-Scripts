
# Archlinux NVIDIA Setup Script

This script provides a quick setup for configuring an Arch Linux system to use the NVIDIA GPU in "NVIDIA only" mode with Optimus support.

## ⚙️ Features

- Installs necessary NVIDIA drivers and dependencies.
- Sets up a hook to regenerate the initramfs when NVIDIA packages are installed, upgraded, or removed.
- Configures X11 to use NVIDIA and Intel GPUs via `xrandr`.
- Adds NVIDIA modules (`nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`) directly to the `mkinitcpio.conf`.
- Blacklists the `nouveau` driver to ensure proper NVIDIA GPU usage.
- Creates autostart entries for GNOME (GDM greeter and user session) to automatically set up the NVIDIA GPU at login.

## 🛠️ Prerequisites

- Arch Linux system with GDM and an NVIDIA Optimus laptop or desktop.
- Ensure you have `sudo` privileges.

## 📜 Script Overview

### Installation

To use the script, simply run it with root privileges:

```bash
git clone https://github.com/yourusername/archlinux-nvidia-scripts.git
cd archlinux-nvidia-scripts
chmod +x nvidia-setup.sh
./nvidia-setup.sh
```

This will:

1. **Install NVIDIA packages**:
    - `nvidia`, `nvidia-utils`, `nvidia-settings`, `libva-mesa-driver`, and `libva-utils`.
  
2. **Create the pacman hook**:
    - The script creates a hook in `/etc/pacman.d/hooks/nvidia.hook` to automatically regenerate the initramfs whenever NVIDIA packages are installed, upgraded, or removed.

3. **Blacklists the `nouveau` driver**:
    - The `nouveau` driver is blacklisted to ensure that the open-source driver doesn’t conflict with the proprietary NVIDIA driver.

4. **Set up X11 OutputClass for NVIDIA and Intel**:
    - The script configures X11 to use the Intel GPU for non-graphical applications and the NVIDIA GPU for graphical tasks.
  
5. **Add NVIDIA modules to `mkinitcpio.conf`**:
    - Directly adds the necessary NVIDIA modules (`nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`) to the `MODULES` line in `/etc/mkinitcpio.conf`.

6. **Create `xinitrc` for NVIDIA GPU switching**:
    - The script generates a `.xinitrc` file in the user's home directory, automatically setting up the NVIDIA GPU at startup.

7. **Create GNOME autostart entries**:
    - Adds entries to automatically switch the display provider to NVIDIA when logging into GNOME via GDM.

8. **Optional: Enable VA-API for Chromium-based browsers**:
    - Uncomment lines in `chrome-flags.conf` to enable hardware acceleration.

### Rebuilding Initramfs

The script will automatically run `mkinitcpio -P` to rebuild the initramfs after making changes to the kernel modules.

### Reboot

After the script finishes, **reboot your system** to apply all changes.

```bash
reboot
```

## 🔧 Troubleshooting

- **Blacklisting `nouveau` fails**:
    - Ensure that the `blacklist-nvidia-nouveau.conf` file is correctly placed in `/etc/modprobe.d/`.
  
- **X11 not detecting the NVIDIA GPU**:
    - Ensure the proper configuration is in `/etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf`.
  
- **Hardware acceleration in Chrome not working**:
    - Check that the `chrome-flags.conf` file is correctly updated for VA-API support.

## 📂 File Locations

- **NVIDIA Hook**: `/etc/pacman.d/hooks/nvidia.hook`
- **Blacklist nouveau**: `/etc/modprobe.d/blacklist-nvidia-nouveau.conf`
- **X11 Configuration**: `/etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf`
- **Autostart entries**:
  - `/usr/share/gdm/greeter/autostart/optimus.desktop`
  - `/etc/xdg/autostart/optimus.desktop`
- **xinitrc**: `$HOME/.xinitrc`
- **Chrome flags**: `$HOME/.config/chrome-flags.conf`
