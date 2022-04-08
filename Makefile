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

secure:
	(	source venv/bin/activate; \
		ansible-playbook mysql.yml --tags secure; \
	)

users:
	(	source venv/bin/activate; \
		ansible-playbook mysql.yml --tags users; \
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
		ansible-playbook ping.yml; \
	)

up_vagrant:
	ssh xeon 'cd /home/anmorgul/Documents/Projects/Softserve/mysql_vagrant/; make up'
	scp xeon:/home/anmorgul/Documents/Projects/Softserve/mysql_vagrant/.vagrant/machines/mysqlserver/virtualbox/private_key ./secrets/mysqlserver/private_key 
	scp xeon:/home/anmorgul/Documents/Projects/Softserve/mysql_vagrant/.vagrant/machines/mysqlserver2/virtualbox/private_key ./secrets/mysqlserver2/private_key 

halt_vagrant:
	ssh xeon 'cd /home/anmorgul/Documents/Projects/Softserve/mysql_vagrant/; make halt'
