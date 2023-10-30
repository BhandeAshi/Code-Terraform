#!/bin/bash

ip=$(terraform output ec2_instance_private_ip)


file_to_modify="nginx.tf"

ip="${ip#\"}"
ip="${ip%\"}"

sed -i "s/ani/$(echo $ip | sed 's/\//\\&/g')/g" "$file_to_modify"

echo "$ip"
