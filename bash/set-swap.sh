#!/bin/bash

SWAP_SIZE=2G  # Change this to the desired swap size
SWAP_FILE="/swapfile"

echo "Checking if swap is already configured..."
if free | awk '/^Swap:/ {exit !$2}'; then
    echo "Swap is already configured. Exiting..."
    exit 0
fi

echo "Creating swap file of $SWAP_SIZE..."
sudo fallocate -l $SWAP_SIZE $SWAP_FILE || sudo dd if=/dev/zero of=$SWAP_FILE bs=1M count=$((2*1024)) status=progress

echo "Setting security permissions..."
sudo chmod 600 $SWAP_FILE

echo "Formatting swap file..."
sudo mkswap $SWAP_FILE

echo "Activating swap..."
sudo swapon $SWAP_FILE

echo "Making swap persistent in /etc/fstab..."
echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab

echo "Configuring performance parameters..."
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50

echo "Applying changes in sysctl.conf..."
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

echo "Swap configured successfully 🚀"
free -h
