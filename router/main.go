package main

import (
	_ "embed"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/pkg/errors"
)

type SystemdNetworkdConfig struct {
	Content  string
	Filename string
}

const (
	ROUTER_COREFILE_PATH             = "/etc/Corefile"
	ROUTER_HOSTS_FILE_OUTPUT         = "/run/router/hosts"
	ROUTER_NFT_MARKER_DNAT           = "{{MARKER_DNAT}}"
	ROUTER_NFT_MARKER_FORWARD_ACCEPT = "{{MARKER_FORWARD_ACCEPT}}"
)

var (
	//go:embed config/router.nft.template
	ROUTER_NFT_TEMPLATE string
)

func main() {
	// systemd-networkd configuration
	log.Println("Clearing systemd-networkd network configurations...")
	if err := ensureEmptyDirectory("/etc/systemd/network"); err != nil {
		log.Fatal(err)
	}
	log.Println("Copying systemd-networkd network configurations...")
	for _, config := range CONFIG_SYSTEMD_NETWORKD {
		configPath := "/etc/systemd/network/" + config.Filename
		if err := os.WriteFile(configPath, []byte(config.Content), 0644); err != nil {
			log.Fatalf("Failed to write %s: %v", configPath, err)
		}
	}
	log.Println("Restarting systemd-networkd...")
	if err := runCommand("systemctl", "restart", "systemd-networkd"); err != nil {
		log.Fatalf("Failed to restart systemd-networkd: %v", err)
	}

	// coredns configuration
	log.Println("Replacing Corefile...")
	if err := os.WriteFile(ROUTER_COREFILE_PATH, []byte(CONFIG_COREFILE), 0644); err != nil {
		log.Fatalf("Failed to write %s: %v", ROUTER_COREFILE_PATH, err)
	}
	log.Println("Restarting coredns...")
	if err := runCommand("systemctl", "restart", "coredns"); err != nil {
		log.Fatalf("Failed to restart coredns: %v", err)
	}

	go func() {
		err := hostsLoop()
		log.Fatalf("hosts loop exited: %v", err)
	}()

	go func() {
		err := forwardsLoop()
		log.Fatalf("forwards loop exited: %v", err)
	}()

	select {}
}

func hostsLoop() error {
	type sourceFetchResult struct {
		index   int
		entries []HostsEntry
	}

	prevFileContent := ""
	entries := make([][]HostsEntry, len(CONFIG_HOSTS_SOURCES))
	resultsChan := make(chan sourceFetchResult)

	for i, source := range CONFIG_HOSTS_SOURCES {
		go func(i int, s HostsSource, c chan sourceFetchResult) {
			for {
				entries, err := s.Fetcher.FetchHosts()
				if err != nil {
					log.Printf("Failed to fetch hosts from %s: %v", s.Name, err)
					time.Sleep(time.Second * 10)
					continue
				}
				c <- sourceFetchResult{
					index:   i,
					entries: entries,
				}
				time.Sleep(s.Interval)
			}
		}(i, source, resultsChan)
	}

	for result := range resultsChan {
		entries[result.index] = result.entries

		content := ""
		for _, entryArr := range entries {
			for _, entry := range entryArr {
				content += entry.String() + "\n"
			}
		}
		if content == prevFileContent {
			continue
		}

		log.Printf("Updated hosts file:\n%s", content)
		prevFileContent = content
		if err := os.WriteFile(ROUTER_HOSTS_FILE_OUTPUT, []byte(content), 0644); err != nil {
			return errors.Wrapf(err, "Failed to write %s", ROUTER_HOSTS_FILE_OUTPUT)
		}
	}

	return fmt.Errorf("hosts loop exited")
}

func forwardsLoop() error {
	type sourceFetchResult struct {
		index   int
		entries []ForwardsEntry
	}
	entries := make([][]ForwardsEntry, len(FORWARD_SOURCES))
	resultsChan := make(chan sourceFetchResult)

	for i, source := range FORWARD_SOURCES {
		go func(i int, s ForwardsSource, c chan sourceFetchResult) {
			for {
				entries, err := s.Fetcher.FetchForwards()
				if err != nil {
					log.Printf("Failed to fetch forwards from %s: %v", s.Name, err)
					time.Sleep(time.Second * 10)
					continue
				}
				c <- sourceFetchResult{
					index:   i,
					entries: entries,
				}
				time.Sleep(s.Interval)
			}
		}(i, source, resultsChan)
	}

	previousContent := ""
	for result := range resultsChan {
		entries[result.index] = result.entries
		collapsedEntries := []ForwardsEntry{}

		for _, entryArr := range entries {
			for _, entry := range entryArr {
				collapsedEntries = append(collapsedEntries, entry)
			}
		}

		content := renderNftTemplate(ROUTER_NFT_TEMPLATE, collapsedEntries)
		if content == previousContent {
			continue
		}

		cmd := exec.Command("nft", "-f", "-")
		cmd.Stdin = strings.NewReader(content)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return errors.Wrapf(err, "Failed to run nft -f -")
		}
	}

	return fmt.Errorf("forwards loop exited")
}

func ensureEmptyDirectory(path string) error {
	if err := os.MkdirAll(path, 0755); err != nil {
		return errors.Wrapf(err, "failed to create directory %s", path)
	}
	entries, err := os.ReadDir(path)
	if err != nil {
		return errors.Wrapf(err, "failed to read directory %s", path)
	}
	for _, entry := range entries {
		if err := os.RemoveAll(entry.Name()); err != nil {
			return errors.Wrapf(err, "failed to remove %s", entry.Name())
		}
	}
	return nil
}

func runCommand(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

func renderNftTemplate(template string, forwards []ForwardsEntry) string {
	dnatLines := []string{}
	forwardAcceptLines := []string{}

	for _, fwd := range forwards {
		// dnat = f"{protocol} dport {src_port} dnat ip to {dst}:{dst_port};"
		// accept = f"ip daddr {dst} {protocol} dport {dst_port} accept;"
		dnat := fmt.Sprintf("%s dport %d dnat ip to %s:%d;", fwd.Protocol, fwd.SourcePort, fwd.Address, fwd.DestinationPort)
		accept := fmt.Sprintf("ip daddr %s %s dport %d accept;", fwd.Address, fwd.Protocol, fwd.DestinationPort)
		dnatLines = append(dnatLines, dnat)
		forwardAcceptLines = append(forwardAcceptLines, accept)
	}

	dnat := strings.Join(dnatLines, "\n")
	accept := strings.Join(forwardAcceptLines, "\n")

	template = strings.Replace(template, ROUTER_NFT_MARKER_DNAT, dnat, 1)
	template = strings.Replace(template, ROUTER_NFT_MARKER_FORWARD_ACCEPT, accept, 1)
	return template
}
