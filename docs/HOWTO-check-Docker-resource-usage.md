# HOWTO Check Docker resource usage

## Check Memory and CPU from EC2 host OS via ssh

This is the most accurate way to determine how much memory should be allocated to each ECS service in the CloudFormation `service.yaml` template's TaskDefinition > Properties > ContainerDefinitions > Memory setting.

To be able to run this command, first `ssh` to the Bastion host (aka "jump box"), then `ssh` to each EC2 box that hosts our ECS services (docker containers).  Then run the following command, and look at the **MEM USAGE / LIMIT** column to see how much memory is actively being used vs how much is currently allocated by the ECS agent.  (Note: The latter value should be equal to what is set in `service.yaml` - if not, the values in the GitHub and/or S3 copies of your `service.yaml` are out of sync with how the service is currently configured in AWS - go get that in sync so we don't blow ourselves up at next Change Set deploy to CloudFormation.)

```shell
docker ps --format "{{.Names}}"  |  xargs docker stats  $1
```

## Check Memory and CPU from ECS console

You can observe the current consumption by all services (containers) at once by reviewing the ECS > Clusters page in AWS console, e.g.
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/clusters

To review what ECS believes is consumed (which is generally a little less than what EC2 actually reports), select one of the services from the Clusters page and click on the Metrics tab, e.g.
https://us-west-2.console.aws.amazon.com/ecs/home?region=us-west-2#/clusters/hacko-integration/services/hacko-integration-Civic2018Service-7ORXOJDUQ5MW-Service-BJZPEKNWYJH2/metrics

The **CPUUtilization** and **MemoryUtilization** graphs give an historical view for the last ~24 hours of how that service's containers are averaging out across the n number of Tasks.

This is a quick way to get a sense of whether the containers are getting close to their max allocation enough that might explain why you might be seeing them be deemed "unhealthy" by ALB and getting recycled.

## Check Data Volume from EC2 host via ssh
The data volume is where Docker stores all the images it downloads before launching a new ECS task.

```shell
docker info | grep "Data Space"
```
