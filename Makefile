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

swap:
	(	source venv/bin/activate; \
		ansible-playbook mysql.yml --tags swap; \
	)

encrypt:
	(	source venv/bin/activate; \
		ansible-vault encrypt ./inventories/host_vars/myubuntu/vault.yml; \
		ansible-vault encrypt ./inventories/group_vars/allmysqlservers/vault.yml; \
		# ansible-vault encrypt ./inventories/host_vars/mysqlserver/private_key; \
	)

decrypt:
	(	source venv/bin/activate; \
		ansible-vault decrypt ./inventories/host_vars/myubuntu/vault.yml; \
		ansible-vault decrypt ./inventories/group_vars/allmysqlservers/vault.yml; \
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

###########
### aws ###
###########

aws: generate_ssh_keys terraform_apply install_awsmysql

generate_ssh_keys:
	(	source venv/bin/activate; \
		ansible-playbook generate_ssh.yml; \
	)

install_awsmysql:
	(	source venv/bin/activate; \
		ansible-playbook aws_mysql.yml --tags install; \
	)

uninstall_awsmysql:
	(	source venv/bin/activate; \
		ansible-playbook aws_mysql.yml --tags uninstall; \
	)

terraform_init:
	(	cd ./terraform; \
		terraform init; \
	)

terraform_plan:
	(	cd ./terraform; \
		terraform plan; \
	)

terraform_apply:
	(	cd ./terraform; \
		terraform apply; \
		./change_ip.sh; \
	)

terraform_destroy:
	(	cd ./terraform; \
		terraform destroy; \
	)

#######
# ECR #
#######
aws_ecr:
	(	source venv/bin/activate; \
		ansible-playbook ecs.yml  --tags ecr -vv; \
	)