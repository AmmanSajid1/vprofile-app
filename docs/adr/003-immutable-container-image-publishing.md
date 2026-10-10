# ADR-003: Immutable Container Image Publishing

## Status
Accepted

## Context
The vProfile CI pipeline publishes Docker images to a shared AWS ECR repository.

Images must be identifiable, reproducible and suitable for promotion across dev, staging and production environments.

Using mutable tags such as `latest` could allow different image contents to be associated with the same tag.

## Decision
Tag container images using the Git commit SHA and enable ECR image tag immutability.

Publish images only from successful CI runs on the main branch.

Before publishing, check whether the image tag already exists in ECR. Skip publishing if it exists, and fail the workflow if the lookup encounters an unexpected AWS error.

Use the same published image artifact across environments rather than rebuilding it for each deployment.

## Reasons
- Each image tag is traceable to a specific Git commit.
- Image immutability prevents accidental tag overwrites.
- Existing images can be reused when promoting releases between environments.
- Workflow reruns do not unnecessarily attempt to overwrite existing images.
- Unexpected ECR errors are not silently treated as missing images.

## Trade-offs
- Every new commit produces a distinct image tag.
- Image retention requires lifecycle policies to control storage growth.
- The image existence check introduces additional CI logic and an ECR permission requirement.
- Concurrent publishing attempts for the same commit are not fully prevented by the existence check alone.