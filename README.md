# Workshop-environment

This repo creates "environment" modules with all the necessary resources to enable end-to-end interaction with a Web-app and RDS

## What are we provisioning here?

- Load-Balancer
- LaunchConfiguration including a user-data script
- AutoscalingGroup
- RDS
- Security groups

## Persistence

- The terraform statefile is stored in an AWS S3 bucket
- The terraform lock file is stored in AWS Dynamodb

Served as an home assignment.
