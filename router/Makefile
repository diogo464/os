HOST ?= core@192.168.0.1

default:
	@make --print-targets

unlock:
	ssh ${HOST} sudo rpm-ostree usroverlay

deploy:
	go build .
	scp router ${HOST}:./router
	ssh ${HOST} 'sudo systemctl stop router && sudo cp router /usr/bin/router && sudo systemctl start router'

logs:
	ssh ${HOST} sudo journalctl -fu router
