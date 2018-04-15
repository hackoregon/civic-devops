# Expected Usage of these scripts

* **create-database-development.sh**: once an EC2 VM is available, run this script from an SSH shell into the VM to install and configure the PostgreSQL database service
* **create-db.sh**: once a PostgreSQL database service is installed, configured and running, run this script from an SSH shell on the VM to create a new database instance
* **create-ec2-machine-database.sh**: run this script from a local *NIX (Mac, Linux or Ubuntu on Win10) shell, where `awscli` is installed and AWS credentials are available, to create a new EC2 VM from the input `profile.sh` configuration
* **ec2-profile-database-development.sh**: this script is used as the `profile.sh` input configuration for the `create-ec2-machine-database.sh` script, to create the central PostgreSQL database host for Hack Oregon's 2018 project season
* **upload-and-ssh-into-ec2.sh**: run this script to `scp` all files in the current directory and `ssh` into the designated SSH-enabled host
