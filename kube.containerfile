FROM git.d464.sh/infra/os/base:latest

# https://devnonsense.com/posts/k3s-on-fedora-coreos-bare-metal/#create-the-iso

RUN curl https://github.com/k3s-io/k3s/releases/download/v1.28.4%2Bk3s2/k3s -L -o k3s && \
	chmod 0755 k3s && mkdir -p /usr/bin && mv k3s /usr/bin/k3s
	
COPY include/kubernetes.repo /etc/yum.repos.d 
RUN chown 0644 /etc/yum.repos.d/kubernetes.repo

COPY include/rancher-k3s-common.repo /etc/yum.repos.d
RUN chown 0644 /etc/yum.repos.d/rancher-k3s-common.repo

RUN rpm-ostree install --assumeyes --allow-inactive kubectl k3s-selinux

COPY	include/k3s-agent.sh \
		include/k3s-bootstrap.sh \
		include/k3s-config.sh \
		include/k3s-server.sh \
		include/k3s-setup.sh \
		include/k3s-token.sh \
		/usr/bin/
COPY include/k3s.service /etc/systemd/system/k3s.service
RUN systemctl enable k3s.service
