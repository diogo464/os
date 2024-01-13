#!/usr/bin/python3

import subprocess
import json

INTERFACE_LAN = "enp1s0"

output = subprocess.check_output(
    ["networkctl", "status", INTERFACE_LAN, "--json=short"]
).decode("utf-8")
status = json.loads(output)

for lease in status["DHCPServer"]["Leases"]:
    addr = lease["Address"]
    ipv4 = f"{addr[0]}.{addr[1]}.{addr[2]}.{addr[3]}"
    hostname = lease["Hostname"]
    print(f"{ipv4} {hostname}")

