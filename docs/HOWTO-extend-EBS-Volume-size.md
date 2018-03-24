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

To extend the filesystem, you'll first have to verify which device is being extended.

### Procedure to Verify

Run the `lsblk` command with no arguments  and locate the information for the attached Volume (note: Linux may have remapped the device name, so it may not match the device name from the Volume “Attachment information” from the AWS console)

You can run commands on the EC2 Instance either locally, after `ssh` into the EC2 Instance the Volume is attached to (to get a remote shell on the Instance), or run commands remotely as parameters to an `ssh` command running locally:

- e.g. `ssh -i ec2-key.pem  ec2-user@xx.xx.xx.xx  'lsblk'`

- the `-i` argument specifies the path to the secret key file for the key used with the ec2 instance

- the `<user>@<xx.xx.xx.xx>` is the user and IP address of the Instance

- the command (e.g. `'lsblk'`) is what you're going to run on the remote Instance

The `lsblk` information will indicate the Linux device name, the mount point (e.g. `/data/pgdata`) and whether it is an entire disk or if the disk has been partitioned. For now we will assume it is not partitioned and the filesystem will be increased to use the entire space of the Volume.  If the Volume is partitioned you will need to use the `gdisk` command to extend the partition before extending the filesystem.

### Procedure to Extend

To resize the disk using all of the newly available space use the `fsadm` command with following options:

- `–v` (verbose) 

- `–e` (unmount before resizing, if mounted)  

- `resize` 

- Device name (use the Linux device name not the AWS device name) 

e.g. `fsadm –v  -e  resize  /dev/sdf`

Once the resize has completed, the filesystem is remounted (if previously mounted) or can be manually mounted for use using the `mount` command (e.g. `mount /dev/sdf /data/pgdata`).

Use the `lsblk` command to check that the filesystem size has increased properly - note: it will not exactly match the size of the Volume due to space needed for filesystem overhead.
