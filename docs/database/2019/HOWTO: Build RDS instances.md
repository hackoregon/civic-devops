# HOWTO Build RDS instances (for 2019 project season)

Summary: these are the manual RDS-instantiation instrux that will form the basis for CloudFormation automation of each 2019 project's databases.

## Background

In the 2019 Hack Oregon project season, we will be using per-project RDS instances for hosting both the staging and production databases.

Per-project - rather than a centralized database instance shared by all databases - because at the outset of the 2019 project season, there was more uncertainty than usual about the size or compute-resource requirements for each 2019 project.

Staging vs. Production - rather than a single layer for full-season usage - because we assume that we'll get around to the laborious and expensive task of standing up a production-ready, well-protected API-to-DB layer - a less-free-for-all infrastructure for Django-to-DB compute than we've had in the past (despite all good intentions).

## Procedure

1. Create an RDS instance with the following shared characteristics (suitable for staging aka "development" work):
** engine = PostgreSQL
** Use Case = dev/test
** DB engine version = PostgreSQL 11.2-R1
** DB instance class = db.t2.small
** Multi-AZ deployment = No
** Storage type = General purpose (SSD)
** Allocated storage = 100 GB
** Virtual Private Cloud = Default VPC
** Public accessibility = yes (note: will be "no" for production DBs, production databases can only be accessed via the related Django container in ECS production deploy)
** Availability zone = no preference
** VPC security groups = hacko-public-database (note: will be more restrictive for production DBs)
** IAM DB authentication = Disable
** Encryption = Enable
** Master key = (default) aws/rds
** Backup retention period = 7 days
** Backup window = no preference
** Enhanced monitoring = Enable enhanced monitoring
** Performance insights = Enable performance insights, retention period = 7 days, Master key = (default) aws/rds
** Log exports = Postgresql log
** Auto minor version upgrade = Enable auto minor version upgrade
** Maintenance window = No preference
** Deletion protection = Enable delete protection
2. Create a login role according to the naming conventions e.g. `transportation2019` - which has following privileges:  Can login, Create databases, Inherit rights from the parent roles
3. Create the database according to the https://docs.google.com/spreadsheets/d/147thL899Bf8IL3ma1S9XBrNXL2xYsIRM5mE-3fceIcQ/ naming scheme
4. Assign the created login role as the Owner of the DB
** note: in AWS RDS, the role creating the database must have the role which will be owner of the database being created: https://stackoverflow.com/a/34898033
5. Execute the following command in the new DB using the Query Tool or other SQL automation:
`CREATE EXTENSION postgis;`
** Even better: add the `postgis` extension to the `template1` database, so that all new databases will automatically get it: _(TBD)_
6. If you need add another role with read-only privileges to the DB, use the script in *HOWTO-enable-readonly-database-user* or similar.

## Other troubleshooting notes

- Check which extensions are enabled for each database - connect to the database and run `SELECT * FROM pg_extension;`
