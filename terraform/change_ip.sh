#!/bin/bash
new_ip="$(terraform output mymysql_public_ip)"
file_path="../inventories/host_vars/awsmysqlserver/vars.yml"
sed -i "/ansible_host:/c ansible_host: $new_ip" $file_path
echo "#!/bin/bash" > ../secrets/awsmysqlserver/ssh_aws.sh
echo "ssh ubuntu@$new_ip -i ./id_rsa_awsmymysql" >> ../secrets/awsmysqlserver/ssh_aws.sh