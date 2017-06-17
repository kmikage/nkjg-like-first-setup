#!/bin/sh
# How to use
# ---
# <New Incetance>
# SAKURA Internet [Virtual Private Server SERVICE]
# $ wget -O - 'https://raw.githubusercontent.com/kmikage/nkjg-like-first-setup/master/Sakura-no-VPS/install_ansible_to_ubuntu16_04.sh' | /bin/sh

sudo sed -i "s/^PermitRootLogin .*$/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo sed -i "s/^PasswordAuthentication .*$/PasswordAuthentication no/g" /etc/ssh/sshd_config
sudo systemctl reload sshd  

sudo sed -i "s/ ALL$/ NOPASSWD:ALL/g" /etc/sudoers

mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa

ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
cp -prv ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys

touch ~/.ssh/config
chmod 600 ~/.ssh/config

cat <<_EOL | tee ~/.ssh/config
Host localhost
 Hostname 127.0.0.1
 Port 22
 User ubuntu
 IdentityFile ~/.ssh/id_rsa

Host *
 ServerAliveInterval 10
 ServerAliveCountMax 5
 GatewayPorts yes
 StrictHostKeyChecking no
 UserKnownHostsFile /dev/null
_EOL

sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install vim -y
sudo apt-get install ansible -y

sudo update-alternatives --config editor
sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

sudo mkdir -p /etc/ansible
echo "127.0.0.1 ansible_connection=local" | sudo tee -a /etc/ansible/hosts

cat <<_EOL > ~/upgrade.yml
---
- hosts: localhost
  user: ubuntu
  become: yes
  tasks:
    - name: "upgrade"
      apt: 
        upgrade: dist

_EOL

ansible-playbook -k ~/upgrade.yml

echo '--- your SSH secret key ---'
cat ~/.ssh/id_rsa
echo '--- your SSH secret key ---'

exit
