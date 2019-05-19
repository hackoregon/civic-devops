# HOWTO: use the "DB jumpbox" to restore PostgreSQL database from S3

Summary: SSH into the jumpbox, grab your backup file, restore your backup.

## Steps

1. *Get the keys*: Talk to #team-infra on our Slack group to get a copy of the SSH keys (in `.pem` format)
2. *Place the keys*: Download the .pem file then run `mv hackoregon-2019-db-restore-jumpbox.pem ~/.ssh`
3. *Secure the keys*: Run `chmod 400 ~/.ssh/hackoregon-2019-db-restore-jumpbox.pem`
4. *Use the keys to get into the box*: Run `ssh -i ~/.ssh/hackoregon-2019-db-restore-jumpbox.pem ec2-user@ec2-34-220-186-62.us-west-2.compute.amazonaws.com` to get into the jumpbox
5. *Get the backup file*: Copy your backup from the S3 location with a command of the form aws s3 cp s3://hacko-data-archive/(team folder)/(backups folder)/(backup file name) /backups
e.g. s3://hacko-data-archive/2017-team-budget/database-backup/budget.sql.gz /backups
6. *Restore your backup*: Run whatever command(s) you need to restore your database/data to your team's RDS instance for your team
7. *Cleanup your backup*: rm -rf /backups/*.*

Your restore procedure will vary depending on the backup tools you're using, the kind of backup (e.g. data, schema or to-be-converted CSV) and where it's headed.
