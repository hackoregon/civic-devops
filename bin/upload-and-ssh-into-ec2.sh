#! /bin/sh

# Utility script uploads all local files to targeted EC2 virtual machine and SSH's into the machine.

EC2MACHINE=$1 # Public DNS of the EC2 VM e.g. ec2-54-200-42-122.us-west-2.compute.amazonaws.com
FILETOUPLOAD="*"
# PEMFILE=$2
PEMFILE="~/.ssh/hackoregon-2018-database-dev-env.pem"

scp -i $PEMFILE $FILETOUPLOAD ec2-user@${EC2MACHINE}:~
ssh -i $PEMFILE ec2-user@${EC2MACHINE}
