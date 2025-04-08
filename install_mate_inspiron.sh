#!/bin/sh

set -e

error_exit() {
  echo "!!! ERROR: $1"
  exit 1
}

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  error_exit "This script must be run as root. Please use 'sudo' or switch to root with 'su -'."
fi

# Optional: create boot environment for rollback if ZFS is in use
if command -v bectl >/dev/null 2>&1; then
  echo ">>> Creating boot environment 'pre-desktop-setup'..."
  bectl create pre-desktop-setup || echo "Warning: Boot environment may already exist"
fi

echo ">>> Updating system..."
freebsd-update fetch install || true
pkg update || error_exit "pkg update failed"
pkg upgrade -y || error_exit "pkg upgrade failed"

# Prompt user to choose desktop environment
echo ">>> Choose desktop environment:"
echo "1) MATE"
echo "2) Xfce"
printf "Enter 1 or 2: "
read -r desktop_choice

case "$desktop_choice" in
  1)
    DESKTOP="MATE"
    DESKTOP_PKGS="mate mate-utils mate-terminal pluma engrampa eom file-roller atril caja galculator"
    XINIT_CMD="exec mate-session"
    ;;
  2)
    DESKTOP="Xfce"
    DESKTOP_PKGS="xfce xfce4-terminal xfce4-goodies thunar-archive-plugin mousepad galculator"
    XINIT_CMD="exec startxfce4"
    ;;
  *)
    error_exit "Invalid choice. Please run the script again and enter 1 or 2."
    ;;
esac

echo ">>> Installing $DESKTOP desktop and LightDM..."
pkg install -y xorg $DESKTOP_PKGS lightdm lightdm-gtk-greeter xf86-video-intel || \
  error_exit "Failed to install desktop components"

echo ">>> Installing Intel graphics driver..."
pkg install -y drm-kmod || error_exit "Failed to install drm-kmod"
sysrc kld_list="/boot/modules/i915kms" || error_exit "Failed to set kld_list"

echo ">>> Attempting to load i915kms driver..."
kldload /boot/modules/i915kms.ko || echo "Warning: Could not load i915kms now. A reboot may be required."

echo ">>> Configuring loader.conf for proper VT handling..."
echo 'kern.vty=vt' >> /boot/loader.conf || error_exit "Failed to write to /boot/loader.conf"

echo ">>> Installing touchpad driver (synaptics)..."
pkg install -y xf86-input-synaptics || error_exit "Failed to install synaptics driver"
mkdir -p /usr/local/etc/X11/xorg.conf.d || error_exit "Failed to create X11 config directory"
cat > /usr/local/etc/X11/xorg.conf.d/touchpad.conf <<EOF || error_exit "Failed to create touchpad config"
Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
    Option "TapButton1" "1"
    Option "VertEdgeScroll" "on"
EndSection
EOF

echo ">>> Enabling essential services..."
for service in dbus hald lightdm; do
  sysrc "${service}_enable=YES" || error_exit "Failed to enable ${service}"
done

echo ">>> Starting dbus and hald services..."
service dbus start || echo "Warning: Could not start dbus"
service hald start || echo "Warning: Could not start hald"

echo ">>> Enabling power management..."
sysrc powerd_enable="YES"
sysrc powerd_flags="-a hiadaptive -b adaptive"

echo ">>> Cloning and running xconfig from GhostBSD..."
if ! command -v git >/dev/null 2>&1; then
  error_exit "git not found. Please install git first."
fi

git clone https://github.com/ghostbsd/xconfig.git || error_exit "Failed to clone xconfig"
cd xconfig || error_exit "Failed to enter xconfig directory"
chmod +x xconfig
./xconfig || error_exit "xconfig execution failed"
cd ..
rm -rf xconfig || echo "Warning: Failed to remove xconfig directory"

# Prompt for user to add to the video group
printf "Enter the username to add to the 'video' group: "
read -r video_user

# Create user if not found
if ! id "$video_user" >/dev/null 2>&1; then
  echo ">>> User '$video_user' not found. Creating user..."
  pw useradd "$video_user" -m -s /bin/sh -G wheel,video || error_exit "User creation failed"
  passwd "$video_user" || error_exit "Setting password failed"
else
  if pw groupshow video | grep -q "\b$video_user\b"; then
    echo ">>> User '$video_user' is already in the 'video' group."
  else
    pw groupmod video -m "$video_user" || error_exit "Failed to add '$video_user' to video group"
    echo ">>> Added '$video_user' to the 'video' group."
  fi
fi

# Update .xinitrc for the specified user
user_home=$(getent passwd "$video_user" | cut -d: -f6)
if [ -d "$user_home" ]; then
  echo "$XINIT_CMD" > "$user_home/.xinitrc" || error_exit "Failed to write to $user_home/.xinitrc"
  chown "$video_user:$video_user" "$user_home/.xinitrc"
  echo ">>> .xinitrc updated for user '$video_user'."
else
  error_exit "Home directory for user '$video_user' not found."
fi

# Optional: better font rendering (commented out)
# echo ">>> Installing optional font packages (uncomment to enable)"
# pkg install -y noto-basic noto-emoji

echo ">>> All done! You can now reboot."
echo "Use 'startx' or wait for LightDM to launch $DESKTOP."
