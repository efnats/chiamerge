# chia-tools
A set of tools for xch crypto farming with mergerfs in mind



If you agree that organizing a lot of hdds for chia farming/plotting should not be done in the fstab, read on.
The toolset constists of a chain of tools that will automate the process a bit.


chiaman: any given disks will be wiped, one large partition is created, formatted, labelled by CHIA-serialnr and an empty file with the filename of the serialnr is created in the main folder of the disk.

mnt-garden.mount: mount all disks that have the pattern CHIA in their disk name into one mergerfs mountpoint. the default is /mnt/garden

mount-chia-drives.service: is called by mnt-garden.mount and will use udisks to mount all drives correctly in /media/root/ preparing it for the mergerfs mount.

BEWARE!!! CHIAMAN HAS FUNCTIONS THAT WILL DESTROY ANY DATA ON THE DISK YOU HAVE GIVEN IT TO WORK ON. All destructive functions come with a warning (y/n) for you to decide. BUT TAKE CARE!!

requirements
------------
this toolset is developed on ubuntu server 20.04.2 but will likely work on any systemd based linux

mergerfs - this is where the magic happens. Thank you trapexit!

udisks - needed for the mount serivce. On ubuntu20.04 apt will install 2.8.4-1ubuntu1 by default. Manually install 2.8.4-1ubuntu2 to make it more stable



chiaman
-------

Arguments:    one or more disknames (eg: sda sdb-sdd)

 Usage 1:      chiaman <diskname>...
 Example:      chiaman sda
               chiaman sda-sdd
               chiaman sda sdd-sdf sdj

 Usage 2:      chiaman <action> <diskname> <disknamerange> ... (in any order)
 Example:      chiaman --wipe sda sdc-sdg sdh
               chiaman --wipe sda sdb --format sdc

commands

  --wipe		wipe all information from the drive using the wipefs
  --format		parition the drive using parted with one partition that uses the entire disk, then create an ext4 filesystem on that disk. Ext4 arguments are pre optimized for chia farming and can be changed in the source code (MKFSOPTIONS)
  --label		aquire serialnr of disk and label the disk as CHIA-[SERIALNR]
  --write-sn		aquire serialnr of disk and write an empty file in the main folder of the partition which is called like the serialnr



Calling chiaman without any commands is the same as calling chiaman with all commands (wipe, format, label, write-sn)

I guess wipe and format are self explanatory.
Here is the explanation for the somewhat odd functions label and write

label: will prepare the disk so that it can be picked up be the mount service later and mounted into the mergerfs mountpoint. This will prevent other disks, like systemdisks etc to be mounted into mergerfs mountpoint /mnt/garden. (Unless you have the pattern CHIA in its label). Label is a non-destructive action. You will not lose your data on an EXT4 disk by changing its label.

write-sn: the empty file named after the serialnr helps to identify disks that are missing from the system (eg. because of a broken SATA cable). Enter the mergerfs dir (/mnt/garden) and count the amount of empty serialnr-files. It should match the amount of disks in your system. If one is missing find the missing serialnr in the folder. PRO-TIP: use your phone's bar code reader. Most disks have their serialnr encoded on the end of the disk. write-sn will only work on preformatted disks as the filesytem will be mounted shortly for that in a temporary folder.




mount-chia-drives.service
------------------
usage: systemctl (start|stop) mount-chia-drives.service

Will call /usr/local/bin/chia-mountall which will mount all disks in the system that have the pattern "CHIA" in their label into /media/root/[LABELNAME] where they will be picked up by the mnt-garden.mount to mount in single folder using mergerfs




mnt-garden.mount
----------------
usage: systemctl (start|stop) mnt-garden.mount

Will start chia-mount.service
Will mount all drives from chia-mount.service into folder /mnt/garden using mergerfs with given policy. The provided example will use policy mfs (most free space) which will grant that in an archiving scenario with multiple plotters connected to a harvester via fast (10G) Ethernet connection the spinning hard disks will less likely be the bottleneck.

For expample: plotter1 is archiving plot1.plot to the harvester into /mnt/garden via network connection
	      plotter2 is archiving plot2.plot to the harvester into /mnt/garden via network connection

In this scenario where (starting with empty disks) plot2.plot will be written to a different hdd than plot1.plot hence extending total write bandwith of the harvester.



NOTE: upon starting mnt-garden.mount the chia-mount.service is being executed automatically. Stopping the mnt-garden.mount will NOT unmount the drives from the system, but only the mergerfs mountpoint. If you want to unmount all disks you should stop the mount-chia-drives.service


install.sh
----------
A very basic fist version of the installer
