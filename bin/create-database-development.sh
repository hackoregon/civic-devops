#! /bin/sh
# Creates the PostgreSQL database server to host all 2018 Hack Oregon season project's databases
# Usage: scp this file to [ec2_machine_DNS:~ then run script as ec2user]
# 
# Prerequisites:
# This EC2 instance is created with an Amazon Linux 2 AMI
# EC2 instance is created from scratch, not a pre-existing server, so EBS volume named /dev/sdb should never collide
# AWS 'amazon-linux-extras' package repo is available
# EBS volume mounted as `/data` is available in which to store all databases


DATA_DIRECTORY="/data/postgresql/databases" #two directories deep to avoid PostgreSQL "direct mountpoint" warning - see http://www.postgresql.org/docs/9.6/static/creating-cluster.html
DATABASE_SERVICE="postgresql"
DEVICE_NAME="/dev/sdb" # Assume the EBS volume is configured as /dev/sdb
MOUNT_POINT="/data"
POSTGRES_OVERRIDE_DIRECTORY="/etc/systemd/system/postgresql.service.d" # Location of override.conf
POSTGRES_PACKAGE="postgresql9.6" # package installed from amazon-linux-extras repo


echo 'Installing PostgreSQL packages...'
sudo yum update -y
sudo amazon-linux-extras install $POSTGRES_PACKAGE # enables postgres9.6 install on Amazon Linux 2
sudo yum install postgresql.x86_64 postgresql-server.x86_64 -y # aliases to postgresql 9.6.6-1.amzn2.0.1 as of 2018-02-25

echo 'Mounting EBS volume '"$DEVICE_NAME"' as '"$MOUNT_POINT..."
sudo mkfs -t ext4 $DEVICE_NAME
sudo mkdir $MOUNT_POINT
sudo mount -t ext4 $DEVICE_NAME $MOUNT_POINT

echo 'Creating properly-configured $PGDATA data_directory...'
sudo mkdir $DATA_DIRECTORY
# PostgreSQL requires the $PGDATA directory to have exclusive ownership and access
sudo chown -R postgres:postgres $DATA_DIRECTORY
sudo chmod 700 $DATA_DIRECTORY

# 'systemctl edit postgresql.service' runs interactively - this approach commits changes to the file without interaction
echo 'Configuring override.conf to use the non-default data_directory...'
sudo mkdir $POSTGRES_OVERRIDE_DIRECTORY
echo '' | sudo tee -a $POSTGRES_OVERRIDE_DIRECTORY/override.conf # https://superuser.com/questions/136646/how-to-append-to-a-file-as-sudo#136653 explains how 'tee' enables write permission as the non-shell user
echo '[Service]' | sudo tee -a $POSTGRES_OVERRIDE_DIRECTORY/override.conf
echo 'Environment=PGDATA='$DATA_DIRECTORY | sudo tee -a $POSTGRES_OVERRIDE_DIRECTORY/override.conf
sudo systemctl daemon-reload # reload systemd to read in override.conf

cd / # necessary to work around a permissions issues between sudo and the /home/ec2_user directory

echo "Initializing PostgreSQL..."
sudo /usr/bin/postgresql-setup --initdb --unit postgresql

echo "Configuring PostgreSQL to listen for all incoming IP addresses..."
echo '' | sudo tee -a ${DATA_DIRECTORY}/postgresql.conf
echo '# Overriding default listener behaviour via build script' | sudo tee -a ${DATA_DIRECTORY}/postgresql.conf
echo "listen_addresses = '*'" | sudo tee -a ${DATA_DIRECTORY}/postgresql.conf

echo "Enabling all database users to login from all IP addresses..."
echo -e 'host all all 0.0.0.0/0 md5' | sudo tee -a ${DATA_DIRECTORY}/pg_hba.conf

echo "Enabling PostgreSQL service to be persistent..."
sudo systemctl enable ${DATABASE_SERVICE}.service # 'sudo service $DATABASE_SERVICE enable' doesn't work here

echo "Starting PostgreSQL..."
sudo service $DATABASE_SERVICE start

echo "Setting password for postgres database account..."
sudo -u postgres psql --command '\password postgres'

# Create databases and their roles
# NOTE: the database naming convention is the project name + data purpose
# e.g. createdb -O transportation-systems transportation-systems-conflicts
# TODO: investigate PostgreSQL Roles to determine if there's any advantage over assigning ownership to the Database

# Database(s) for 2018 disaster-resilience project
ROLENAME="disaster-resilience"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL
#echo -e 'host ' ${DBNAME_FULL} ' ' ${ROLENAME} ' 0.0.0.0/0 md5' | sudo tee -a ${DATA_DIRECTORY}/pg_hba.conf

# Database(s) for Project: 2018 housing-affordability project
ROLENAME="housing-affordability"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL

# Database(s) for 2018 local-elections project
ROLENAME="local-elections"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL

# Database(s) for 2018 transportation-systems project
ROLENAME="transportation-systems"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL

# Database(s) for 2018 urban-development project
ROLENAME="urban-development"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL


echo "HUP the database service in case any .conf files were altered since last start..."
sudo -u postgres pg_ctl reload --pgdata=${DATA_DIRECTORY} # sends SIGHUP to postgres server
