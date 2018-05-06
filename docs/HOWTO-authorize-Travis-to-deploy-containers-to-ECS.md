# How To Authorize Travis to deploy containers to ECS via ECR

## Background

Hack Oregon takes an approach that our container image repository (currently hosted on AWS ECR) should not be public - some of our container images contain baked-in secrets such as the password to connect to the backend databases.

Thus our ECR repositories require authorization, and we use the approach of authorizing access using an AWS IAM user that has the following permissions:

We generate AWS keypairs for the user, bake those keypairs into env var settings in both the associated Travis repository settings and the associated ECS service configuration.

The actual `docker push` operation is authorized as a result of the [deploy.sh](https://github.com/hackoregon/backend-examplar-2018/blob/staging/bin/deploy.sh) script that uses `aws ecr get-login` command to get an authorization token for ECR that gets implicitly carried forward by `docker push`.

## Error when running `docker push`

When the ECR configuration isn't correct (e.g. the repository hasn't been created, or the repository permissions aren't all in place), you'll observe the command fail with an error such as you see here:

``` text
The push refers to a repository [845828040396.dkr.ecr.us-west-2.amazonaws.com/production/transportation-systems-service]
8b9d1a227ff3: Preparing
ddb0f3c05a82: Preparing
5028495d0a14: Preparing
3e04065e9676: Preparing
306881af805a: Preparing
f3afc624eb91: Preparing
31f8aa385131: Preparing
9650e1239c3e: Preparing
f04225383530: Preparing
f186354f2c39: Preparing
90b8c3cde875: Preparing
fbbeadfbd3ca: Preparing
0f6f641d80ca: Preparing
76a66da94657: Preparing
0f3a12fef684: Preparing
f3afc624eb91: Waiting
31f8aa385131: Waiting
9650e1239c3e: Waiting
f04225383530: Waiting
f186354f2c39: Waiting
90b8c3cde875: Waiting
fbbeadfbd3ca: Waiting
0f6f641d80ca: Waiting
76a66da94657: Waiting
0f3a12fef684: Waiting
denied: User: arn:aws:iam::845828040396:user/2018-ecs-ecr-deployer is not authorized to perform: ecr:InitiateLayerUpload on resource: arn:aws:ecr:us-west-2:845828040396:repository/production/transportation-systems-service
```

## Setup Procedures

1. Create an IAM user
2. Create the ECR repository
3. Configure the ECR repository permissions
4. Add the IAM user's AWS keypair to Travis

### Create an IAM user

(coming soon)

### Create the ECR repository

(coming soon)

### ECR repository permissions

Configuring the permissions in the AWS console is just setting up checkboxes - when you're done, the **Permissions** > **Policy document** should look like the result at the bottom.

This permission set is enough to enable `docker push`:

```JSON
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "push",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::845828040396:user/2018-ecs-ecr-deployer"
            },
            "Action": [
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ]
        }
    ]
}
```

And according to [this article](https://stackoverflow.com/questions/46858799/how-to-pull-from-aws-ecr-docker-image-anonymously) (and our own live ECR repositories from 2017 confirm this), this is the set of permissions needed to pull an image from an ECR repo:

```JSON
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "pull",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::845828040396:user/2018-ecs-ecr-deployer"
            },
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
```

#### Permissions: final result

Since we're using the same user for both the `docker push` and the `ecs-deploy`, that results in the following permissions on each ECR repo:

```JSON
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "push-and-pull",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::845828040396:user/2018-ecs-ecr-deployer"
            },
            "Action": [
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:PutImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ]
        }
    ]
}
```

### Add the IAM user's AWS keypair to Travis
