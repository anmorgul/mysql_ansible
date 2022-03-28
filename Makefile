SHELL := /bin/bash

install: 
	(	python3 -m venv venv; \
		source venv/bin/activate; \
		python3 -m pip install --upgrade pip; \
		pip install -r ./requirements.txt;\
	)

freeze:
	(	source venv/bin/activate; \
		pip freeze > ./requirements.txt; \
	)