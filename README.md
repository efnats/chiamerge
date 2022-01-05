# Chiamerge

**A set of tools for xch crypto farming with mergerfs in mind**

<p>
    <a href="#About">About</a> •
    <a href="#why-mergerfs">Why mergerfs?</a> •
    <a href="#Description">Description?</a> •
    <a href="#Requirements">Requirements</a> •
    <a href="#Chiamerge">Chiamerge</a> •
    <a href="#Features">Features</a> •
    <a href="#Installation">Installation</a> •
    <a href="#Configuration">Configuration</a> •
    <a href="#bugs-todo">Bugs / Todo</a>


</p>

## About

If you agree that organizing a lot of hdds for chia farming/plotting should not be done in the fstab, read on.
Here are some tools that will automate the process for you. It consists of a bash tool called **chiamerge**, which will allow you to format and prepare multiple disks at once to be later picked up by the provided mount service **mnt-garden.mount** that handles which drives are being selected for the final mount directory.

## Why mergerfs?
Mergerfs is a union filesystem that logically merges multiple paths together. There is no redunancy in mergerfs and this makes it a perfect match for chia plots, as there is no userdata stored, so that a lost disk drive can easily be replaced by simply replotting it. We don't use a blockdevice based filesystem like ZFS or LVM that will write over disk boundaries because the loss of one disk would then mean a loss of the entire dataset, which we cannot allow.
The author of mergerfs is awesome, as you can see here: https://www.reddit.com/r/chia/comments/o7pxpz/mergerfs_and_chia/

## Description

-   **chiamerge**: any given disks will be wiped, one large partition is created, formatted, labelled by CHIA-serialnr and an empty file with the filename of the serialnr is created in the main folder of the disk.
-   **mnt-garden.mount**: mount all disks that have the pattern CHIA in their disk label into one mergerfs mountpoint. the default is /mnt/garden
-   **mount-chia-drives.service**: is called by mnt-garden.mount and will use udisks to mount all drives correctly in /media/root/[labelname] preparing it for the mergerfs mount.

_BEWARE!!! CHIAMAN HAS FUNCTIONS THAT WILL DESTROY ANY DATA ON THE DISK YOU HAVE GIVEN IT TO WORK ON. All destructive functions come with a warning (y/n) for you to decide. BUT TAKE CARE!!_

## Requirements

This toolset is tested on Ubuntu Server 20.04.2 but will likely work on any debian or systemd based linux

mergerfs - this is where the magic happens. Thank you trapexit https://github.com/trapexit/mergerfs

udisks - needed for the mount serivce. On ubuntu20.04 apt will install 2.8.4-1ubuntu1 by default. Manually install 2.8.4-1ubuntu2 to make it more stable

smartmontools - to read out the serial number of hard disks

## Chiamerge

### Arguments

one or more disknames (eg: `sda sdb-sdd`)

Usages:

1. `chiamerge <action> <diskname> <range> ...` (in any order)

    Example:

    - `chiamerge --wipe sda sdc-sdg sdh`
    - `chiamerge --wipe sda sdb --format sdc`

### Actions

`--wipe` wipe **all information** from the drive using the wipefs command

`--format` **parition the drive** using parted with one partition that uses the entire disk, then create an ext4|xfs|ntfs filesystem on that disk. EXT4|XFS|NTFS arguments are pre optimized for chia farming and can be changed in the configuration part of chiamerge (EXT4OPTIONS|XFSOPTIONS|NTFSOPTINS)

`--format-ext4` **parition the drive with EXT4 Filesystem** using parted with one partition that uses the entire disk, then create an ext4 filesystem on that disk. You will not need this option if you set the desired filesystem in the config and use --format or --chia-init-disk

`--format-xfs` **parition the drive with XFS Filesystem** using parted with one partition that uses the entire disk, then create an ext4 filesystem on that disk. You will not need this option if you set the desired filesystem in the config and use --format or --chia-init-disk

`--format-ntfs` **parition the drive with NTFS Filesystem** using parted with one partition that uses the entire disk, then create an ext4 filesystem on that disk. You will not need this option if you set the desired filesystem in the config and use --format or --chia-init-disk

`--label` **aquire serialnr** of disk and **label** the disk as CHIA-[SERIALNR]

`--write-sn` **aquire serialnr** of disk and **write** an empty file in the main folder of the partition which is called like the serialnr

`--chia-init-disk` is the same as calling chiamerge with the actions (`--wipe`, `--format`, `--label`, `--write-sn`). This the default intended behaviour to prepare hard drives.


Here is the explanation for the somewhat odd functions label and write-sn

`label`:

