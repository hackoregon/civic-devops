# Procedure to increase the size of EBS Volume (disk)

## Resize the Volume

Login to AWS account as an Admin user and click on drop down for **Services** in upper left of console.

Select **EC2** under **Compute** and when EC2 dashboard appears, select **Volumes** under the “**Elastic Block Store**” from the left side column.

On the Volumes page select the Volume you want to increase the size of and under **Description Tab** you'll see the current “**Attachment information**”. If the Volume is not attached to a system, the attachment information will be blank; if attached it will display something like this (*i-05a53808f9f20874d (EBStest):/dev/sdd (attached)*). This information indicates the Instance ID and Name tag (if any) of the EC2 instance to which the volume is attached. 

You will need the public IP address and private key to `ssh` into the system.

Note: the size of the volume can be increased without unmounting the filesystem or detaching the Volume or stopping the Instance. However it is good practice to create a snapshot of the Volume before changing the size and extending the filesystem, in case something goes wrong and you have to rebuild (snapshot recovery is quicker than traditional copy or restore).

### Procedure to Resize

With the Volume selected on the AWS console, click the “**Actions**” drop down in the upper right. In the drop down select “**Modify Volume**”. Set the new size and click the “**Modify**” button. 

In the Description tab of the Volume it will show the "**State**" of the operation - you may need to refresh the screen (circular arrows in to right of screen) to see the current status. 

When this operation has completed ("**State**" again reports `in-use`), the next step is to extend the filesystem.

## Extend the filesystem

To extend the filesystem, you'll first have to verify which device is being extended, then make sure the filesystem isn't busy, then actually perform the filesystem resize.

### Procedure to Verify

Run the `lsblk` command with no arguments to get the NAME for the attached Volume (note: Linux may have remapped the device name, so it may not match the device name from the Volume “Attachment information” from the AWS console).  Example output:

```
$ lsblk
NAME    MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   8G  0 disk 
└─xvda1 202:1    0   8G  0 part /
xvdb    202:16   0  13G  0 disk /data
```

The `lsblk` information will indicate the Linux device name, the mount point (e.g. `/data`) and whether it is an entire disk (i.e. `disk`) or if the disk has been partitioned (i.e. `part`). In the procdure below, we will assume the disk has not partitioned and thus the filesystem can be increased to use the entire space of the Volume.  (If the Volume is partitioned you will need to use the `gdisk` command to extend the partition before extending the filesystem.)

You can run commands like this on the EC2 Instance either from a shell running on the server - after `ssh`-ing into the EC2 Instance the Volume is attached to - or remotely as parameters to an `ssh` command that's launched locally:

- e.g. `ssh -i ec2-key.pem  ec2-user@xx.xx.xx.xx  'lsblk'`

- the `-i` argument specifies the path to the secret key file for the key used with the ec2 instance

- the `<user>@<xx.xx.xx.xx>` is the user and IP address of the Instance

- the command (e.g. `'lsblk'`) is what you're going to run on the remote Instance

You'll notice that the SIZE is already quoting the new extended size.  To verify the current filesystem-level allocation of space, run the `df -h` command, with such output as this:

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        484M     0  484M   0% /dev
tmpfs           497M  4.0K  497M   1% /dev/shm
tmpfs           497M   13M  484M   3% /run
tmpfs           497M     0  497M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.2G  6.9G  15% /
tmpfs           100M     0  100M   0% /run/user/0
tmpfs           100M     0  100M   0% /run/user/1000
/dev/xvdb       7.8G  252M  7.1G   4% /data
```

You should notice that the Size of `/dev/xvdb` is still only 7.8G (which is its original size).

### Procedure to make sure filesystem isn't Busy

If you proceed to extend the filesystem but it's "busy" (an application or service is detected using the filesystem), then the request will fail like the following:

```
$ sudo fsadm -e resize xvdb
Device does not exist.
Command failed
Do you want to unmount "/data"? [Y|n] n
fsadm: Cannot proceed with mounted filesystem "/data".
[ec2-user@ip-172-31-5-248 ~]$ sudo fsadm -e -v resize xvdb
fsadm: "ext4" filesystem found on "/dev/xvdb".
fsadm: Device "/dev/xvdb" size is 13958643712 bytes
Device does not exist.
Command failed
fsadm: Parsing tune2fs -l "/dev/xvdb"
fsadm: resize2fs needs unmounted filesystem
Do you want to unmount "/data"? [Y|n] y
fsadm: Executing umount /data
umount: /data: target is busy.
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))
fsadm: Cannot proceed with mounted filesystem "/data".
```

Thus the "busying" process will have to be terminated.

### Procedure to terminate PostgreSQL

In the case of a service such as PostgreSQL, it can be shut down by use of a command such as `sudo systemctl stop postgresql`. (Remember to `start` it again when this is all done.)

NOTE: it's unclear whether `sudo systemctl stop postgresql` will wait until in-progress transactions are finished before shutting down the daemon.  Further research is needed, in [issue #55](https://github.com/hackoregon/civic-devops/issues/55).

### Procedure to Extend

To resize the disk using all of the newly available space use the `fsadm` command with following options:

- `–v` (verbose) 

- `–e` (unmount before resizing, if mounted)  

- `resize` 

- Device name (use the Linux device name not the AWS device name) 

e.g. `sudo fsadm –v -e resize xvdb`, which will manually prompt to unmount the filesystem - answer `Y` to proceed.  Success may resemble the following (resizing from 8GB to 13GB in this example):

```
$ sudo fsadm -v -e resize xvdb
fsadm: "ext4" filesystem found on "/dev/xvdb".
fsadm: Device "/dev/xvdb" size is 13958643712 bytes
Device does not exist.
Command failed
fsadm: Parsing tune2fs -l "/dev/xvdb"
fsadm: resize2fs needs unmounted filesystem
Do you want to unmount "/data"? [Y|n] y
fsadm: Executing umount /data
fsadm: Executing fsck -f -p /dev/xvdb
fsck from util-linux 2.23.2
/dev/xvdb: 1466/524288 files (0.3% non-contiguous), 130095/2097152 blocks
fsadm: Resizing filesystem on device "/dev/xvdb" to 13958643712 bytes (2097152 -> 3407872 blocks of 4096 bytes)
fsadm: Executing resize2fs /dev/xvdb 3407872
resize2fs 1.42.9 (28-Dec-2013)
Resizing the filesystem on /dev/xvdb to 3407872 (4k) blocks.
The filesystem on /dev/xvdb is now 3407872 blocks long.

fsadm: Remounting unmounted filesystem back
fsadm: Executing mount /dev/xvdb /data
```

Once the resize has completed, the filesystem is remounted (if previously mounted). You can also manually mount the filesystem for use using the `mount` command (e.g. `mount xvdb /data`).

Use the `df -h` command to check that the filesystem size has increased properly, e.g.

```
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        484M     0  484M   0% /dev
tmpfs           497M  4.0K  497M   1% /dev/shm
tmpfs           497M   13M  484M   3% /run
tmpfs           497M     0  497M   0% /sys/fs/cgroup
/dev/xvda1      8.0G  1.2G  6.9G  15% /
tmpfs           100M     0  100M   0% /run/user/0
tmpfs           100M     0  100M   0% /run/user/1000
/dev/xvdb        13G  256M  11.9G   2% /data
```

Note: the Size will not exactly match the size of the Volume due to space needed for filesystem overhead.

ALSO: don't forget to restart any "busying" processes that were temporarily shut down - e.g. `sudo systemctl start postgresql`
