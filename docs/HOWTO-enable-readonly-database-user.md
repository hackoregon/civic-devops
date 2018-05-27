# How To Enable a read-only database user on an existing PostgreSQL database

https://stackoverflow.com/questions/13497352/error-permission-denied-for-relation-tablename-on-postgres-while-trying-a-selec

## Assumptions

This example assumes that:

- database name = "avengers-secret-hideouts"
- read-only database user = "shield-agent-level6"
- the read-only database user has already been created (e.g. using PgAdmin)
- the read-only database user has default privileges on the server, except has been granted the privilege to Login
- the read-only database user will have read access to the target database
- the read-only database user will end up with only the minimum permissions to the rest of the databases

## Commands

```shell
sudo -u postgres psql
```

```SQL
GRANT USAGE ON SCHEMA public to "shield-agent-level6";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "shield-agent-level6";

GRANT CONNECT ON DATABASE "avengers-secret-hideouts" to "shield-agent-level6";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "shield-agent-level6";
GRANT USAGE ON SCHEMA public to "shield-agent-level6";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO "shield-agent-level6";
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "shield-agent-level6";
```
