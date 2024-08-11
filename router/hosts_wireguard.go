package main

import (
	"os"
)

type HostsFetcherWireguard struct{}

// FetchHosts implements HostsFetcher.
func (f *HostsFetcherWireguard) FetchHosts() ([]HostsEntry, error) {
	content, err := os.ReadFile("/run/router/wireguard-hosts")
	if err != nil {
		return nil, err
	}
	return ParseHostsFile(string(content))
}
