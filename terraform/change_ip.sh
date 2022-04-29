#!/bin/bash
new_ip="$(terraform output dns_name_nlb)"
file_path="../secrets/bastion/bastion_ip.yml"
sed -i "/bastion_ip:/c bastion_ip: $new_ip" $file_path
echo "#!/bin/bash" > ../secrets/awsmysqlserver/ssh_aws.sh
echo "ssh ubuntu@$new_ip -i ./id_rsa_awsmymysql" >> ../secrets/awsmysqlserver/ssh_aws.sh