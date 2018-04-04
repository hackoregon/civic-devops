#!/bin/bash -e

# Parameters:
# - $1 : Instance's name
# - $2 : Path to instance profile

# Result:
# - Launch an EC2 instance named $1, with the specs/profile provided in the file located at $2
# - Output the public IP address of the instance

if [ "$#" -ne 2 ]; then
    echo "Must provide 2 arguments as (a) instance tag=Name and (b) path to instance profile script"
    echo "e.g. ./create-ec2-machine-database.sh HackO-Developer-Database ec2-profile-database-developer.sh"
    exit 1
fi

# Source EC2 specs from a separate file
# The ./ec2-profile.sh should contain the following variables
# DEVICENAME='/dev/sdb'
# DELETEONTERM='true'
# IMAGEID='ami-7f43f307'
# INSTANCETYPE='t2.micro'
# KEYNAME='hackoregon-2018-database-dev-env'
# REGION='us-west-2'
# SECURITYGROUPIDS='sg-28154957'
# SUBNETID='subnet-8794fddf'
# VOLUMESIZE='8'
# VOLUMETYPE='gp2'

EC2PROFILE=$2
INSTANCE_ID=
INSTANCE_ID_FILE='./tmp_instance_id'
INSTANCE_NAME=$1
TAG_SPECS='ResourceType=instance,Tags=[{Key=Name,Value='$INSTANCE_NAME'}]'

source $EC2PROFILE

echo "Launching the ec2 "\"$INSTANCE_NAME\"" instance..."
aws ec2 run-instances \
   --image-id $IMAGEID \
   --count 1 \
   --instance-type $INSTANCETYPE \
   --key-name $KEYNAME \
   --security-group-ids $SECURITYGROUPIDS \
   --subnet-id $SUBNETID\
   --region $REGION \
   --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\",\"Ebs\":{\"VolumeSize\":$VOLUMESIZE,\"VolumeType\":\"$VOLUMETYPE\",\"DeleteOnTermination\":$DELETEONTERM}}]" \
   --tag-specifications $TAG_SPECS \
   --query 'Instances[0].InstanceId' \
    > $INSTANCE_ID_FILE

echo "New instance'id: "
cat $INSTANCE_ID_FILE

echo "Getting the public ip address of the new instance..."
INSTANCE_ID=$( cat $INSTANCE_ID_FILE )
INSTANCE_ID=$( echo $INSTANCE_ID | cut -c 2- | rev | cut -c 2- | rev ) # trim off the surrounding double quotes
echo "instance id= "$INSTANCE_ID
aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress'

rm -f $INSTANCE_ID_FILE
