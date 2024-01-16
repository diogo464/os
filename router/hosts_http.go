package main

import (
	"io"
	"net/http"

	"github.com/pkg/errors"
)

type HostsFetcherHttp struct {
	Url string
}

// FetchHosts implements HostsFetcher.
func (f *HostsFetcherHttp) FetchHosts() ([]HostsEntry, error) {
	response, err := http.Get(f.Url)
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to fetch %s", f.Url)
	}
	content, err := io.ReadAll(io.LimitReader(response.Body, 1024*1024))
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to read response body from %s", f.Url)
	}
	return ParseHostsFile(string(content))
}
