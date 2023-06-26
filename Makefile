.PHONY:

install-python:
	poetry install

install: install-python

lint:
	poetry run ansible-lint playbooks/provision/main.yml 2>/dev/null

provision:
	poetry run ansible-playbook -i environments/production/provision.yml provision.yml
