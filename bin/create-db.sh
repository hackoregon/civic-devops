#! /bin/sh

# Creates database instances one at a time.
# Usage: 
# (1) Feed with parameters: sudo create-db.sh <database_instance_name> <database_user_name> <database_user_password>
# or (2) Use interatively (no parameters): sudo create-db.sh

# Result:
# - The database is successfully created with the name, database user and password
# - The database user has Owner rights to the database
# 

# Prerequisites:
# - Postgres has been configured and started
# - Admin-level permissions to the database
# 

# TODO: 
# 1. make password secure
# 2. investigate PostgreSQL Roles to determine if there's any advantage over assigning ownership to the Database

DB_NAME=
USERNAME=
PASSWORD=

if [ "$#" -eq 3 ]; then
	# Running with 3 arguments
	DB_NAME=$1
	USERNAME=$2
	PASSWORD=$3
	SET_PWD_COMMAND="\"ALTER USER ${USERNAME} ENCRYPTED PASSWORD \'${PASSWORD}\';\""
	sudo -u postgres createuser --encrypted --no-createdb --no-createrole --no-superuser --no-replication $USERNAME
	sudo -u postgres psql -c ${SET_PWD_COMMAND}
elif [ "$#" -eq 0 ]; then
	# Running interatively (no arguments)
	echo 'NOTE: the database naming convention is (without bracket): <the project name>-<data purpose>'
	read -p "Database name: " DB_NAME
	read -p "Username: " USERNAME
	echo "Creating DB $DB_NAME user $USERNAME - prompts for password..."
	sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $USERNAME
else
	echo "Error: Must be 0 or 3 parameters"
	echo 'Usage:'
	echo '(1) Feed with parameters: sudo create-db.sh <database_instance_name> <database_user_name> <database_user_password>'
	echo 'or (2) Use interatively (no parameters): sudo create-db.sh'
	exit 1
fi

sudo -u postgres createdb -O $USERNAME $DB_NAME
#echo -e 'host ' ${DBNAME_FULL} ' ' ${ROLENAME} ' 0.0.0.0/0 md5' | sudo tee -a ${DATA_DIRECTORY}/pg_hba.conf
