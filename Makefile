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
		ansible-playbook mysql.yml --tags install -vvvv; \
	)

remove_mysql:
	(	source venv/bin/activate; \
		ansible-playbook mysql.yml --tags uninstall -vv; \
	)

encrypt:
	(	source venv/bin/activate; \
		ansible-vault encrypt ./inventories/host_vars/myubuntu/vault.yml; \
		# ansible-vault encrypt ./inventories/host_vars/mysqlserver/private_key; \
	)

decrypt:
	(	source venv/bin/activate; \
		ansible-vault decrypt ./inventories/host_vars/myubuntu/vault.yml; \
		# ansible-vault decrypt ./inventories/host_vars/mysqlserver/private_key; \
	)

ping:
		(	source venv/bin/activate; \
		ansible-playbook ping.yml -vvvv; \
	)
