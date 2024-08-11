package main

import (
	"encoding/json"
	"fmt"
	"net"
	"os"
	"os/exec"
	"strings"

	"github.com/pkg/errors"
)

type HostsFetcherNetworkdInterface struct {
	Interface string
}

// FetchHosts implements HostsFetcher.
func (f *HostsFetcherNetworkdInterface) FetchHosts() ([]HostsEntry, error) {
	cmd := exec.Command("networkctl", "status", "--json=short", f.Interface)
	output, err := cmd.Output()
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to run %s", strings.Join(cmd.Args, " "))
	}
	if hosts, err := parseNetworkctlStatus(string(output)); err != nil {
		return nil, errors.Wrapf(err, "Failed to parse output of %s", strings.Join(cmd.Args, " "))
	} else {
		return hosts, nil
	}
}

func parseNetworkctlStatus(output string) ([]HostsEntry, error) {
	type NetworkctlStatus struct {
		DHCPServer struct {
			Leases []struct {
				Hostname string `json:"Hostname"`
				Address  []int  `json:"Address"`
			} `json:"Leases"`
		} `json:"DHCPServer"`
	}

	var status NetworkctlStatus
	if err := json.Unmarshal([]byte(output), &status); err != nil {
		return nil, err
	}

	hosts := []HostsEntry{}
	for _, lease := range status.DHCPServer.Leases {
		addr := net.ParseIP(fmt.Sprintf("%d.%d.%d.%d", lease.Address[0], lease.Address[1], lease.Address[2], lease.Address[3]))
		if addr == nil {
			return nil, errors.Errorf("Invalid IP address: %v", lease.Address)
		}
		if len(lease.Hostname) == 0 {
			continue
		}
		hosts = append(hosts, HostsEntry{
			Address: addr,
			Hosts:   []string{lease.Hostname, fmt.Sprintf("%v.local", lease.Hostname), fmt.Sprintf("%v.home", lease.Hostname), fmt.Sprintf("%v.lan", lease.Hostname)},
		})
	}

	localHostname, err := os.Hostname()
	if err != nil {
		return nil, errors.Wrapf(err, "failed to get local hostname")
	}
	hosts = append(hosts, HostsEntry{
		Address: net.IPv4(10, 0, 0, 1),
		Hosts:   []string{localHostname, fmt.Sprintf("%v.local", localHostname), fmt.Sprintf("%v.home", localHostname), fmt.Sprintf("%v.lan", localHostname)},
	})

	return hosts, nil
}
