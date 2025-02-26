#!/bin/bash

# User variables
USERNAME="aaa" # Change this to the desired username
PASSWORD="aaa" # Change this to a secure password
SSH_KEY="ssh-ed25519 AAAA..." # Add your SSH key here

echo "Updating system..."
sudo apt-get update && sudo apt-get upgrade -y

# Security configuration
echo "Disabling SSH access for root..."
sudo sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

echo "Creating user $USERNAME..."
sudo adduser --disabled-password --gecos "" $USERNAME
echo "$USERNAME:$PASSWORD" | sudo chpasswd
sudo usermod -aG sudo $USERNAME

echo "Enabling SSH for $USERNAME..."
sudo mkdir -p /home/$USERNAME/.ssh
echo "$SSH_KEY" | sudo tee /home/$USERNAME/.ssh/authorized_keys > /dev/null
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

echo "Setting up UFW firewall..."
sudo ufw allow OpenSSH
sudo ufw enable -y

echo "Installing Fail2Ban..."
sudo apt-get install -y fail2ban
sudo systemctl enable --now fail2ban

# Installing essential tools
echo "Installing zip, 7zip, and git..."
sudo apt-get install -y zip p7zip-full git

# Installing Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Uncomment this if you want to run docker without sudo level
# echo "Adding user $USERNAME to the docker group..."
# sudo usermod -aG docker $USERNAME

echo "Rebooting system to apply changes..."
sudo reboot
