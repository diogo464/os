package main

import (
	"fmt"
	"testing"
)

const NETWORKD_STATUS_OUTPUT = `
{
  "Index": 2,
  "Name": "enp1s0",
  "Type": "ether",
  "Driver": "r8169",
  "Flags": 69699,
  "FlagsString": "up,broadcast,running,multicast,lower-up",
  "KernelOperationalState": 6,
  "KernelOperationalStateString": "up",
  "MTU": 1500,
  "MinimumMTU": 68,
  "MaximumMTU": 9194,
  "HardwareAddress": [
    172,
    21,
    162,
    159,
    16,
    131
  ],
  "PermanentHardwareAddress": [
    172,
    21,
    162,
    159,
    16,
    131
  ],
  "BroadcastAddress": [
    255,
    255,
    255,
    255,
    255,
    255
  ],
  "IPv6LinkLocalAddress": [
    254,
    128,
    0,
    0,
    0,
    0,
    0,
    0,
    174,
    21,
    162,
    255,
    254,
    159,
    16,
    131
  ],
  "AdministrativeState": "configured",
  "OperationalState": "routable",
  "CarrierState": "carrier",
  "AddressState": "routable",
  "IPv4AddressState": "routable",
  "IPv6AddressState": "degraded",
  "OnlineState": "online",
  "NetworkFile": "/etc/systemd/network/20-lan.network",
  "NetworkFileDropins": [],
  "RequiredForOnline": true,
  "RequiredOperationalStateForOnline": [
    "degraded",
    "routable"
  ],
  "RequiredFamilyForOnline": "any",
  "ActivationPolicy": "up",
  "LinkFile": "/usr/lib/systemd/network/99-default.link",
  "Path": "pci-0000:01:00.0",
  "Vendor": "Realtek Semiconductor Co., Ltd.",
  "Model": "RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller (TP-Link TG-3468 v4.0 Gigabit PCI Express Network Adapter)",
  "DNSSettings": [
    {
      "LLMNR": "yes",
      "ConfigSource": "static"
    },
    {
      "MDNS": "no",
      "ConfigSource": "static"
    }
  ],
  "Addresses": [
    {
      "Family": 10,
      "Address": [
        254,
        128,
        0,
        0,
        0,
        0,
        0,
        0,
        174,
        21,
        162,
        255,
        254,
        159,
        16,
        131
      ],
      "PrefixLength": 64,
      "Scope": 253,
      "ScopeString": "link",
      "Flags": 128,
      "FlagsString": "permanent",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 2,
      "Address": [
        10,
        0,
        0,
        1
      ],
      "Broadcast": [
        10,
        0,
        255,
        255
      ],
      "PrefixLength": 16,
      "Scope": 0,
      "ScopeString": "global",
      "Flags": 128,
      "FlagsString": "permanent",
      "ConfigSource": "static",
      "ConfigState": "configured"
    }
  ],
  "Routes": [
    {
      "Family": 2,
      "Destination": [
        10,
        0,
        0,
        1
      ],
      "DestinationPrefixLength": 32,
      "PreferredSource": [
        10,
        0,
        0,
        1
      ],
      "Scope": 254,
      "ScopeString": "host",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 2,
      "TypeString": "local",
      "Priority": 0,
      "Table": 255,
      "TableString": "local",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 2,
      "Destination": [
        10,
        0,
        0,
        0
      ],
      "DestinationPrefixLength": 16,
      "PreferredSource": [
        10,
        0,
        0,
        1
      ],
      "Scope": 253,
      "ScopeString": "link",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 1,
      "TypeString": "unicast",
      "Priority": 0,
      "Table": 254,
      "TableString": "main",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 10,
      "Destination": [
        254,
        128,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ],
      "DestinationPrefixLength": 64,
      "Scope": 0,
      "ScopeString": "global",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 1,
      "TypeString": "unicast",
      "Priority": 256,
      "Table": 254,
      "TableString": "main",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 10,
      "Destination": [
        255,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ],
      "DestinationPrefixLength": 8,
      "Scope": 0,
      "ScopeString": "global",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 5,
      "TypeString": "multicast",
      "Priority": 256,
      "Table": 255,
      "TableString": "local",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 2,
      "Destination": [
        10,
        0,
        255,
        255
      ],
      "DestinationPrefixLength": 32,
      "PreferredSource": [
        10,
        0,
        0,
        1
      ],
      "Scope": 253,
      "ScopeString": "link",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 3,
      "TypeString": "broadcast",
      "Priority": 0,
      "Table": 255,
      "TableString": "local",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 10,
      "Destination": [
        254,
        128,
        0,
        0,
        0,
        0,
        0,
        0,
        174,
        21,
        162,
        255,
        254,
        159,
        16,
        131
      ],
      "DestinationPrefixLength": 128,
      "Scope": 0,
      "ScopeString": "global",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 2,
      "TypeString": "local",
      "Priority": 0,
      "Table": 255,
      "TableString": "local",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    },
    {
      "Family": 10,
      "Destination": [
        254,
        128,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ],
      "DestinationPrefixLength": 128,
      "Scope": 0,
      "ScopeString": "global",
      "Protocol": 2,
      "ProtocolString": "kernel",
      "Type": 4,
      "TypeString": "anycast",
      "Priority": 0,
      "Table": 255,
      "TableString": "local",
      "Preference": 0,
      "Flags": 0,
      "FlagsString": "",
      "ConfigSource": "foreign",
      "ConfigState": "configured"
    }
  ],
  "DHCPServer": {
    "PoolOffset": 50,
    "PoolSize": 150,
    "Leases": [
      {
        "ClientId": [
          1,
          184,
          39,
          235,
          157,
          107,
          248
        ],
        "Address": [
          10,
          0,
          0,
          50
        ],
        "Hostname": "raspberrypi",
        "ExpirationUSec": 322562586
      }
    ]
  }
}
`

func TestHostsNetworkdParse(t *testing.T) {
	hosts, err := parseNetworkctlStatus(NETWORKD_STATUS_OUTPUT)
	if err != nil {
		t.Fatal(err)
	}
	if len(hosts) != 1 {
		fmt.Println(hosts)
		t.Fatalf("Expected 4 host, got %d", len(hosts))
	}

	host := hosts[0]
	if host.Address.String() != "10.0.0.50" {
		t.Fatalf("Invalid host address: %s", host.Address)
	}
	if len(host.Hosts) != 4 {
		t.Fatalf("Expected 1 host name, got %d", len(host.Hosts))
	}
	if host.Hosts[0] != "raspberrypi" {
		t.Fatalf("Invalid host name: %s", host.Hosts[0])
	}
}
