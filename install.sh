#!/bin/bash
echo ""
echo "Welcome to chia-tools install script"
echo ""
echo "This will install prerequesites and copy the mnt-garden.mount to your systemd folder and reload the systemd daemon"
echo "The rest can be found in /usr/local/bin/"
echo ""
read -p "Continue? (y/n)" ANS
echo ""
sudo mkdir -p /mnt/garden
sudo apt install -y udisks2 mergerfs
sudo cp -v mnt-garden.mount /etc/systemd/system/
sudo cp -v mount-chia-drives.service /etc/systemd/system/
sudo cp -v chia-mountall /usr/local/bin
sudo cp -v chia-unmountall /usr/local/bin
sudo cp -v chiaman /usr/local/bin
sudo chmod +x /usr/local/bin/chia-mountall
sudo chmod +x /usr/local/bin/chia-unmountall
sudo chmod +x /usr/local/bin/chiaman
sudo systemctl daemon-reload
sudo systemctl enable mnt-garden.mount
echo "done"