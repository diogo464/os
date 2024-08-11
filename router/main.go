package main

import (
	"bytes"
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
	ROUTER_CONFIG_DIRECTORY          = "/etc/router"
	ROUTER_CONFIG_BLOCKY_PATH        = ROUTER_CONFIG_DIRECTORY + "/blocky.yaml"
	ROUTER_RUN_DIRECTORY             = "/run/router"
	ROUTER_HOSTS_FILE_OUTPUT         = ROUTER_RUN_DIRECTORY + "/hosts"
	ROUTER_NFT_MARKER_DNAT           = "{{MARKER_DNAT}}"
	ROUTER_NFT_MARKER_FORWARD_ACCEPT = "{{MARKER_FORWARD_ACCEPT}}"
)

var (
	//go:embed router.nft.template
	ROUTER_NFT_TEMPLATE string
)

func main() {
	log.Println("Starting router...")
	if err := os.MkdirAll(ROUTER_RUN_DIRECTORY, 0755); err != nil {
		log.Fatalf("Failed to create %s: %v", ROUTER_RUN_DIRECTORY, err)
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

	if _, err := os.Stat(ROUTER_HOSTS_FILE_OUTPUT); os.IsNotExist(err) {
		log.Printf("Creating %s...", ROUTER_HOSTS_FILE_OUTPUT)
		if err := os.WriteFile(ROUTER_HOSTS_FILE_OUTPUT, []byte(""), 0644); err != nil {
			return errors.Wrapf(err, "Failed to create %s", ROUTER_HOSTS_FILE_OUTPUT)
		}
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

		finalEntries := []HostsEntry{}
		for _, entryArr := range entries {
			for _, entry := range entryArr {
				finalEntries = append(finalEntries, entry)

				for _, host := range entry.Hosts {
					if strings.Contains(host, ".") {
						continue
					}

					finalEntries = append(finalEntries, HostsEntry{
						Address: entry.Address,
						Hosts: []string{
							fmt.Sprintf("%v.local", host), fmt.Sprintf("%v.home", host), fmt.Sprintf("%v.lan", host),
						},
					})
				}
			}
		}

		content := ""
		for _, entry := range finalEntries {
			content += entry.String() + "\n"
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
	applyNftTemplate := func(content string) error {
		cmd := exec.Command("nft", "-f", "-")
		cmd.Stdin = strings.NewReader(content)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			return errors.Wrapf(err, "Failed to run nft -f -")
		}
		return nil
	}

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

	log.Println("Applying empty nft template...")
	if err := applyNftTemplate(renderNftTemplate(ROUTER_NFT_TEMPLATE, []ForwardsEntry{})); err != nil {
		return errors.Wrapf(err, "Failed to apply nft template")
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
		if err := applyNftTemplate(content); err != nil {
			return errors.Wrapf(err, "Failed to apply nft template")
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

func writeFile(path string, content string) {
	log.Printf("writing %s", path)
	if err := os.WriteFile(path, []byte(content), 0); err != nil {
		log.Fatalf("failed to write %s", path)
	}
}

func writeFileIfChanged(path string, content string) bool {
	existing, err := os.ReadFile(path)
	if err != nil && !os.IsNotExist(err) {
		log.Fatalf("failed to read file %s", path)
	}

	if err == nil && bytes.Equal([]byte(content), existing) {
		return false
	}

	writeFile(path, content)
	return true
}

func runCommand(name string, args ...string) {
	c := ""
	c += name
	for _, arg := range args {
		c += " " + arg
	}
	log.Printf("running %s", c)

	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Fatalf("failed to run %s", c)
	}
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
