# CI/CD and GitOps Release Pipeline

## Overview

The vProfile application uses GitHub Actions for continuous integration and release promotion, Amazon ECR for container image storage, and Argo CD for Kubernetes deployments.

Application source code and Kubernetes deployment configuration are maintained in separate repositories:

- **vprofile-app:** Application source code, Dockerfiles, tests, and GitHub Actions workflows.
- **vprofile-gitops:** Kubernetes manifests and Kustomize overlays for development and staging.
- **vprofile-infra:** Terraform infrastructure and platform configuration.

The pipeline follows a build-once, promote-the-same-artifact approach. Application and Flyway migration images are built once, tagged with the source commit SHA, and reused across environments.

## Release Flow

```text
Developer pushes to vprofile-app/main
                |
                v
        GitHub Actions CI
         - Maven tests
         - Docker image builds
         - ECR image publishing
                |
                v
     Automated GitOps development PR
                |
          Review and merge
                |
                v
       Development desired state
                |
       Manual staging promotion
         - Read dev image tags
         - Verify images in ECR
         - Update staging overlay
                |
                v
         GitOps staging PR
                |
          Review and merge
                |
                v
        Staging desired state
```

When the Kubernetes cluster is running, Argo CD reconciles the corresponding environment after GitOps changes are merged.

## Continuous Integration

The CI workflow is defined in `.github/workflows/ci.yaml`.

It runs on pushes and pull requests to the application's `main` branch.

The workflow:

1. Runs Maven tests and builds the Java application.
2. Builds Docker images for the application and Flyway database migrations.
3. On pushes to `main`, authenticates to AWS using GitHub Actions OIDC.
4. Checks whether the commit-tagged images already exist in Amazon ECR.
5. Publishes missing images using the source commit SHA as the immutable tag.
6. Opens a pull request in `vprofile-gitops` to update the development image versions.

Image publishing is restricted to the appropriate push workflow. Pull request validation does not publish release images.

The ECR repositories use immutable tags, preventing an existing image tag from being overwritten.

## Development Deployment

The development Kustomize overlay is located at:

`apps/vprofile/overlays/dev/kustomization.yaml`

This path is relative to the `vprofile-gitops` repository.

CI updates the application and Flyway image tags together through a GitOps pull request.

A reviewer merges the PR after checking the proposed changes. When the environment is available, Argo CD detects the updated desired state and reconciles the development deployment.

This separates image publishing from deployment approval.

## Manual Staging Promotion

The promotion workflow is defined in:

`.github/workflows/promote-staging.yaml`

It is started manually through GitHub Actions using `workflow_dispatch`.

The workflow:

1. Checks out the GitOps repository's `main` branch.
2. Reads the application and Flyway image references from the development Kustomize overlay.
3. Confirms that both images use the same 40-character Git SHA tag.
4. Verifies that the images exist in Amazon ECR.
5. Updates the staging Kustomize overlay to use the approved development image tag.
6. Creates a staging promotion pull request for review.

The promotion does not rebuild or republish container images. This ensures staging receives the same artifacts already selected for development.

The workflow also checks whether staging already matches development. If the image tags are identical, it exits successfully without creating a PR.

## Authentication and Access Control

AWS authentication uses GitHub Actions OIDC with an IAM role, avoiding long-lived AWS access keys in GitHub secrets.

Cross-repository GitOps operations use a GitHub App installation token. The App credentials are stored in GitHub Actions secrets.

Non-sensitive configuration, including the GitOps repository, AWS region, and IAM role ARN, is stored in GitHub Actions repository variables.

The GitOps `main` branch is protected, so automated workflows propose changes through pull requests rather than pushing directly to the deployment branch.

## Design Decisions

**Immutable image tags:** Git commit SHAs provide a traceable link between source code and published images.

**Build once, promote:** Development and staging use the same artifacts, avoiding differences introduced by separate builds.

**GitOps separation:** Application builds do not directly modify the running Kubernetes cluster. Deployment configuration changes are reviewed and recorded in Git.

**Manual staging approval:** Promotion is an explicit release decision rather than an automatic consequence of merging application code.

**Idempotent workflows:** Repeated runs avoid unnecessary image publishing and duplicate staging changes.

## Validation

The release pipeline was tested by:

- Successfully running CI after an application repository push.
- Creating and merging an automated development GitOps PR.
- Manually triggering staging promotion.
- Verifying that the promotion workflow created a PR updating both staging image tags.
- Merging the staging PR.
- Rerunning the promotion workflow and confirming that no new PR was created when development and staging already matched.

The promotion workflow was validated while the EKS cluster was offline. This confirmed the GitHub Actions, ECR verification, and GitOps pull request process without requiring running Kubernetes infrastructure.

Live Kubernetes reconciliation and deployment behaviour were tested separately.