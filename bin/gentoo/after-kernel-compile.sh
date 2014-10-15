#!/bin/sh

emerge xf86-input-synaptics xf86-input-keyboard xf86-input-mouse xf86-input-evdev
emerge xf86-video-intel xf86-video-nouveau
#emerge xf86-video-vmware xf86-video-intel xf86-video-nouveau
#emerge vmware-modules vmware-tools
emerge xorg-server xorg-drivers
emerge mesa
# USE="additions qt4 extensions" emerge virtualbox 
# emerge virtualbox-modules virtualbox-additions
emerge iwl6050-ucode

# NOW USING nouveau driver (open-source nvidia driver)
#emerge -av nvidia-drivers
#sh /web/files/laptop/thinkpad-w520/nvidia-xorg/NVIDIA-Linux-x86_64-304.64.run
#emerge -av bumblebee bbswitch virtualgl
#cp ~nkd/.bin/nvidia/init.d-vgl /etc/init.d/vgl
#cp ~nkd/.bin/nvidia/init.d-bumblebee /etc/init.d/bumblebee
