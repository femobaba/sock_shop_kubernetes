#!/bin/bash

# Update instance and install ansible
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible python3-pip -y
sudo bash -c ' echo "strictHostKeyChecking No" >> /etc/ssh/ssh_config'

# Copying Private Key into Ansible Server and chaning its permission
echo "${prv_key}" >> /home/ubuntu/PACUJPEU1-key
sudo chmod 400 /home/ubuntu/PACUJPEU1-key
sudo chown ubuntu:ubuntu /home/ubuntu/PACUJPEU1-key 

# Giving the right permission to Ansible Directory
sudo chown -R ubuntu:ubuntu /etc/ansible && chmod +x /etc/ansible
sudo chmod 777 /etc/ansible/hosts
sudo chown -R ubuntu:ubuntu /etc/ansible

# Copying the 1st HAproxy IP into our ha-ip.yml
sudo echo ha_prv_ip: "${HAproxy1_IP}" >> /home/ubuntu/ha-ip.yml

# Copying the 2nd HAproxy IP into our ha-ip.yml
sudo echo prod_Bckup_haIP: "${HAproxy2_IP}" >> /home/ubuntu/ha-ip.yml

# Updating Host inventory file with all the ip addresses
sudo echo "[MastKeepalived]" >> /etc/ansible/hosts
sudo echo "${HAproxy1_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts
sudo echo "[Prod_BackupKeepalived]" >> /etc/ansible/hosts
sudo echo "${HAproxy2_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts 
sudo echo "[main_master]" >> /etc/ansible/hosts
sudo echo "${master1_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts
sudo echo "[member_master]" >> /etc/ansible/hosts
sudo echo "${master2_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts
sudo echo "${master3_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts
sudo echo "[Worker]" >> /etc/ansible/hosts
sudo echo "${worker1_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts 
sudo echo "${worker2_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts 
sudo echo "${worker3_IP} ansible_ssh_private_key_file=/home/ubuntu/PACUJPEU1-key" >> /etc/ansible/hosts 

# # Executing all playbooks
sudo su -c "ansible-playbook /home/ubuntu/playbooks/installation.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/keepalived.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/main_master.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/member_master.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/worker.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/haproxy.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/stage.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/prod.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbooks/monitoring.yml" ubuntu

sudo hostnamectl set-hostname Ansible