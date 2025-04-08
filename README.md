# Desktop Setup for FreeBSD on Dell Inspiron 15-3210

This script automates the installation and configuration of a MATE or Xfce desktop environment on FreeBSD, specifically tuned for the Dell Inspiron 15-3210 laptop. It includes proper graphics driver setup, touchpad support, and automatic X11 configuration using GhostBSD’s `xconfig`.

---

## ✅ Features

- Prompts to install either **MATE** or **Xfce**
- Installs LightDM as the display manager
- Sets up Intel graphics (`i915kms`)
- Loads the graphics driver and updates loader configuration
- Enables Synaptics touchpad with tapping and scrolling
- Installs and runs GhostBSD’s `xconfig` to auto-generate `xorg.conf`
- Enables required services: `dbus`, `hald`, `lightdm`, `powerd`
- Creates ZFS boot environment for rollback (if supported)
- Creates a user (if not already present) and adds them to the `video` group
- Sets the correct `~/.xinitrc` for the selected desktop

---

## 💻 System Requirements

- FreeBSD (14.x)
- Dell Inspiron 15-3210 (or similar with Intel HD Graphics 3000/4000)
- Internet connection for installing packages and cloning GitHub repo

---

## 📦 Packages Installed

Common:
- `xorg`
- `lightdm`, `lightdm-gtk-greeter`
- `drm-kmod` (Intel graphics)
- `xf86-input-synaptics` (touchpad)
- `git` (to fetch `xconfig`)
- `noto-basic`
- `noto-emoji`

MATE-specific:
- `mate`, `mate-utils`, `mate-terminal`, `pluma`, `engrampa`, `eom`, `file-roller`, `atril`, `caja`, `galculator`

Xfce-specific:
- `xfce`, `xfce4-terminal`, `xfce4-goodies`, `thunar-archive-plugin`, `mousepad`, `galculator`

---

## 🚀 Usage

### 1. Download the script

```sh
su
fetch -o install_mate_inspiron.sh https://github/ghostfixer/install_desktop_inspiron.sh
chmod +x install_desktop_inspiron.sh
```

> Replace the URL with the actual location if hosted online.

### 2. Run the script

```sh
./install_desktop_inspiron.sh
```

### 3. Reboot

```sh
sudo reboot
```

MATE should start via LightDM. If using `startx`, log in via TTY and type:
```sh
startx
```

---

## 🛠️ Notes

- The script sets `kern.vty=vt` in `/boot/loader.conf` for graphical console support.
- `xconfig` from GhostBSD is used to auto-generate `/etc/X11/xorg.conf` based on hardware.
- For wireless support, you may need to install additional Wi-Fi firmware depending on your chipset.

---

## 📄 License

This project is open-source and released under the BSD 2-Clause License.
