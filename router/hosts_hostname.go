package main

import (
	"net"
	"os"

	"github.com/pkg/errors"
)

type HostsFetcherHostname struct{}

// FetchHosts implements HostsFetcher.
func (f *HostsFetcherHostname) FetchHosts() ([]HostsEntry, error) {
	localHostname, err := os.Hostname()
	if err != nil {
		return nil, errors.Wrapf(err, "failed to get local hostname")
	}
	return []HostsEntry{{
		Address: net.IPv4(10, 0, 0, 1),
		Hosts:   []string{localHostname},
	}}, nil
}
