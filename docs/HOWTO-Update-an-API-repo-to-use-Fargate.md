# Refactoring an API Repo to use Fargate

Although the bulk of what is required to move a service from EC2-backed ECS to Fargate-backed ECS happens in Cloud Formation, since APIs control their own deployment via scripts and Travis, some work has to happen in the API repo as well.

## Ultimate Goal

Since each project will likely be slightly different, it's worth pointing out what the goal is before itemizing likely scenarios.

What we want to do is **convert existing scripts to support Fargate task definitions while ensuring that the newly built containers have all the environment variables they need to function.**

Since we have tried to be consistent, there are bound to be a few likely sticking points.

### Tests fail before even getting to the point of deploying the container

**Problem:** It's possible that dependencies outside of our control have changed since an old API project was last built causing test failures.
**What to look for:** Suspicious package versions, mentions of deprecations.
**Solution:** If the error is something about `funcargnames`, then the dependency on pytest needs to be updated. If it is something else, you're on your own. Hopefully Googling the error message leads to something.

### Updating the ecs-deploy script to support Fargate

**Problem:** The ecs-deploy script in many repos pre-dates AWS launching Fargate.
**What to look for:** An error message in travis along the lines of "Could not start non-Fargate task".
**Solution:** Update the `ecs-deploy.sh` script to the latest version in [the source repo](https://github.com/silinternational/ecs-deploy/blob/3.6.0/ecs-deploy).

### Getting containers to push to ECR

**Problem:** Due to some migrations and silent errors, rebuilding old repos may result in ECR errors, which will fail silently.
**What to look for:** An error message in Travis, hidden under the `deploy.sh` collapsed section that mentions something about bad permissions or non-existent repo.
**Solution:** Verify that the ENV VARS set on the Travis project match the VARS expects in the `/bin` scripts for the repo. Update ENV VARS accordingly. This may require breaking `DOCKER_REPO` into `DOCKER_REPO_NAMESPACE` and `DOCKER_REPO`

### Getting services to restart in ECS

**Problem:** Due to changes required for Fargate task definitions, the AWS user used by Travis for a repo may not have all the necessary permissions.
**What to look for:** An error message in Travis, hidden under the `deploy.sh` collapsed section that mentions "AWS User <user> doesn't have required permission <permission>".
**Solution:** Update the user in AWS to have the missing permission. It is likely `iam:PassRole` if anything. 

### Providing all required configuration to containers

**Problem:** Due to some migrations and silent errors, old repos may be attempting to get their configuration from the parameter store despite there being no configuration for that particular project in the parameter store.
**What to look for:** An error message and stack trace in CloudWatch for the running Fargate task that mentions something semi-cryptic that sounds like a missing value for an environment variable.
**Solution:** Update the Dockerfile and maybe the docker-compose file to plumb the Travis environment into the Container using a combination of docker-compose build-args and Dockerfile `ARG` and `ENV` statements. Look at the [2017 Emergency Response](https://github.com/hackoregon/emergency-response-backend) repo for an example.

## Confirming a Successful Migration

You know that the migration is successful once a Travis build on the master branch results in

1. A new pushed container to the ECR registry for the correct ECR repo
2. A new task definition in ECS for the correct task
3. A task restart in ECS resulting in the current running task for the correct service to be the latest task definition revision as seen in the Travis logs
4. The newest tasks for the service in ECS in a running state.
5. No error messages in CloudWatch for the newly running task.
6. Passing health check log messages in CloudWatch for the newly running task.
7. Browse to https://service.civicpdx.org/{service_name} to verify the API container is successfully responding to external requests.
