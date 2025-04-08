# MATE Desktop Setup for FreeBSD on Dell Inspiron 15-3210

This script automates the installation and configuration of the MATE desktop environment on FreeBSD, specifically tuned for the Dell Inspiron 15-3210 laptop. It includes proper graphics driver setup, touchpad support, and automatic X11 configuration using GhostBSD’s `xconfig`.

---

## ✅ Features

- Installs MATE desktop and LightDM display manager
- Sets up Intel graphics (i915kms) for optimal performance
- Enables Synaptics touchpad with tapping and scrolling
- Installs and runs `xconfig` to generate `xorg.conf`
- Enables required services: `dbus`, `hald`, `lightdm`
- Sets `~/.xinitrc` to start MATE session (for `startx` users)

---

## 💻 System Requirements

- FreeBSD (14.x)
- Dell Inspiron 15-3210 (or similar with Intel HD Graphics 3000/4000)
- Internet connection for installing packages and cloning GitHub repo

---

## 📦 Packages Installed

- `xorg`
- `mate`, `mate-utils`, `mate-terminal`
- `lightdm`, `lightdm-gtk-greeter`
- `drm-kmod` (for i915 graphics)
- `xf86-input-synaptics` (for touchpad)
- Git (to fetch `xconfig`)

---

## 🚀 Usage

### 1. Download the script

```sh
su
fetch -o install_mate_inspiron.sh https://github/ghostfixer/install_mate_inspiron.sh
chmod +x install_mate_inspiron.sh
```

> Replace the URL with the actual location if hosted online.

### 2. Run the script

```sh
./install_mate_inspiron.sh
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
