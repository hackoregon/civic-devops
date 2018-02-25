#! /bin/sh
# Creates the PostgreSQL database server to host all 2018 Hack Oregon season project's databases
# Usage: scp this file to [ec2_machine_DNS:~ then run script as ec2user]

POSTGRES_PACKAGE="postgresql9.6"

sudo yum update -y
sudo amazon-linux-extras install $POSTGRES_PACKAGE # enables postgres9.6 install on Amazon Linux 2
sudo yum install postgresql.x86_64 postgresql-server.x86_64 # aliases to postgresql 9.6.6-1.amzn2.0.1 as of 2018-02-25

DATA_DIRECTORY="/data/databases" # Assumes secondary volume is mounted as /data

sudo mkdir $DATA_DIRECTORY
sudo chown postgres $DATA_DIRECTORY

echo "Initializing PostgreSQL..."
# sudo service postgresql96 initdb --pgdata=/data/databases # This is the usual documented approach but doesn't work in Amazon Linux 2
#sudo -u postgres initdb --pgdata=$DATA_DIRECTORY
sudo -u postgres postgresql-setup --initdb --datadir $DATA_DIRECTORY

echo "Starting PostgreSQL..."
sudo service postgresql start # errors out - 'Directory "/var/lib/pgsql/data" is missing or empty.''

# TODO: determine if we need to configure the service to start automatically, and if 'service' is preferred over 'systemctl'
# systemctl enable postgresql.service

# TODO: is it *less* secure to set a password for this account?
echo "Setting password for OS account postgres..."
sudo -u postgres passwd

# TODO: set the password for the 'postgres' database account

# This approach is untested
#read -p "Setting password for DB user postgres - type in the password:" DB_password
#sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$DB_password';"

# -OR-
sudo -u postgres psql --command '\password postgres'

# Create databases and their roles
# NOTE: the database naming convention is the project name + data purpose
# e.g. createdb -O transportation-systems transportation-systems-conflicts

# 2018 disaster-resilience project
ROLENAME="disaster-resilience"
DBNAME_SUFFIX=""
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 housing-affordability project
ROLENAME="housing-affordability"
DBNAME_SUFFIX=""
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 local-elections project
ROLENAME="local-elections"
DBNAME_SUFFIX=""
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 transportation-systems project
ROLENAME="transportation-systems"
DBNAME_SUFFIX=""
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 urban-development project
ROLENAME="urban-development"
DBNAME_SUFFIX=""
echo "Creating DB user $ROLENAME - prompts for password..."
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}
