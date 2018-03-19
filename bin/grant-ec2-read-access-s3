#!/bin/bash -e

ROLE_NAME='s3access'
TRUST_POLICY_FILE='file://ec2-role-trust-policy.json'
ACCESS_POLICY_FILE='file://ec2-role-access-policy.json'
ACCESS_POLICY_NAME='S3-Permissions'
INSTANCE_PROFILE_NAME='s3access-profile'

echo
echo "Creating IAM role named \"$ROLE_NAME\""
aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document $TRUST_POLICY_FILE

echo
echo "Attaching the access policy \"$ACCESS_POLICY_FILE\" to role \"$ROLE_NAME\" "
aws iam put-role-policy \
    --role-name $ROLE_NAME \
    --policy-name $ACCESS_POLICY_NAME \
    --policy-document $ACCESS_POLICY_FILE

echo
echo "Creating an instance profile named \"$INSTANCE_PROFILE_NAME\" "
aws iam create-instance-profile \
    --instance-profile-name $INSTANCE_PROFILE_NAME

echo
echo "Adding the role named \"$ROLE_NAME\" to the instance profile named \"$INSTANCE_PROFILE_NAME\" "
aws iam add-role-to-instance-profile \
    --instance-profile-name $INSTANCE_PROFILE_NAME \
    --role-name $ROLE_NAME










