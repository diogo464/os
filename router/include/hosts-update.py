#!/usr/bin/python3

import os

for file in os.listdir("/etc/router/hosts.d"):
    path = os.path.join("/etc/router/hosts.d", file)
    with open(path, "r") as f:
        for line in f:
            print(line.strip())
