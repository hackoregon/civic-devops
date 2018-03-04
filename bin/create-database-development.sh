#! /bin/sh
# Creates the PostgreSQL database server to host all 2018 Hack Oregon season project's databases
# Usage: scp this file to [ec2_machine_DNS:~ then run script as ec2user]
# 
# Prerequisites:
# EC2 machine using Amazon Linux 2 AMI is already created and running
# AWS 'amazon-linux-extras' package repo is available
# EBS volume mounted as `/data` is available in which to store all databases

DATA_DIRECTORY="/data/databases" # Assumes EBS volume is mounted as /data
DATABASE_SERVICE="postgresql"
POSTGRES_OVERRIDE_DIRECTORY="/etc/systemd/system/postgresql.service.d" # Location of override.conf
POSTGRES_PACKAGE="postgresql9.6" # package installed from amazon-linux-extras repo

echo 'Installing PostgreSQL packages...'
sudo yum update -y
sudo amazon-linux-extras install $POSTGRES_PACKAGE # enables postgres9.6 install on Amazon Linux 2
sudo yum install postgresql.x86_64 postgresql-server.x86_64 # aliases to postgresql 9.6.6-1.amzn2.0.1 as of 2018-02-25

echo 'Creating properly-configured $PGDATA data_directory...'
sudo mkdir $DATA_DIRECTORY
# PostgreSQL requires the $PGDATA directory to have exclusive ownership and access
sudo chown -R postgres:postgres $DATA_DIRECTORY
sudo chmod 700 $DATA_DIRECTORY

echo 'Configuring override.conf to use the non-default data_directory...'
# 'systemctl edit postgresql.service' runs interactively, so this is an alternative to provide an override
sudo mkdir $POSTGRES_OVERRIDE_DIRECTORY
#sudo touch $POSTGRES_OVERRIDE_DIRECTORY/override.conf
# Create the override.conf file to enable postgresql.service to use non-default DATA_DIRECTORY
# NOTE: https://superuser.com/questions/136646/how-to-append-to-a-file-as-sudo#136653 explains how to gain write permission as the non-shell user
echo '' | sudo tee -a $POSTGRES_OVERRIDE_DIRECTORY/override.conf
echo '[Service]' | sudo tee -a $POSTGRES_OVERRIDE_DIRECTORY/override.conf
echo 'Environment=PGDATA='$DATA_DIRECTORY | sudo tee -a $POSTGRES_OVERRIDE_DIRECTORY/override.conf
#sudo cp --no-preserve=mode,ownership override.conf $POSTGRES_OVERRIDE_DIRECTORY
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

# 2018 disaster-resilience project
ROLENAME="disaster-resilience"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL
#echo -e 'host ' ${DBNAME_FULL} ' ' ${ROLENAME} ' 0.0.0.0/0 md5' | sudo tee -a ${DATA_DIRECTORY}/pg_hba.conf

# 2018 housing-affordability project
ROLENAME="housing-affordability"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL

# 2018 local-elections project
ROLENAME="local-elections"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL

# 2018 transportation-systems project
ROLENAME="transportation-systems"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL

# 2018 urban-development project
ROLENAME="urban-development"
DBNAME_SUFFIX=""
DBNAME_FULL=${ROLENAME}-${DBNAME_SUFFIX}
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME $DBNAME_FULL


echo "HUP the database service in case any .conf files were altered since last start..."
sudo -u postgres pg_ctl reload --pgdata=${DATA_DIRECTORY} # sends SIGHUP to postgres server
