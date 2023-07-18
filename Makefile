.PHONY:

install-python:
	poetry install

install: install-python

lint:
	poetry run ansible-lint playbooks/provision/main.yml
	poetry run ansible-lint playbooks/cluster/main.yml

provision:
	poetry run ansible-playbook -i environments/production/provision.yml provision.yml
