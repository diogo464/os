FROM git.d464.sh/infra/os/base:latest

# https://devnonsense.com/posts/k3s-on-fedora-coreos-bare-metal/#create-the-iso

RUN curl https://github.com/k3s-io/k3s/releases/download/v1.28.4%2Bk3s2/k3s -L -o k3s && \
	chmod 0755 k3s && mkdir -p /var/usr/local/bin && mv k3s /var/usr/local/bin/k3s
	
COPY include/kubernetes.repo /etc/yum.repos.d 
RUN chown 0644 /etc/yum.repos.d/kubernetes.repo

COPY include/rancher-k3s-common.repo /etc/yum.repos.d
RUN chown 0644 /etc/yum.repos.d/rancher-k3s-common.repo

RUN rpm-ostree install --assumeyes --allow-inactive kubectl k3s-selinux

#- name: "k3s.service"
#  enabled: true
#  contents: |
#    [Unit]
#    Description=Run K3s
#    Wants=network-online.target
#    After=network-online.target

#    [Service]
#    Type=notify
#    EnvironmentFile=-/etc/default/%N
#    EnvironmentFile=-/etc/sysconfig/%N
#    EnvironmentFile=-/etc/systemd/system/%N.env
#    KillMode=process
#    Delegate=yes
#    LimitNOFILE=1048576
#    LimitNPROC=infinity
#    LimitCORE=infinity
#    TasksMax=infinity
#    TimeoutStartSec=0
#    Restart=always
#    RestartSec=5s
#    ExecStartPre=-/sbin/modprobe br_netfilter
#    ExecStartPre=-/sbin/modprobe overlay
#    ExecStart=/usr/local/bin/k3s server

#    [Install]
#    WantedBy=multi-user.target  
