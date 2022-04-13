#!/bin/bash
new_ip="$(terraform output mymysql_public_ip)"
file_path="../inventories/host_vars/awsmysqlserver/vars.yml"
sed -i "/ansible_host:/c ansible_host: $new_ip" $file_path