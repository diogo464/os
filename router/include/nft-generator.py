#!/usr/bin/python3

import os

from typing import Tuple
from ipaddress import IPv4Address


MARKER_DNAT = "{{MARKER_DNAT}}"
MARKER_FORWARD_ACCEPT = "{{MARKER_FORWARD_ACCEPT}}"

PATH_TEMPLATE = os.environ.get("PATH_TEMPLATE", "/etc/router/router.nft.template")
PATH_FORWARD = os.environ.get("PATH_FORWARD", "/etc/router/forward")


def parse_forward_line(line: str) -> Tuple[str, int, IPv4Address, int]:
    """
    Parse a line from the forward file.
    Returns a tuple of (protocol, src_port, dst, dst_port)
    """
    components = line.strip().split()
    protocol = components[0]
    if protocol not in ["tcp", "udp"]:
        raise ValueError("Invalid protocol: {}".format(protocol))
    src_port = int(components[1])
    if src_port < 1 or src_port > 65535:
        raise ValueError("Invalid source port: {}".format(src_port))
    dst = IPv4Address(components[2])
    dst_port = int(components[3])
    if dst_port < 1 or dst_port > 65535:
        raise ValueError("Invalid destination port: {}".format(dst_port))
    return (protocol, src_port, dst, dst_port)


template = open(PATH_TEMPLATE, "r").read().strip()
forwards = []

for file in os.listdir("/etc/router/forward.d"):
    path = os.path.join("/etc/router/forward.d", file)
    with open(path, "r") as f:
        for line in f.read().strip().splitlines():
            forwards.append(line.strip())

dnat_lines = []
forward_accept_lines = []

for line in forwards:
    protocol, src_port, dst, dst_port = parse_forward_line(line)
    # 	tcp dport 80 dnat ip to 10.0.0.50:3000;
    dnat = f"{protocol} dport {src_port} dnat ip to {dst}:{dst_port};"
    accept = f"ip daddr {dst} {protocol} dport {dst_port} accept;"
    dnat_lines.append(dnat)
    forward_accept_lines.append(accept)

dnat_chunk = "\n\t\t".join(dnat_lines)
forward_accept_chunk = "\n\t\t".join(forward_accept_lines)

template = template.replace(MARKER_DNAT, dnat_chunk).replace(
    MARKER_FORWARD_ACCEPT, forward_accept_chunk
)
print(template)

