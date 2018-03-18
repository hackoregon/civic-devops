#!/bin/bash -e

if [ "$#" -ne 1 ]; then
    echo "Must has 1 argument as instance tag name"
    exit 1
fi

DEVICENAME='/dev/sdb'
IMAGEID='ami-7f43f307'
INSTANCETYPE='t2.micro'
KEYNAME='hackoregon-2018-database-dev-env'
REGION='us-west-2'
SECURITYGROUPIDS='sg-28154957'
SUBNETID='subnet-8794fddf'
VOLUMESIZE='8'

EC2PROFILE='./ec2-profile-1.sh'
source $EC2PROFILE

instance_name=$1
tag_specs='ResourceType=instance,Tags=[{Key=Name,Value='$instance_name'}]'
instance_id_file='./tmp_instance_id'
instance_id=

echo "Launching the ec2 "\"$instance_name\"" instance..."
aws ec2 run-instances \
   --image-id $IMAGEID \
   --count 1 \
   --instance-type $INSTANCETYPE \
   --key-name $KEYNAME \
   --security-group-ids $SECURITYGROUPIDS \
   --subnet-id $SUBNETID\
   --region $REGION \
   --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\",\"Ebs\":{\"VolumeSize\":8,\"DeleteOnTermination\":true}}]" \
   --tag-specifications $tag_specs \
   --query 'Instances[0].InstanceId' \
    > $instance_id_file

echo "New instance'id: "
cat $instance_id_file

echo "Getting the public ip address of the new instance..."
instance_id=$( cat $instance_id_file )
instance_id=$( echo $instance_id | cut -c 2- | rev | cut -c 2- | rev ) # trim off the surrounding double quotes
echo "instance id= "$instance_id
aws ec2 describe-instances \
    --instance-ids $instance_id \
    --query 'Reservations[0].Instances[0].PublicIpAddress'

rm -f $instance_id_file
