# ADR-002: GitHub Actions AWS Authentication

## Status
Accepted

## Context
The vProfile CI pipeline requires access to AWS ECR to publish container images after successful builds and tests.

Two authentication approaches were considered:
- Store long-lived IAM access keys as GitHub Actions secrets.
- Use GitHub Actions OIDC federation to obtain temporary AWS credentials.

## Decision
Use GitHub Actions OIDC federation to assume a dedicated IAM role (`vprofile-app-github-ci`) through AWS STS.

Restrict role assumption to the vProfile application repository's main branch and grant only the ECR permissions required by the CI pipeline.

Manage the OIDC provider, IAM role, trust policy and permissions through Terraform in `vprofile-infra`.

## Reasons
- Avoid storing long-lived AWS credentials in GitHub.
- Use temporary credentials issued for individual workflow runs.
- Restrict AWS access through IAM trust policy conditions.
- Limit the CI role's permissions to the required ECR operations.
- Keep IAM configuration version-controlled through Terraform.

## Trade-offs
- OIDC federation requires additional IAM and trust policy configuration.
- Incorrect audience or subject claims can prevent role assumption.
- CI authentication depends on GitHub's OIDC identity provider and AWS STS availability.