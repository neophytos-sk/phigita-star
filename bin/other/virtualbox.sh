xterm -e /bin/bash -l -c "su - -c 'for m in vbox{drv,netadp,netflt}; do modprobe $m; done'"
for m in vbox{drv,netadp,netflt}; do modprobe $m; done
VirtualBox $1
