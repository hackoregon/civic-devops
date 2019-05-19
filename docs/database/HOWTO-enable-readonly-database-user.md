# How To Enable a read-only database user on an existing PostgreSQL database

## Driven by Script

Uses `grant-readonly-access-for-PostgreSQL-user.sh`.

### Prereqs for the Script

Create the read-only user account in PostgreSQL using pgAdmin or psql.

e.g. Run the following command from an interactive shell on your database server to create the read-only user needed for the script (NOTE we still don't have the escaping correct for the PASSWORD variable):

`sudo -u postgres psql -c 'ALTER USER "useraccount-readonly" ENCRYPTED PASSWORD "StrongPassword"'`

### Script usage

e.g. `sudo -u postgres ./grant-readonly-access-for-PostgreSQL-user.sh --user backend-exemplar-readonly --database backend-exemplar`

--user is the name of the read-only user

--database is the name of the database to which the user is to be granted read-only access

## Manual Approach

https://stackoverflow.com/questions/13497352/error-permission-denied-for-relation-tablename-on-postgres-while-trying-a-selec

### Assumptions

This example assumes that:

- database name = "avengers-secret-hideouts"
- read-only database user = "shield-agent-level6"
- the read-only database user has already been created (e.g. using PgAdmin)
- the read-only database user has default privileges on the server, except has been granted the privilege to Login
- the read-only database user will have read access to the target database
- the read-only database user will end up with only the minimum permissions to the rest of the databases

### Commands

First enter the interactive `psql` shell:
```shell
sudo -u postgres psql
```

Then run the SQL commands:
```SQL
GRANT USAGE ON SCHEMA public to "shield-agent-level6";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "shield-agent-level6";

GRANT CONNECT ON DATABASE "avengers-secret-hideouts" to "shield-agent-level6";
\c avengers-secret-hideouts
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "shield-agent-level6";
GRANT USAGE ON SCHEMA public to "shield-agent-level6";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "shield-agent-level6";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "shield-agent-level6";
```

Note: don't forget the `\c` command in the middle - that switches context to the selected database, so that all `SCHEMA public` references are explictly towards the selected database and not just "into the ether".
