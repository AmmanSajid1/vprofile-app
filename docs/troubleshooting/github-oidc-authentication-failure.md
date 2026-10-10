# GitHub Actions OIDC Authentication Failure

## Problem

While configuring GitHub Actions to authenticate with AWS using OIDC, the CI workflow failed when attempting to assume the IAM role created for ECR image publishing.

The workflow used `aws-actions/configure-aws-credentials` to request temporary AWS credentials through STS.

AWS rejected the request with an error similar to:

`Not authorized to perform sts:AssumeRoleWithWebIdentity`

The IAM role, OIDC provider and trust policy had already been provisioned through Terraform.

## Investigation

The IAM role's trust policy was reviewed to confirm the configured federated principal, audience and subject conditions.

The audience was configured as:

`sts.amazonaws.com`

The trust policy initially expected the conventional GitHub OIDC subject format:

`repo:AmmanSajid1/vprofile-app:ref:refs/heads/main`

However, authentication continued to fail.

A temporary debugging step was added to the GitHub Actions workflow to inspect the claims contained in the OIDC token issued during the workflow run.

The token's actual `sub` claim was:

`repo:AmmanSajid1@138880648/vprofile-app@1386408522:ref:refs/heads/main`

Unlike the initially expected value, the actual subject included numeric identifiers for the GitHub repository owner and repository.

The subject condition in the IAM trust policy therefore did not match the token presented to AWS STS.

## Fix

The Terraform IAM trust policy was updated to match the actual subject claim issued to the workflow.

The updated subject condition restricted role assumption to:

`repo:AmmanSajid1@138880648/vprofile-app@1386408522:ref:refs/heads/main`

The audience condition remained restricted to `sts.amazonaws.com`.

After applying the Terraform changes, the GitHub Actions workflow successfully assumed the IAM role.

Authentication was verified using:

`aws sts get-caller-identity`

The temporary OIDC token debugging step was removed from the workflow after the issue was resolved.

## Lesson

OIDC authentication depends on an exact match between the identity claims issued by the provider and the conditions configured in the IAM role trust policy.

When `AssumeRoleWithWebIdentity` fails, the actual token claims should be inspected rather than assuming that the expected subject format is being issued.

GitHub OIDC subject claims can differ from the conventional repository-name format depending on identity configuration.

Restrictive trust policy conditions should be preserved during troubleshooting rather than replacing them with broad wildcard access.