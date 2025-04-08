#!/bin/sh

set -e

echo ">>> Updating system..."
sudo freebsd-update fetch install || true
sudo pkg update && sudo pkg upgrade -y

echo ">>> Installing MATE desktop and LightDM..."
sudo pkg install -y xorg mate mate-utils mate-terminal lightdm lightdm-gtk-greeter xf86-video-intel

echo ">>> Installing Intel graphics driver..."
sudo pkg install -y drm-kmod
sudo sysrc kld_list="/boot/modules/i915kms"

echo ">>> Configuring loader.conf for proper VT handling..."
echo 'kern.vty=vt' | sudo tee -a /boot/loader.conf

echo ">>> Installing touchpad driver (synaptics)..."
sudo pkg install -y xf86-input-synaptics
sudo mkdir -p /usr/local/etc/X11/xorg.conf.d
sudo tee /usr/local/etc/X11/xorg.conf.d/touchpad.conf <<EOF
Section "InputClass"
    Identifier "touchpad"
    Driver "synaptics"
    MatchIsTouchpad "on"
    Option "TapButton1" "1"
    Option "VertEdgeScroll" "on"
EndSection
EOF

echo ">>> Enabling essential services..."
sudo sysrc dbus_enable="YES"
sudo sysrc hald_enable="YES"
sudo sysrc lightdm_enable="YES"

echo ">>> Cloning and running xconfig from GhostBSD..."
git clone https://github.com/ghostbsd/xconfig.git
cd xconfig
chmod +x xconfig
sudo ./xconfig
cd ..
rm -rf xconfig

echo ">>> Creating ~/.xinitrc (for startx users)..."
echo "exec mate-session" > ~/.xinitrc

echo ">>> All done! You can now reboot."
echo "Use 'startx' or wait for LightDM to launch MATE."
