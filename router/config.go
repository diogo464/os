package main

import (
	_ "embed"
	"time"
)

var (
	//go:embed config/10-upstream.network
	CONFIG_NETWORK_FILE_UPSTREAM string
	//go:embed config/20-lan.network
	CONFIG_NETWORK_FILE_LAN string
)

var CONFIG_SYSTEMD_NETWORKD = []SystemdNetworkdConfig{
	{
		Content:  CONFIG_NETWORK_FILE_UPSTREAM,
		Filename: "10-upstream.network",
	},
	{
		Content:  CONFIG_NETWORK_FILE_LAN,
		Filename: "20-lan.network",
	},
}

var CONFIG_HOSTS_SOURCES = []HostsSource{
	{
		Name: "kubernetes operator",
		Fetcher: &HostsFetcherHttp{
			Url: "http://10.0.2.1/hosts",
		},
		Interval: time.Second * 10,
	},
	{
		Name: "networkd lan interface",
		Fetcher: &HostsFetcherNetworkdInterface{
			Interface: "enp1s0",
		},
		Interval: time.Second * 10,
	},
}

var FORWARD_SOURCES = []ForwardsSource{
	{
		Name: "kubernetes operator",
		Fetcher: &ForwardsFetcherHttp{
			Url: "http://10.0.2.1/forward",
		},
		Interval: time.Second * 10,
	},
}
