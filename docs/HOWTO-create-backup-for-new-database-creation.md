# HOWTO create a backup for new database creation

When standing up a new database instance, the project team must submit that data in a specified format so that the database automation we support can ingest the initial data load.  The currently-supported procedures for initial data load are [here](https://github.com/hackoregon/civic-devops/blob/master/docs/HOWTO-rebuild-the-centralized-database-service.md#restore-databases-from-backup)

## Requirements

These are the current requirements for submitting a database backup to the Hack Oregon DevOps squad that can be successfully used to perform the initial load of a new database instance.

1. Coordinate with the Hack Oregon DevOps squad to finalize the name of the database instance and acquire the username that will own that database instance (e.g. a project named mars-space-flight might have two databases, mars-space-flight-surface-lander and mars-space-flight-liftoff).


2. The current required format for database backups is compressed plain-text, and the current supported version of PostgreSQL at this time is 9.6.6 (latest supported on Amazon Linux 2). Other formats are sometime incompatible with PostgreSQL servers at the same release or newer. Note that database backups are not designed to be restored to older versions of PostgreSQL - e.g. don't take a backup from 10.3 and expect it to restore to 9.6.

    A plain-text backup is SQL code with some `psql` commands mixed in, You can read it with a text editor. A compressed plain text backup can be read if you uncompress it first.
3. A database on the source server should have the same owner name as it will have on the destination server. All the objects in the database should have that owner name too. This means the user / role must exist on the source when the backup is created and on the destination before it is restored.

    You can change owners of databases and the objects they contain with SQL script like the following:

    ```
    ALTER DATABASE odot_crash_data OWNER TO "transportation-systems";
    REASSIGN OWNED BY znmeb TO "transportation-systems";
    ```

    Note: the double quotes are required because of the hyphen in the new owner's name.
4. Command to create a compressed text backup:

    ```
    pg_dump -Fp -v -C -c --if-exists -d <database> \
    | gzip -c > <database>.sql.gz
    ```

    `<database>` is the database. Run this as the database superuser `postgres` on Linux. The parameters:
    * `-Fp`: plain text format
    * `-v`: verbose
    * `-C -c`: create a clean new database. This is done by DROPping the database objects. If they doesn't exist, the DROP will error, so ...
    * `--if-exists`: don't DROP if it doesn't exist. You'll get a `NOTICE` instead of an `ERROR` and the restore will continue!
5. Command to restore the compressed backup:

    ```
    gzip -dc <database>.sql.gz | psql -v ON_ERROR_STOP=1
    ```

    Run this as the database superuser `postgres`. As noted above, the owners of all the objects on the backup file must exist in the destination server or the restore will fail.
6. Did it work? Usually you'll see `Restore completed` at the end of a successful restore. The `ON_ERROR_STOP=1` option will force `psql` to stop on its first error.
7. The latest release of `data-science-pet-containers` has an option to do restore testing on an Amazon Linux 2 container running PostgreSQL from Amazon Linux Extras. See <https://github.com/hackoregon/data-science-pet-containers#amazon>

## Need Help?
If you need help generating compatible backups from your development data, please post your questions to the #chat-databases channel on the [Hack Oregon 2018 Slack group](https://hackoregon2018.slack.com).
