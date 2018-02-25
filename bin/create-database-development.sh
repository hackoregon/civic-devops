#! /bin/sh
# Creates the PostgreSQL database server to host all 2018 Hack Oregon season project's databases
# TODO: declare the yum package as a variable up front for visibility

sudo yum update -y
sudo amazon-linux-extras install postgresql9.6 # enables postgres9.6 install on Amazon Linux 2
sudo yum install postgresql.x86_64 postgresql-server.x86_64 # aliases to postgresql 9.6.6-1.amzn2.0.1 as of 2018-02-25

mkdir /data/databases # Create data_directory
sudo chown postgres /data/databases

# sudo service postgresql96 initdb --pgdata=/data/databases # I believe this worked on Amazon Linux (not AL "2")
sudo -u postgres initdb --pgdata=/data/databases
sudo service postgresql96 start # errors out - 'Directory "/var/lib/pgsql/data" is missing or empty.''

# Note: this should prompt for console input to set the 'postgres' OS account password
# <<EXPECT CONSOLE INPUT>>
sudo -u postgres passwd

# TODO: set the password for the 'postgres' database account
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'newpassword';"
# -OR-
sudo -u postgres psql --command '\password postgres'

# Create databases and their roles
# NOTE: the dbname will always be the project name + data purpose
# e.g. createdb -O transportation-systems transportation-systems-conflicts
# Note: this should prompt for console input to set each database role's password

# 2018 disaster-resilience project
ROLENAME="disaster-resilience"
DBNAME_SUFFIX=""
# <<EXPECT CONSOLE INPUT>>
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 housing-affordability project
ROLENAME="housing-affordability"
DBNAME_SUFFIX=""
# <<EXPECT CONSOLE INPUT>>
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 local-elections project
ROLENAME="local-elections"
DBNAME_SUFFIX=""
# <<EXPECT CONSOLE INPUT>>
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 transportation-systems project
ROLENAME="transportation-systems"
DBNAME_SUFFIX=""
# <<EXPECT CONSOLE INPUT>>
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}

# 2018 urban-development project
ROLENAME="urban-development"
DBNAME_SUFFIX=""
# <<EXPECT CONSOLE INPUT>>
sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $ROLENAME
sudo -u postgres createdb -O $ROLENAME ${ROLENAME}-${DBNAME_SUFFIX}
