# os

This repo contains the different coreos variants that I use.

## base
This image just provides some basic packages and is not meant to be deployed directly.

## kube
This image includes k3s and other kubernetes binaries.
It is meant to be used as kubernetes node or as the base for another images that uses kubernetes.

The main way to configure this image once its booted up is using the following scripts(they contain comments with usage):
`k3s-setup.sh`: setups up k3s on this node.
`k3s-token.sh`: outputs k3s token to stdout.
`k3s-killall.sh`: stops k3s.
`k3s-config.sh`: outputs a kubectl config to stdout.

## builder
This image contains the `act_runner` for gitea actions.
To setup the image after booting from it just ssh into the core user and run:
```
act_runner register # follow the prompts
systemctl --user enable --now act_runner
loginctl enable-linger core
```

## nas
This image builds on top of `kube` and adds zfs and a containerized gitea installation.
Gitea is run this way to avoid bootstraping problems with the kubernetes cluster.
Only one machine is meant to run this image and it should be the kubernetes cluster leader.

The main way to interact with this image is to just ssh and use the `zfs` cli.

## router
This image is meant to be deployed on the router machine.
It takes care of setting up network interfaces, a basic firewall, dns and TODO wireguard.

This machine is configured mainly using 2 files.

`/etc/router/hosts.d/*`
```
# this is just your typical hosts file
127.0.0.1 localhost
```
Any file under this directory will be used to by the dns server to resolve domain names.
Currently this directory is populated with the files:
```
hosts.d/kubernetes          -> fetched from kubernetes operator web api
hosts.d/networkctl          -> fetched from networkctl to resolve hostnames from the dhcp leases
```

`/etc/router/forward.d/*`
```
tcp 80 10.0.2.3 80
udp 6881 10.0.2.3 6881
```
The files in this directory are just plaintext with a simple format as can be seen above.
Each line contains three fields, seperated by spaces:
+ `protocol`: this can be `tcp` or `udp`
+ `external_port`: the port used to connect from the outside
+ `address`: the ipv4 address to forward to
+ `internal_port`: the port to forward to on `address`
Currently this directory is populated with the files:
```
forward.d/kubernetes        -> fethed from kubernetes operator web api
```
