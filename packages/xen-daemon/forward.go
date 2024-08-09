package main

import (
	"io"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/pkg/errors"
)

const (
	FORWARD_PROTOCOL_TCP = "tcp"
	FORWARD_PROTOCOL_UDP = "udp"
)

var _ ForwardsFetcher = (*ForwardsFetcherHttp)(nil)

type ForwardsSource struct {
	Name     string
	Fetcher  ForwardsFetcher
	Interval time.Duration
}

type ForwardsFetcher interface {
	FetchForwards() ([]ForwardsEntry, error)
}

type ForwardsEntry struct {
	Protocol        string
	SourcePort      int
	Address         net.IP
	DestinationPort int
}

type ForwardsFetcherHttp struct {
	Url string
}

// FetchForwards implements ForwardsFetcher.
func (f *ForwardsFetcherHttp) FetchForwards() ([]ForwardsEntry, error) {
	response, err := http.Get(f.Url)
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to fetch %s", f.Url)
	}
	content, err := io.ReadAll(io.LimitReader(response.Body, 1024*1024))
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to read response body from %s", f.Url)
	}
	return ParseForwardsFile(string(content))
}

func ParseForwardsFile(content string) ([]ForwardsEntry, error) {
	forwards := []ForwardsEntry{}
	lines := strings.Split(content, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		fields := strings.Fields(line)
		if len(fields) != 4 {
			return nil, errors.Errorf("Invalid forward entry: %s", line)
		}

		protocol := strings.ToLower(fields[0])
		if protocol != FORWARD_PROTOCOL_TCP && protocol != FORWARD_PROTOCOL_UDP {
			return nil, errors.Errorf("Invalid protocol: %s", protocol)
		}

		sourcePort, err := parsePort(fields[1])
		if err != nil {
			return nil, errors.Wrapf(err, "Invalid source port: %s", fields[1])
		}

		addr := net.ParseIP(fields[2])
		if addr == nil {
			return nil, errors.Errorf("Invalid IP address: %s", fields[2])
		}

		destinationPort, err := parsePort(fields[3])
		if err != nil {
			return nil, errors.Wrapf(err, "Invalid destination port: %s", fields[3])
		}

		forwards = append(forwards, ForwardsEntry{
			Protocol:        protocol,
			SourcePort:      sourcePort,
			Address:         addr,
			DestinationPort: destinationPort,
		})
	}
	return forwards, nil
}

func parsePort(port string) (int, error) {
	if port == "*" {
		return 0, nil
	}
	v, err := strconv.Atoi(port)
	if err != nil {
		return 0, errors.Errorf("Invalid port: %s", port)
	}
	if v < 1 || v > 65535 {
		return 0, errors.Errorf("Invalid port: %s", port)
	}
	return v, nil
}
