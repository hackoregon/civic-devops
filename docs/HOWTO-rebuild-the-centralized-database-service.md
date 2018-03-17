# HOWTO: Rebuild the Centralized Database service

This set of scripts and procedures is how we built the PostgreSQL database service for the 2018 Hack Oregon projects.

1. Build an EC2 machine
2. Install and configure PostgreSQL
3. Create users and databases
4. Restore databases from backup
5. Extend the EBS data volume for new databases

## Build an EC2 machine

This procedure relies on the `create-ec2-machine-database.sh` script:

* Prereq: run the script from an environment where AWS keys are available and the keys grant EC2 machine creation privileges
* Prereq: the [awscli](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) is installed
* Step 1: edit any of the VARIABLES to match your intended EC2 virtual machine environment, especially the KEYNAME
* Step 2: run `./create-ec2-machine-database.sh NAME_OF_RESULTING_MACHINE`, where NAME_OF_RESULTING_MACHINE will be used to populate the AWS "Name" tag of the machine

## Install and configure PostgreSQL

NOTE: "development" is meant to signify this was the build for a development, not a production, instance of the database.
This procedure relies on the `create-database-development.sh` script that runs on the server:

* Prereq: an EC2 machine has already been built
* Assumption: no database service has been installed or configured on the machine
* Prereq: the AWS "amazon-linux-extras" repo is available, and the version of PostgreSQL installed is the Amazon Linux package
* Step 1: edit any of the VARIABLES to match your intended PostgreSQL service and environment
* Step 2: run `./create-database-development.sh` with no parameters
* Step 3: fill in the `postgres` database user password when prompted

## Create users and databases

This procedure relies on the `create-db.sh` script that runs on the PostgreSQL server

* Prereq: PostgreSQL has been configured successfully and is running
* Prereq: run the script from within the machine that hosts the targeted PostgreSQL service
* Prereq: run the script from a shell where `sudo -u postgres` will silently succeed
* Step 1: decide upon the name of the database instance, name of database user who will own that instance, and password for that user
* Step 2: `scp` the script to the server and `ssh` in as `ec2-user` (or equivalent)
* Step 3: run `./create.db.sh` with no parameters (or alternatively, feed the values from Step 1 in as the correct parameters)
* Step 4: fill in the database user password when prompted (if running interactively)

## Restore databases from backup

This procedure relies on stepwise commands run on the PostgreSQL server to restore database data to an empty database instance.

There are two scenarios: `.backup` file that was generated from `pgdump` native format, or `.sql.gz` file that was generated from `pgdump` in "compressed SQL" format

### Restore from .sql.gz

* Prereq: database instance has been created
* Prereq: named database user is owner of the target database instance
* Prereq: backup has been created from instance with the same database user name and database instance name
* Step 1: `ssh` into the machine hosting the PostgreSQL service as `ec2-user` (or equivalent)
* Step 2: run wget to download the backup file e.g. `wget https://s3-us-west-2.amazonaws.com/hacko-data-archive/2018-transportation-systems/data/interim/passenger_census.backup`
* Step 3: run `gzip -dc BACKUP_FILE.sql.gz | sudo -u postgres psql`
* Step 4: test that the restore succeeded (i.e. the database is not still empty) by running `sudo -u postgres psql -d [DATABASE_INSTANCE] -c 'SELECT COUNT(*) FROM [DATABASE_INSTANCE/TABLE_NAME];'` where [DATABASE_INSTANCE] is the database instance name e.g. `sudo -u postgres psql -d passenger_census -c 'SELECT COUNT(*) FROM passenger_census;'`
* Note: the test command should result in a non-zero count

# Extend the EBS data volume for new databases

EBS volumes are allocated statically for EC2 machines - that is, if you need to allow your data files to grow to 500GB, then you need to explicitly allocate 500GB to the EBS volume housing those data files.

Since EBS space isn't free, Hack Oregon is working to allocate only as much space as is needed for the existing databases.  When a new database instance is added, chances are the EBS volume needs to be "grown" to accommodate the new space requirements.

(Procedure document forthcoming from Ian )