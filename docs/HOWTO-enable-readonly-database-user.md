# How To Enable a read-only database user on an existing PostgreSQL database

https://stackoverflow.com/questions/13497352/error-permission-denied-for-relation-tablename-on-postgres-while-trying-a-selec

Assume:

- database name = "local-elections-finance"
- read-only database user = "local-elections-readonly"
- the database user has already been used

## Commands

This example assumes that

- we have already created the database user "local-elections-readonly"
- the user has login privileges but no other non-default privileges on the database server
- the user will be granted read-only privileges on database "local-elections-finance"

```shell
sudo -u postgres psql
```

```SQL
GRANT USAGE ON SCHEMA public to "local-elections-readonly";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "local-elections-readonly";

GRANT CONNECT ON DATABASE "local-elections-finance" to "local-elections-readonly";
\c foo
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "local-elections-readonly"; --- this grants privileges on new tables generated in new database "foo"
GRANT USAGE ON SCHEMA public to "local-elections-readonly";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "local-elections-readonly";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "local-elections-readonly";
```
