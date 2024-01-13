FROM quay.io/fedora/fedora-coreos:stable
RUN systemctl disable zincati
RUN rpm-ostree install pciutils usbutils tmux
