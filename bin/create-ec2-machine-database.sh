#!/bin/bash -e

# TODO: change the VolumeType if necessary
# TODO: disable DeleteOnTermination

# if [ "$#" -ne 1 ]; then
#     echo "Must has 1 argument as instance name"
#     exit 1
# fi

DEVICENAME='/dev/sdb'
IMAGEID='ami-7f43f307'
INSTANCETYPE='t2.micro'
INSTANCEPROFILE='s3access-profile'
KEYNAME='hackoregon-2018-database-dev-env'
REGION='us-west-2'
SECURITYGROUPIDS='sg-28154957'
SUBNETID='subnet-8794fddf'
VOLUMESIZE='8'

instance_name=$1
tag_specs='ResourceType=instance,Tags=[{Key=Name,Value='$instance_name'}]'
echo $tag_specs
aws ec2 run-instances \
   --image-id $IMAGEID \
   --count 1 \
   --instance-type $INSTANCETYPE \
   --iam-instance-profile Name=$INSTANCEPROFILE \
   --key-name $KEYNAME \
   --security-group-ids $SECURITYGROUPIDS \
   --subnet-id $SUBNETID\
   --region $REGION \
   --block-device-mappings "[{\"DeviceName\":\"/dev/sdb\",\"Ebs\":{\"VolumeSize\":8,\"VolumeType\":\"gp2\",\"DeleteOnTermination\":true}}]" \
   --tag-specifications $tag_specs \
   --query 'Instances[0].InstanceId'