#!/usr/bin/python3

import urllib.request

OPERATOR_IP = "10.0.2.1"
HOSTS_URL = f"http://{OPERATOR_IP}/hosts"
FORWARD_URL = f"http://{OPERATOR_IP}/forward"
PATH_HOSTS = "/etc/router/hosts.d/kubernetes"
PATH_FORWARD = "/etc/router/forward.d/kubernetes"

try:
    hosts = urllib.request.urlopen(HOSTS_URL).read().decode("utf-8").strip()
    if hosts != open(PATH_HOSTS, "r").read().strip():
        print("Updating hosts...")
        with open(PATH_HOSTS, "w") as f:
            f.write(hosts)
except Exception as e:
    print(f"Failed to fetch hosts: {e}")


try:
    forward = urllib.request.urlopen(FORWARD_URL).read().decode("utf-8").strip()
    if forward != open(PATH_FORWARD, "r").read().strip():
        print("Updating forward...")
        with open(PATH_FORWARD, "w") as f:
            f.write(forward)
except Exception as e:
    print(f"Failed to fetch forward: {e}")

