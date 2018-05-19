#     **Settings needed for Civic services**

New services need to be entered into the below table and have the values completed and reviewed before task definitions can be created to permit containers being deployed to the ECS instances from the Travis/build CI/CD.

The following table is used to track items assigned to services. These items are needed to keep services from colliding in the load balancer listener rules, service name collisions, domain/subdomain for services and the needed CPU/Memory and container Port resources need for services to start and run in the container service (ECS).

In ECS/EC2 (current for Hack Oregon stack) the CPU and memory values are used to reserve resources and set a resource limit (if there is not enough of a recourse for the reservation to complete, the service will not start, regardless of how much CPU/Memory is really used by the service). The CPU and memory settings are optional.

In ECS/Fargate (possible future infrastructure) the CPU and memory settings are required and the service will be allocated (and charges incurred) for the amount of the CPU and memory that is set (regardless if used or not) and acts as a hard limit for the service resources.

**Attempts should be made to set the CPU and Memory setting as low as possible as they have an effect on the size of the ECS instances (EC2) and the costs (EC2 and Fargate)**

The Host value is used to place the service in a domain for the load balancer and the Host and Path are combined for the listener rule for the service. Care must be taken to make sure paths in a domain/subdomain do not collide/overlap between services as the first listener rule that matches will apply.

The priority setting must be unique and determines the order in which listener rules are evaluated from lowest to highest number. The first rule to satisfy the request is applied.

**The civic-lab service must be the highest priority number of all services (last rule to be evaluated before the catch-all default rule) since it's Path is ( / )**

**All 2018 services must have priority numbers less than (evaluated before) the civic-2018-service since its path is ( /* ) and would match before any new services in the staging-2018.civicpdx.org domain.**

The above requirement are be the same for the civic-2017 service if any new services are added to its domain (2017.civicpdx.org)

The 2017 services priorities are historical and are not being changed at this time.

| Year | Service Name                     | CPU  |  Mem.  |  Port   | Priority |           Host            | Path                       |
| :--: | :------------------------------- | :--: | :----: | :-----: | :------: | :-----------------------: | :------------------------- |
| 2017 | emergency-service                |  0   |  100   |  8000   |    3     |   service.civicpdx.org    | /emergency*                |
| 2017 | endpoint-service                 |  0   |  100   |  8000   |    4     |   service.civicpdx.org    | /endpoint-service*         |
| 2017 | homeless-service                 |  0   |  100   |  8000   |    5     |   service.civicpdx.org    | /homeless*                 |
| 2017 | housing-service                  |  0   |  100   |  8000   |    6     |   service.civicpdx.org    | /housing*                  |
| 2017 | transport-service                |  0   |  2048  |  8000   |    7     |   service.civicpdx.org    | /transport*                |
| 2017 | budget-service                   |  0   |  100   |  8000   |    69    |   service.civicpdx.org    | /budget*                   |
| 2018 | civic-2017-service               |  0   |  100   |  3000   |    10    |     2017.civicpdx.org     | /*                         |
| 2018 | housing-affordability-service    |  0   |  ???   |   ???   |    20    |   service.civicpdx.org    | /housing-affordability*    |
| 2018 | neighborhood-development-service |  0   |  ???   |   ???   |    25    |   service.civicpdx.org    | /neighborhood-development* |
| 2018 | local-elections-service          |  0   |  ???   |   ???   |    30    |   service.civicpdx.org    | /local-elections*          |
| 2018 | disaster-resilience-service      |  0   |  ???   |   ???   |    35    |   service.civicpdx.org    | /disaster-resilience*      |
| 2018 | transportation-systems-service   |  0   | `2GB?` | `3000?` |    40    |   service.civicpdx.org    | /transportation-systems*   |
| 2018 | civic-2018-service               |  0   |  100   |  3000   |    45    | staging-2018.civicpdx.org | /*                         |
|      |                                  |      |        |         |    50    |                           |                            |
|      |                                  |      |        |         |    55    |                           |                            |
|      |                                  |      |        |         |    60    |                           |                            |
| 2017 | civic-lab-service                |  0   |  1024  |  8000   |    78    |   service.civicpdx.org    | /                          |

