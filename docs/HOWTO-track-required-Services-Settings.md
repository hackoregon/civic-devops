#     **Settings needed for Civic services**

New services need to be entered into the below table and have the values assigned and reviewed before task definitions can be created and containers deployed to the ECS instances.

The following table is used to track the configuration we've assigned to ECS services. This tracking is needed to keep services from colliding in the load balancer listener rules, as well as prevent service name collisions, domain/subdomain for services and the needed CPU/Memory and container Port resources need for services to start and run in the container service (ECS).

## CPU & Memory
In ECS/EC2 (current for Hack Oregon stack) the CPU and memory values are used to reserve resources and set a resource limit (if there is not enough of a recourse for the reservation to complete, the service will not start, regardless of how much CPU/Memory is really used by the service). The CPU and memory settings are optional.

In ECS/Fargate (a possible future infrastructure) the CPU and memory settings are required and the service will be allocated (and charges incurred) for the amount of the CPU and memory that is set (regardless if used or not) and acts as a hard limit for the service resources.

**Attempts should be made to set the CPU and Memory setting as low as possible as they have an effect on the size of the ECS instances (EC2) and the costs (EC2 and Fargate)**

## Host & Path
The Host value is used to place the service in a domain for the load balancer and the Host and Path are combined for the listener rule for the service. Care must be taken to make sure paths in a domain/subdomain do not collide/overlap between services as the first listener rule that matches will apply.

## Priority
The Priority value must be unique and determines the order in which listener rules are evaluated from lowest to highest number (smallest to largest). The first rule to satisfy the request is applied - e.g. the rule with Priority "20" is evaluated before the rule with Priority "56".

**NOTE: The endpoint-service must have the largest Priority number of all services (last rule to be evaluated before the catch-all default rule) since its Path is ( / )**

**All 2018 services must have Priority values smaller than (evaluated before) the civic-2018-service since its path is ( /* ) and would match before any new services in the staging-2018.civicpdx.org domain.**

The above requirement are be the same for the civic-2017 service if any new services are added to its domain (2017.civicpdx.org)

| Year | Service Name                     | CPU  |  Mem.  |  Port   | Priority |           Host            | Path                       |
| :--: | :------------------------------- | :--: | :----: | :-----: | :------: | :-----------------------: | :------------------------- |
| 2018 | civic-2017-service               |  0   |  100   |  3000   |    15    |     2017.civicpdx.org     | /*                         |
| 2018 | civic-2017-service               |  0   |  100   |  3000   |    16    |     2017.civicpdx.org:443 | /*                         |
| 2018 | civic-2017-service               |  0   |  100   |  3000   |    17    |     civicpdx.org          | /*                         |
| 2018 | housing-affordability-service    |  0   |  100   |  8000   |    20    |   service.civicpdx.org    | /housing-affordability*    |
| 2018 | housing-affordability-service    |  0   |  100   |  8000   |    21    |   service.civicpdx.org:443 | /housing-affordability*    |
| 2018 | neighborhood-development-service |  0   |  300   |  8000   |    25    |   service.civicpdx.org    | /neighborhood-development* |
| 2018 | neighborhood-development-service |  0   |  300   |  8000   |    26    |   service.civicpdx.org:443 | /neighborhood-development* |
| 2018 | local-elections-service          |  0   |  200   |  8000   |    30    |   service.civicpdx.org    | /local-elections*          |
| 2018 | local-elections-service          |  0   |  200   |  8000   |    31    |   service.civicpdx.org:443 | /local-elections*          |
| 2018 | disaster-resilience-service      |  0   |  300   |  8000   |    35    |   service.civicpdx.org    | /disaster-resilience*      |
| 2018 | disaster-resilience-service      |  0   |  300   |  8000   |    36    |   service.civicpdx.org:443 | /disaster-resilience*      |
| 2018 | transportation-systems-service   |  0   |  500   |  8000   |    40    |   service.civicpdx.org    | /transportation-systems*   |
| 2018 | transportation-systems-service   |  0   |  500   |  8000   |    41    |   service.civicpdx.org:443 | /transportation-systems*   |
| 2018 | civic-2018-service               |  0   |  100   |  3000   |    45    | civicplatform.org | /*                         |
| 2018 | civic-2018-service               |  0   |  100   |  3000   |    46    | civicplatform.org:443 | /*                         |
| 2017 | budget-service                   |  0   |  100   |  8000   |    50     |   service.civicpdx.org    | /budget*                   |
| 2017 | budget-service                   |  0   |  100   |  8000   |    51     |   service.civicpdx.org:443 | /budget*                   |
| 2017 | emergency-service                |  0   |  100   |  8000   |    52     |   service.civicpdx.org    | /emergency*                |
| 2017 | emergency-service                |  0   |  100   |  8000   |    53     |   service.civicpdx.org:443 | /emergency*                |
| 2017 | homeless-service                 |  0   |  100   |  8000   |    54     |   service.civicpdx.org    | /homeless*                 |
| 2017 | homeless-service                 |  0   |  100   |  8000   |    55    |   service.civicpdx.org:443 | /homeless*                 |
| 2017 | housing-service                  |  0   |  100   |  8000   |    56     |   service.civicpdx.org    | /housing*                  |
| 2017 | housing-service                  |  0   |  100   |  8000   |    57     |   service.civicpdx.org:443 | /housing*                  |
| 2017 | transport-service                |  0   | 2048   |  8000   |    58     |   service.civicpdx.org    | /transport*                |
| 2017 | transport-service                |  0   | 2048   |  8000   |    59     |   service.civicpdx.org:443 | /transport*                |
|      |                                  |      |        |         |    60    |                           |                            |
| both | endpoint-service                 |  0   |  100   |  8000   |    79     |   service.civicpdx.org    | /                 |
| both | endpoint-service                 |  0   |  100   |  8000   |    80     |   service.civicpdx.org    | /\_\_assets*                 |
| both | endpoint-service                 |  0   |  100   |  8000   |    81    |   service.civicpdx.org:443 | /                 |
| both | endpoint-service                 |  0   |  100   |  8000   |    82    |   service.civicpdx.org:443 | /\_\_assets*                 |



