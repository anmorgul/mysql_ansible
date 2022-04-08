preinit: install_plugins init
init: up

install_plugins:
	vagrant plugin install vagrant-hostsupdater
	vagrant plugin install vagrant-env

up:
	vagrant up

halt:
	vagrant halt mysqlserver mysqlserver2
#jenkinsnode2

destroy:
	vagrant destroy mysqlserver mysqlserver2
#jenkinsnode2
