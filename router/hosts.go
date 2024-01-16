package main

import (
	"fmt"
	"net"
	"strings"
	"time"

	"github.com/pkg/errors"
)

var _ HostsFetcher = (*HostsFetcherHttp)(nil)
var _ HostsFetcher = (*HostsFetcherNetworkdInterface)(nil)

type HostsSource struct {
	Name     string
	Fetcher  HostsFetcher
	Interval time.Duration
}

type HostsFetcher interface {
	FetchHosts() ([]HostsEntry, error)
}

type HostsEntry struct {
	Address net.IP
	Hosts   []string
}

func (e HostsEntry) String() string {
	return fmt.Sprintf("%s %s", e.Address, strings.Join(e.Hosts, " "))
}

func ParseHostsFile(content string) ([]HostsEntry, error) {
	hosts := []HostsEntry{}
	lines := strings.Split(content, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}
		fields := strings.Fields(line)
		addr := net.ParseIP(fields[0])
		if addr == nil {
			return nil, errors.Errorf("Invalid IP address: %s", fields[0])
		}
		hosts = append(hosts, HostsEntry{
			Address: addr,
			Hosts:   fields[1:],
		})

	}
	return hosts, nil
}