-   will prepare the disk so that it can be picked up be the mount service later and mounted into the **mergerfs** mountpoint. This will prevent other disks, like systemdisks etc to be mounted into mergerfs mountpoint **/mnt/garden**. (Unless you have the pattern CHIA in its label). Label is a non-destructive action. You will not lose your data on an EXT4 or XFS disk by changing its label.

`write-sn`:

-   the empty file named after the serialnr helps to identify disks that are missing from the system (eg. because of a broken SATA cable). Enter the **mergerfs dir** (/mnt/garden/serial) and count the amount of empty **serialnr-files**. It should match the amount of disks in your system. If one is missing find the missing serialnr in the folder. PRO-TIP: use your phone's bar code reader. Most disks have their serialnr encoded on the end of the disk. write-sn will only work on preformatted disks as the filesytem will be mounted shortly for that in a temporary folder.

## The systemd service

### mount-chia-drives.service

    usage: systemctl (start|stop) mount-chia-drives.service

Will call **/usr/local/bin/chia-mountall** which will mount all disks in the system that have the pattern "CHIA" in their label into **/media/root/[LABELNAME]** where they will be picked up by the mnt-garden.mount to mount in single folder using mergerfs

### mnt-garden.mount

    usage: systemctl (start|stop) mnt-garden.mount

Will start **chia-mount.service**
Will mount all drives from chia-mount.service into folder **/mnt/garden** using mergerfs with given policy. The provided example will use policy mfs (most free space) which will grant that in an archiving scenario with multiple plotters connected to a harvester via fast (10G) Ethernet connection the spinning hard disks will less likely be the bottleneck.

For expample: plotter1 is archiving plot1.plot to the harvester into /mnt/garden via network connection
plotter2 is archiving plot2.plot to the harvester into /mnt/garden via network connection

In this scenario where (starting with empty disks) plot2.plot will be written to a different hdd than plot1.plot hence extending total write bandwith of the harvester.

NOTE: upon starting **mnt-garden.mount** the **mount-chia-drives.service** is being executed automatically. Stopping the **mnt-garden.mount** will NOT unmount the drives from the system, but will only unmount the mergerfs mountpoint. If you want to unmount all disks from the system you should stop the **mount-chia-drives.service**

## Installation / Examples

### Installation

Open a terminal
`git clone https://github.com/efnats/chiamerge.git`

`cd chiamerge`

`./install.sh`

Open chiamerge with an editor and check the configuration settings. The default is to use ext4, but you can change it to xfs or ntfs.

`lsblk`to see your currently installed disks. Make sure all disks that you would like to prepare are unmounted

`./chiamerge --chia-init-disk sda-sdf sdi sdaa-sdab`

This will guide you through the process of formatting and labelling all your selected disks. In this case we have chosen 9 disks.

`systemctl start mnt-garden.mount`

To mount our disks and create the mergerfs mount /mnt/garden

check in `/mnt/garden/serial` and count the number of files to verify the correct amount of disks is in the mergerfs mountpoint


## Configuration

### chiamerge

There is a configuration section in the chiamerge bash script.
-   **FSTYPE** Use FTSYPE=EXT4 or FSTYPE=XFS or FSTYPE=NTFS
-   **EXT4OPTIONS** and **XFSOPTIONS** and **NTFSOPTIONS** will determine the options that mkfs will use to write the filesystem. The default options are optimized to fit as many plots as possible in the filesystem. If you have suggestions to improve please do let me know.
-   **DEBUGLEVEL** DEBUGLEVEL=0 to disable logging into ./chiamerge.log

### mnt-garden.mount

Please refer to https://github.com/trapexit/mergerfs#options to determine what the best options for mergerfs are for you. Especially the write policy is important here as decribed above. The supplied config has been tested with multiple stand-alone harvesters.

The chia-mountall script in /usr/local/bin has rw (read/write) in the mount option set by default. If you're done plotting it would make sense to change this to ro (read-only)


## Bugs / Todo

The function label doesnt check for the filesystem used on the specific partition. If you want to label a partition, the correct setting (xfs or ext4) must be applied in advance. If you try to label a partition in xfs for example when the partition is formatted in ext4 the function will fail. I don't think it is worth adding this function as the specific use case for chia is not to have a bunch of disks with different filesystems each but rather an array of disks that are all prepared in the same fashion.

The installer needs to be better.

Extended disk ranges from sda-sdaz are not working. Whats working though is sda-sdz sdaa-sdaz so you can just combine the two. At a later stage I want to pull the disk names from lsblk.

Documentation for mount/umount function
## Socials

-   @efnats

## License

-   MIT License
