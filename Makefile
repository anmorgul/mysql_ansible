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
		ansible-playbook install_mysql.yml --tags install; \
	)

remove_mysql:
	(	source venv/bin/activate; \
		ansible-playbook install_mysql.yml --tags uninstall; \
	)
