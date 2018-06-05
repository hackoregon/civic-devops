#!/bin/bash -e 

set -o errexit
set -o pipefail
set -u

function usage() {
    set -e
    cat <<EOM
    ##### grant-readonly-access-for-PostgreSQL-user #####
    Crude script to grant read access for a non-owner PostgreSQL user to a database
    Required arguments:
        --user          Database user which requires read-only access to the specified database
        --database      Database to which the specified user will have read-only access
    Requirements:
        1. The 'pqsl' binary must be installed and on the current \$PATH
        2. This script must be run as user postgres
        3. This script must be run from a shell local to the server running PostgreSQL

    Example:
      sudo -u postgres ./$0 --user "shield-agent-readonly" --database "shield-bases"
EOM

    exit 2
}

if [ $# == 0 ]; then usage; fi

# Loop through arguments, two at a time for key and value
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        --user)
            DATABASE_USER="$2"
            shift # past argument
            ;;
        --database)
            DATABASE_TARGET="$2"
            shift # past argument
            ;;
        *)
            usage
            exit 2
        ;;
    esac
    shift # past argument or value
done


# TODO: 
# create input parameters for --user and --database

echo "Granting read-only access for database user '$DATABASE_USER' to database '$DATABASE_TARGET'"

command1="GRANT USAGE ON SCHEMA public to \"$DATABASE_USER\";"
psql --command "$command1"

command2="ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"$DATABASE_USER\";"
psql --command "$command2"

command3="GRANT CONNECT ON DATABASE \"$DATABASE_TARGET\" to \"$DATABASE_USER\";"
psql --command "$command3"

command4="\c \"$DATABASE_TARGET\""
psql --command "$command4"

command5="ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"$DATABASE_USER\";"
psql --command "$command5"

command6="GRANT USAGE ON SCHEMA public to \"$DATABASE_USER\";"
psql --command "$command6"

command7="GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO \"$DATABASE_USER\";"
psql --command "$command7"

command8="GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"$DATABASE_USER\";"
psql --command "$command8"

echo ""
echo "database user '$DATABASE_USER' has been granted read-only access to database '$DATABASE_TARGET'"
