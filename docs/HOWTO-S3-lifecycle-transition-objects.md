# Enabling lifecycle policy on S3 Bucket

## Example Policy

```
<LifecycleConfiguration>
  <Rule>
    <ID>Move to inactive</ID>
    <Filter>
      <Tag>
         <Key>Archive</Key>
         <Value>maybe</Value>
      </Tag>
    </Filter>
    <Status>Disabled</Status>
    <Transition>
      <Days>35</Days>
      <StorageClass>STANDARD_IA</StorageClass>
    </Transition>
  </Rule>
  <Rule>
    <ID>Move to Glacier</ID>
    <Filter>
      <Tag>
         <Key>Archive</Key>
         <Value>yes</Value>
      </Tag>
    </Filter>
    <Status>Disabled</Status>
    <Transition>
      <Days>65</Days>
      <StorageClass>GLACIER</StorageClass>
    </Transition>
  </Rule> 
  <Rule>
    <ID>Delete unfinished multipart uploads</ID>
    <Filter>
    </Filter>
    <Status>Enable</Status>
    <AbortIncompleteMultipartUpload>
       <DaysAfterInitiation>7</DaysAfterInitiation>
    </AbortIncompleteMultipartUpload>
  </Rule>
</LifecycleConfiguration>

```

## How this Policy Works

Below is a lifecycle policy that can be applied to a bucket. It consists of three rules that will be applied to objects held in the Bucket. The first rule will look for all objects that have the tag `Archive` with a value of `maybe`. Objects found with this tag/value combination that have not been modified in 35 days will be moved to storage class "Infrequent Access" which is half the cost of the default "Standard" S3 storage.

Note that tag names and their values are case sensitive so tag names `Archive` and `archive` are two separate tags. Likewise a tag value of `Maybe`or`MAYBE` will not match the value specified in the rule.

The second rule moves objects that have not been modified in 65 days to "Glacier" storage if they have the tag `Archive` with a value of `yes` . If an object does not have the `Archive` tag or has a value other than `maybe` or `yes` then the object will not be transitioned.

The first two rules have a status of `Disabled` - this allows us to apply the policy to a Bucket immediately, but that it will not have an effect on any Object that has the `Archive` tag, until each rule's Status value is changed to `Enabled`.

The third rule will remove any failed or incomplete multipart uploads that are more than seven days old, and is Enabled by default.

## What Happens When Changes are Made

The lifecycle can be applied to the Bucket before or after objects are tagged with the `Archive` tag.

To have an object move to "Infrequent Access" after 35 days since it was last modified, add the tag/value `Archive=maybe` this can easily be changed in the rule if we want to use something else like `Archive=IA`.

To have an object moved to "Glacier" (least expensive storage, but takes a restore Request and a number of hours to complete), assign the object a tag/value of `Archive=yes` or change the rule to expect `Archive=GLACIER`. 
