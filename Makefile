SHELL := /bin/bash

init: 
	(	python3 -m venv venv; \
		source venv/bin/activate; \
		python3 -m pip install --upgrade pip; \
		pip install -r ./requirements.txt;\
	)

freeze:
	(	source venv/bin/activate; \
		pip freeze > ./requirements.txt; \
	)

install_mysql:
	(	source venv/bin/activate; \
		ansible-playbook mysql.yml --tags install; \
	)

remove_mysql:
	(	source venv/bin/activate; \
		ansible-playbook mysql.yml --tags uninstall; \
	)

encrypt:
	(	source venv/bin/activate; \
		ansible-vault encrypt ./host_vars/vault.yml; \
	)

decrypt:
	(	source venv/bin/activate; \
		ansible-vault decrypt ./host_vars/vault.yml; \
	)
