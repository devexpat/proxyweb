basedir = /usr/local/proxyweb
secret_key=$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

proxyweb-build:
	docker build -t proxyweb/proxyweb:latest .

proxyweb-build-nocache:
	docker build --no-cache -t proxyweb/proxyweb:latest .

proxyweb-run-local:
	docker run -h proxyweb --name proxyweb --network="host" -d proxyweb/proxyweb:latest 

proxyweb-run:
	docker run -h proxyweb --name proxyweb -p 5000:5000 -d proxyweb/proxyweb:latest 

proxyweb-run-mappedconf:
	docker run --mount type=bind,source="`pwd`/config/config.yml",target="/app/config.yml" -h proxyweb --name proxyweb --network="host" -d proxyweb/proxyweb:latest 

proxyweb-login:
	docker exec -it proxyweb bash 

proxyweb-pull:
	docker pull proxyweb/proxyweb:latest

proxyweb-push:
	docker push proxyweb/proxyweb:latest

proxyweb-destroy:
	docker stop proxyweb && docker rm proxyweb

install:
	useradd -s /bin/false -d $(basedir)  proxyweb
	apt update && apt install python3-pip python3-venv -y
	mkdir -p $(basedir)/
	cp -r . $(basedir)/
	chown -R proxyweb  $(basedir)/config/
	sed -i "s/12345678901234567890/${secret_key}/" ${basedir}/config/config.yml
	python3 -m venv $(basedir)/
	$(basedir)/bin/pip3 install -r $(basedir)/requirements.txt
	cp misc/proxyweb.service /etc/systemd/system/
	systemctl daemon-reload
	systemctl enable proxyweb
	systemctl start proxyweb
	systemctl status proxyweb

uninstall:
	-systemctl stop proxyweb
	-systemctl disable proxyweb
	-userdel proxyweb
	-rm /etc/systemd/system/proxyweb.service
	-rm -rf $(basedir)

proxyweb-start:
	systemctl start proxyweb

proxyweb-stop:
	systemctl stop proxyweb

dbtest-build:
	cd docker-compose/dbtest && docker build -t proxyweb/dbtest:latest .

dbtest-pull:
	docker pull proxyweb/dbtest:latest

dbtest-push:
	docker push proxyweb/dbtest:latest

dbtest-build-nocache:
	cd docker-compose/dbtest && docker build --no-cache -t proxyweb/dbtest:latest .

compose-destroy:
	cd docker-compose/ && docker-compose rm -f

compose-up:
	cd docker-compose/ && docker-compose up --remove-orphans

compose-down:
	cd docker-compose/ && docker-compose down

