# Kubernetes (K8s) Deployment

Deployment scripts for Kubernetes cluster of microservices.

## Overview

I worked on a project with ~10 microservices making up a test authoring platform.  Test questions were 
authored through this platform and made available to be packaged into tests.  The tests could be 
distributed to platforms like Pearson or into school districts for testing grades 3-11.

The platform runs on AWS but this was before EKS came out.  I had not explored Helm at the time either.

My goal was to make releasing microservice into the Kubernetes cluster simple and easy.

The K8s files shown here are likely outdated and reflect what was used at the time.

## Gradle
Using Gradle and its copy filtering feature, the values in gradle.properties were used to define the release.
This created one place the Ops team had to go to update the release.  All other files in the branch are common across
environment specific branches.

## Branches 
Branches were used to represent the different environments.  Branches like 'dev', 'stg', and 'prod'.
The main branch gradle.properties had values that were common to all environments.  If there was a property
that was environment specific the main branch had no value for that property.

If there were main branch changes those needed to be pulled into the env branches. 

1. Checkout env branch.
2. Merge the main branch into the env branch.  
3. 

The only changes that merge in from main would be changes to gradle.properties.

## Templates
See the [templates](templates) folder.  It contains different files with tokens that are replaces by Gradle.  The tokens
start and end with the @ symbol, for example `@version_publisher@`.

Gradle replaces the tokens and copies the files to the release folder.

To see the template filtering in action you can either run `./gen` or you could call gradle directly `./gradlew`.  The 
build has a default set of tasks it runs so there are no tasks needed when calling Gradle.

The files presented in this project are simple and have a few tokens in order to demonstrate the idea.  
You could put as many tokens as you want into the templates.  Just make sure to add them to gradle.properties.

## Scripts
Scripts in the root of the project are used to drive the creation of the templates and to execute the process.
 
When standing up a new environment the cluster and its base services needed run.  Then the applications needed
to be created in the cluster.

Once the initial setup was done, updating the applications was the most common thing to be done.  New features in the apps
would come out, a release was planned, Ops updated gradle.properties with the correct app version, and executed 
[cluster-update-apps.sh](cluster-update-apps.sh)

## Cluster Creation
Creating a new cluster had to be done once per environment.

See [cluster-create.sh](cluster-create.sh)

We used [KOps](https://kops.sigs.k8s.io/) to create the K8s cluster on AWS.

Once the cluster was available we added some base services, an autoscaler and a nginx http-backend.

Steps when standing up a new env:
1. Checkout env branch.
2. Merge the main branch into the env branch.
3. Update gradle.properties with the env specific values.
4. Run `./cluster-create.sh`
5. Wait for the cluster to be available, this can take some time
6. Run `./cluster-create-base.sh`
7. Wait for the base services to be available, this was quick
8. Run `./cluster-create-app.sh`

## Application Release
The applications were developed in a separate Git repository.  Initially each app was in its own Git repo, but
we combined them into a single repo where we used a multi-module Gradle structure.

The applications were developed and a release was eventually created.  The release was a docker image per service that was 
pushed into Docker Hub.  The released docker images were given a version like 1.2.3 or 1.0.7

Docker Hub was used by Kubernetes to pull down the apps and run them their respective deployments. See the files in 
`templates/k8s-app`.  Each Yaml file represents an application where the file defines the app's
K8s service and deployment specifications.

Once the applications were created in the cluster, the only thing required was to up the cluster with new versions of 
the apps as they were released.e

Steps when updating application versions:
1. Checkout env branch.
2. Merge the main branch into the env branch.
3. Update gradle.properties with the env specific values. 
4. Adjust [cluster-update-apps.sh](cluster-update-apps.sh) to your needs. 
5. Run `./cluster-update-app.sh`

## Commit Changes

Once a release/deployment was successful, the Ops team would commit the changes made.  This
captured what was done for a particular release.  

The changes to gradle.properties are committed to the Git history. 

Maybe you don't need to release all the apps in the ecosystem.  In this case, adjust [cluster-update-apps.sh](cluster-update-apps.sh)
by commenting out what doesn't require being deployed.  Committing these changes shows what was done at that time.  On the 
next deployment this file will be adjusted again to capture what was done.


## Lessons Learned

When updating the applications in the cluster, consider using sleep in between `kubectl replace` calls.  The idea is 
to replace a few apps and let them fully come up before moving on to replacing more.  This helps avoid overwhelming
the cluster.  See [cluster-update-apps.sh](cluster-update-apps.sh)

We felt having one cluster in one VPC was overkill for our needs.  We ended up having the production cluster in its
own VPC, but we shared another VPC for our dev, uat, and staging clusters.  It required editing values when creating 
the cluster.  Values like subnet CIDRs.

## Requirements

You will need an AWS account where the cluster will be created.  

You will need credentials on the machine where this project is executed.

* [Gradle](https://gradle.org/)
* [AWS client](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [kubectl](https://kubernetes.io/docs/reference/kubectl/kubectl/)
* [KOps](https://kops.sigs.k8s.io/getting_started/install/) 
