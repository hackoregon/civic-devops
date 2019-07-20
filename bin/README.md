# Expected Usage of these scripts

* **build-and-install-PostGIS.sh**: after installing PostgreSQL in your EC2 VM, run this script from an SSH shell (as root - run `sudo su -` before launching the script) to add PostGIS and the common dependencies needed for HackOregon projects, so that subsequent databases added to the server can take advantage of typical GIS functionality
* **create-database-development.sh**: after creating an EC2 VM , run this script from an SSH shell into the VM to install and configure the PostgreSQL database service
* **create-db.sh**: after installing PostgreSQL database service, configured and running, run this script from an SSH shell on the VM to create each new database instance (note: if your database instance requires PostGIS, run `build-and-install-PostGIS.sh` before restoring the database or generating the database schema)
* **create-ec2-machine-database.sh**: run this script from a local \*NIX (Mac, Linux or Ubuntu on Win10) shell, where `awscli` is installed and AWS credentials are available, to create a new EC2 VM from the input `profile.sh` configuration
* **ec2-profile-database-development.sh**: use this script as the `profile.sh` input configuration for the `create-ec2-machine-database.sh` script, to create the central PostgreSQL database host for Hack Oregon's 2018 project season
* **ssm-parameters-upload.py**: run this script to upload a bulk array of new SSM Parameter Store parameters
* **upload-and-ssh-into-ec2.sh**: run this script to `scp` all files in the current directory and `ssh` into the designated SSH-enabled host

Order of operations, from scratch:
1. **create-ec2-machine-database.sh** - create an EC2 VM (using **ec2-profile-database-development.sh** to set the unique settings for this database)
2. **upload-and-ssh-into-ec2.sh** - uploads all scripts to EC2 VM
3. **create-database-development.sh** - installs and configures PostgreSQL database service
4. **build-and-install-PostGIS.sh** - adds PostGIS functionality to PostgreSQL
5. **create-db.sh** - creates individual database instances on the PostgreSQL/PostGIS service
6. **grant-readonly-access-for-PostgreSQL-user.sh** - takes an additional read-only psql user and grants it only read-only access to the specified database

## ssm-parameters-upload.py

Imports an arbitrary set of SSM parameters into AWS Parameter Store, both String and SecureString parameters.  Does not overwrite existing SSM parameters.

Script expects comma delimiter by default, but can be trivially changed by modifying the `delimiter_character` variable.

### Prerequisites

* the `awscli` must be installed locally on the host
* user must have AWS credentials sufficient to write to the AWS SSM parameter store

### Required Inputs

* `--file` = path and name of CSV file
* `--keyid` = the key-id for encrypting SecureString SSM parameters
* `--region` = the AWS region in which the parameters will be stored

### CSV file requirements

File must contain a header row with four columns (in any order):

* NamespacePrefix (e.g. `/staging/2019-sandbox`)
* Parameter (e.g. `POSTGRES_HOST`)
* Type (either `String` or `SecureString`)
* Value (e.g. `rdshostname1.randomsubdomain.us-west-2.rds.amazonaws.com`)
