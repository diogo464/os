package main

import (
	_ "embed"
	"time"
)

var CONFIG_HOSTS_SOURCES = []HostsSource{
	{
		Name: "kubernetes operator",
		Fetcher: &HostsFetcherHttp{
			Url: "http://10.0.1.1/hosts",
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
			Url: "http://10.0.1.1/forward",
		},
		Interval: time.Second * 10,
	},
}
