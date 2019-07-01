# How to Update CloudFormation

For every configuration change in a CloudFormation cluster in ECS, the predictable and repeatable way to introduce those changes is to generate a Change Set and then execute it once you've had a chance to validate.

This is always performed in the CloudFormation console in AWS, using the latest version of our `master.yaml` - which we keep in the [hackoregon-aws-infrastructure](https://github.com/hackoregon/hackoregon-aws-infrastructure/blob/master/master.yaml) repo.  When this is validated and executed, it will download and use any changed templates specified in the `master.yaml`.  We reference all of those templates to an S3 bucket (hacko-infrastructure-cfn) to which we upload the latest copies from the GitHub repo.  That is, we consider the GitHub repo as our source of truth, and the S3 bucket happens to be the online cache to which CloudFormation has access when performing updates via any of those linked files.

For example, when adding a new Service to the ECS cluster `hacko-integration`, we:

- make any changes you like to a copy of the template(s)
- commit those changed template files to the [hackoregon-aws-infrastructure](https://github.com/hackoregon/hackoregon-aws-infrastructure) GitHub repo - this gives us a known good copy, and your PR will help with code review to get human eyes to confirm the intended changes
- upload those changed files to the hacko-infrastructure-cfn bucket in Hack Oregon's S3
- login to the HackOregon AWS account
- open the CloudFormation console
- scroll to the bottom of the list and select the “hacko-integration” stack name (the only one not marked “NESTED”)
- on the Actions menu, choose “Create change set…”
- under “Choose a template” paste in the following to the S3 template URL option: https://s3-us-west-2.amazonaws.com/hacko-infrastructure-cfn/master.yaml
- give it a decent name and any old description…
- ignore the keypair - that’s a battle for a different day…
- just hit Next on the Options screen
- hit “Create change set” button - this will just evaluate the changes, it will not yet make those changes
- scroll through the resulting list - you should see two “Add” entries for our new services/FE-containers.  You will also see a suite of “Modify” entries (for services that make runtime references to `!Ref` variables stored outside of their originating files - Ian assures me this is normal and unavoidable given our use of `!Ref`).
- on the far-right column labelled Replacement, in most cases you should see nothing labelled “True”, and the Add entries - for any new services being added - should have *no* value
- if that’s what you’re seeing, then hit the Execute button at the top right and cross your fingers.
- if this succeeds, then when you click on the parent stack listing on the CloudFormation page, under the Events section you should see `UPDATE_COMPLETE` status for any existing services, and `CREATE_COMPLETE` for any newly-added services

## Couple of Warnings

1. Do NOT to execute the change-set if you do not have full administrator privileges as pain will ensue.
2. Do NOT use the update button and go down that path as it does not create a change-set that can be reviewed (and either deleted or executed ) but does the changes immediately - unless you *want* to make such changes immediately.
