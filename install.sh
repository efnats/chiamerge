#!/bin/bash
echo ""
echo "Welcome to the chiamerge install script"
echo ""
echo "This will install all prerequesites and the systemd services to your systemd folder and reload the systemd daemon"
echo "Everything else can then be found in /usr/local/bin/"
echo ""
echo "Prerequesites to be installed are: udisks2 mergerfs smartmontools and ntfs-3g"
echo "The systemd services are called: mnt-garden.mount and mount-chia-drives.service and are located at /etc/systemd/system/"
echo ""
echo "No destructive actions are being perfomed upon this installation. Your plots are safe!"
echo ""
read -p "Continue? (y/n)" ANS
echo ""
sudo mkdir -p /mnt/garden
sudo apt install -y udisks2 mergerfs smartmontools ntfs-3g
sudo cp -v mnt-garden.mount /etc/systemd/system/
sudo cp -v mount-chia-drives.service /etc/systemd/system/
sudo cp -v chia-mountall /usr/local/bin/
sudo cp -v chia-unmountall /usr/local/bin/
sudo cp -v chiamerge /usr/local/bin/
sudo cp -v exportdrives /usr/local/bin/
sudo chmod +x /usr/local/bin/chia-mountall
sudo chmod +x /usr/local/bin/chia-unmountall
sudo chmod +x /usr/local/bin/chiamerge
sudo systemctl daemon-reload
sudo systemctl restart mnt-garden.mount
sudo systemctl enable mnt-garden.mount
echo "done"