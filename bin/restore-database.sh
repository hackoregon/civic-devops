#! /bin/sh

# Intentions:
# - Restore a single database instance from a shell session running on the PostgreSQL server

# Usage: 
# (1) Feed with parameters: 
#     $ restore-database.sh <database_instance_name> <database_user_name> <database_user_password>
# or
# (2) Use interatively (no parameters): 
#     $ restore-database.sh

# Result:
# - The database is successfully restored to the target

# Prerequisites:
# - Postgres has been configured and started
# - Admin-level permissions to the database
# - Database instance is configured with Owner access for the user context
# - The file located at $S3_BACKUP_FILE has to be a pg_dump in binary compatible
#   with the currently used Postgres version
# - This ec2 instance has permission to read from s3. 
#   To has such permission, this ec2 instance must have been launched with 
#   the flag `--iam-instance-profile Name=$INSTANCE_PROFILE_NAME `, where
#   the $INSTANCE_PROFILE_NAME is the instance profile that was once created 
#   by running `create-instance-profile.sh`

DATABASE_NAME=
USERNAME=
PASSWORD=
DATABASE_SERVER= # e.g. ec2-34-214-158-132.us-west-2.compute.amazonaws.com
LOCAL_BACKUP_FILE= # e.g. './passenger_census.backup'
S3_BACKUP_FILE= # e.g. 's3://luukh/test1/passenger_census.backup'

# Get parameters from user
if [ "$#" -eq 5 ]; then
	# Running with 5 arguments
	DATABASE_NAME=$1
	USERNAME=$2
	PASSWORD=$3
    DATABASE_SERVER=$4 
    S3_BACKUP_FILE=$5 
elif [ "$#" -eq 0 ]; then
	# Running interatively (no arguments)
    read -p "Database server name: " DATABASE_SERVER
	read -p "Database instance name: " DATABASE_NAME
	read -p "Username: " USERNAME
    read -p "backup file path and name: " S3_BACKUP_FILE
else
	echo "Error: Must be 0 or 5 parameters"
	echo 'Usage:'
	echo '(1) Feed with parameters: sudo create-db.sh <database_instance_name> <database_user_name> <database_user_password>'
	echo 'or (2) Use interatively (no parameters): sudo create-db.sh'
	exit 1
fi

echo "Downloading $S3_BACKUP_FILE to $LOCAL_BACKUP_FILE"
aws s3 cp $S3_BACKUP_FILE $LOCAL_BACKUP_FILE
if [ $? != 0 ]; then
    echo 'Downloading failed'
    exit 1
done
echo

echo 'Downloaded file size: '
ls -l --block-size=M $LOCAL_BACKUP_FILE

echo "Restoring backup file to $DATABASE_NAME..."
#sudo -u postgres createuser --encrypted --pwprompt --no-createdb --no-createrole --no-superuser --no-replication $USERNAME
sudo -u postgres pg_restore \
    --host $DATABASE_SERVER \
    --port "5432" \
    --username $USERNAME \
    --no-password \
    --dbname $DATABASE_NAME \
    --verbose \
    $LOCAL_BACKUP_FILE
