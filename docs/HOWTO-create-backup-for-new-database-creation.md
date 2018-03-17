# HOWTO create a backup for new database creation

When standing up a new database instance, the project team must submit that data in a specified format so that the database automation we support can ingest the initial data load.  The currently-supported procedures for initial data load are [here](https://github.com/hackoregon/civic-devops/blob/master/docs/HOWTO-rebuild-the-centralized-database-service.md#restore-databases-from-backup)

## Requirements

These are the current requirements for submitting a database backup to the Hack Oregon DevOps squad that can be successfully used to perform the initial load of a new database instance.

* Coordinate with the Hack Oregon DevOps squad to finalize the name of the database instance and acquire the username that will own that database instance
* Generate a `pgdump` backup using one of two methods:
* * the procedure that results in `.backup` file in native pgdump format
* * the procedure that generates "raw SQL" data into a `.sql` file

If you need help generating compatible backups from your development data, please post your questions to the #chat-databases channel on the [Hack Oregon 2018 Slack group](https://hackoregon2018.slack.com).