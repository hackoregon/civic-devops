# Procedure to increase the size of EBS Volume (disk)

Login to AWS account as an Admin user and click on drop down for **Services** in upper left of console.

Select **EC2** under **Compute** and when EC2 dashboard appears, select **Volumes** under the “**Elastic Block Store**” from the left side column.

On the Volumes page select the Volume you want to increase the size of and under **Description Tab** note the current size, state and “**Attachment information**”. If the Volume is not attached to a system, the attachment information will be blank, if attached will have something like this (*i-05a53808f9f20874d (EBStest):/dev/sdd (attached)*). The information will show the Instance ID and name tag (if there is a tag) of the system. You will need the public IP address and private key to SSH into the system.

The size of the volume can be increased without unmounting the filesystem or detaching the Volume or stopping the Instance. However it is good practice to create a snapshot of the Volume before changing the size and extending the filesystem.

With the Volume selected on the AWS console, click the “**Actions**” drop down in the upper right. In the drop down select “**Modify Volume**”. Set the new size and click the “**Modify**” button. In the Description tab of the Volume it will show the state of the operation (you may need to refresh the screen (circular arrows in to right of screen) to see the current status. When the operation has completed, the filesystem can be extended.

To extend the filesystem, `SSH` into the Instance the Volume is attached to and use the `sudo su` command to have the proper permissions or run commands remotely using `SSH`  (IE. `ssh -i ec2-key.pem  ec2-user@xx.xx.xx.xx  'lsblk'`).  The -i argument specifies the path to the secret key file for the key used with the ec2 instance. The <user>@<xx.xx.xx.xx> is the user and IP address of the instance and the command to run is the item in the single quotes.

Run the `lsblk` command with no arguments  and locate the information for the attached Volume (note, Linux may have remapped the device name so it may not match the device name from the Volume “Attachment information” from the AWS console)

The `lsblk` information will indicate the Linux device name, the mount point (IE. /data/pgdata) and if it is an entire disk or partitioned. If the Volume is partitioned you will need to use the `gdisk` command to extend the partition before extending the filesystem. For now we will assume it is not partitioned and the filesystem will be increased to use the entire space of the Volume.

To resize the disk using all of the newly available space use the `fsadm` command with following options 

- –v (verbose) 


- –e (unmount before resizing, if mounted)  


- resize  


- Device name (use the Linux device name not the AWS device name) 

(IE. `fsadm –v  -e  resize  /dev/sdf`)  

Once the resize has completed, the filesystem is remounted (if previously mounted) or can be manually mounted for use using the `mount` command (IE. `mount /dev/sdf /data/pgdata`).

Use the `lsblk` command to check the filesystem size has increased properly, it will not exactly match the size of the Volume due to space needed for filesystem overhead.