FROM git.d464.sh/infra/os/base:latest

RUN rpm-ostree install neovim htop tcpdump systemd-networkd tmux wpa_supplicant python
RUN curl https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz -L -o coredns.tgz && \
	tar -xf coredns.tgz && rm coredns.tgz && chmod 0755 coredns && mv coredns /usr/bin/

COPY include/router/10-upstream.network /etc/systemd/network/
COPY include/router/20-lan.network /etc/systemd/network/
COPY include/router/coredns.service /etc/systemd/system/
COPY include/router/nft-generator.service /etc/systemd/system/
COPY include/router/nft-generator.path /etc/systemd/system/
COPY include/router/networkctl-hosts.service /etc/systemd/system/
COPY include/router/networkctl-hosts.timer /etc/systemd/system/
COPY include/router/hosts-update.service /etc/systemd/system/
COPY include/router/hosts-update.path /etc/systemd/system/
COPY include/router/kubernetes-fetch.service /etc/systemd/system/
COPY include/router/kubernetes-fetch.timer /etc/systemd/system/

COPY include/router/nft-generator.py /usr/bin/
COPY include/router/networkctl-hosts.py /usr/bin/
COPY include/router/hosts-update.py /usr/bin/
COPY include/router/kubernetes-fetch.py /usr/bin/

RUN mkdir -p /etc/router /etc/router/hosts.d/ /etc/router/forward.d/
COPY include/router/router.nft.template /etc/router/
COPY include/router/Corefile /etc/router/

RUN systemctl disable NetworkManager
RUN systemctl enable systemd-networkd \
	coredns \
	nft-generator.service nft-generator.path \
	networkctl-hosts.timer \
	hosts-update.path \
	kubernetes-fetch.timer

RUN ostree container commit
