#! /bin/sh

# Restore a single database instance from a shell session running on the PostgreSQL server
# Usage: 
# (1) Feed with parameters
# or
# (2) Use interatively (no parameters)

# Result:
# - The database is successfully restored to the target instance

# Prerequisites:
# - Postgres has been configured and started
# - Admin-level permissions to the database
# - Database instance is configured with Owner access for the user context

if [ "$#" -eq 5 ]; then
	# Running with 5 arguments
	DATABASE_NAME=$1
	USERNAME=$2
	PASSWORD=$3
    DATABASE_SERVER=$4
    BACKUP_FILE=$5

    sudo -u postgres pg_restore \
         --host $DATABASE_SERVER \
         --port "5432" \
         --username $USERNAME \
         --no-password \
         --dbname $DATABASE_NAME \
         --verbose \
         $BACKUP_FILE

elif [ "$#" -eq 0 ]; then
	# Running interatively (no arguments)
    read -p "Database server name: " DATABASE_SERVER
	read -p "Database instance name: " DATABASE_NAME
	read -p "Username: " USERNAME
    read -p "backup file path and name: " BACKUP_FILE
	echo "Restoring backup file to $DATABASE_NAME - prompts for password..."
#	sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $USERNAME
    sudo -u postgres pg_restore \
         --host $DATABASE_SERVER \
         --port "5432" \
         --username $USERNAME \
         --no-password \
         --dbname $DATABASE_NAME \
         --verbose \
         $BACKUP_FILE

else
    # TODO: clean up this branch
	echo "Error: Must be 0 or 3 parameters"
	echo 'Usage:'
	echo '(1) Feed with parameters: sudo create-db.sh <database_instance_name> <database_user_name> <database_user_password>'
	echo 'or (2) Use interatively (no parameters): sudo create-db.sh'
	exit 1
fi
