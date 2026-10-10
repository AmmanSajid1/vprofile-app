# ECR Image Publishing and Workflow Rerun Issues

## Problem

The GitHub Actions CI pipeline was configured to publish Docker images to AWS ECR using immutable Git commit SHA tags.

Because ECR image tag immutability was enabled, rerunning a workflow for a commit that had already been published could result in an attempt to push an existing image tag.

An image existence check was introduced to avoid unnecessary publishing.

However, several issues were encountered while implementing this logic:

- The CI IAM role initially lacked permission to describe ECR images.
- An early version of the check masked AWS CLI failures.
- Exiting the image-check step successfully did not prevent later image-publishing steps from executing.

## Investigation

The pipeline used the AWS CLI to check whether an image with the current Git commit SHA already existed:

`aws ecr describe-images --repository-name vprofile-app --image-ids imageTag=<commit-sha>`

The initial lookup failed because the IAM policy attached to the GitHub Actions role did not include `ecr:DescribeImages`.

After identifying the missing permission, the IAM policy was reviewed and updated.

The workflow's shell logic was also examined.

An early implementation used `|| echo` after the AWS CLI command, which prevented the original command's non-zero exit status from being handled correctly.

Another approach attempted to use `exit 0` when the image already existed.

However, `exit 0` only completes the current workflow step successfully. It does not skip subsequent steps in the job.

The workflow therefore needed an explicit mechanism to communicate whether the image already existed.

## Fix

The `ecr:DescribeImages` permission was added to the CI IAM policy, scoped to the shared vProfile ECR repository.

The image existence check was updated to write an output using `$GITHUB_OUTPUT`:

- `exists=true` when the image was found.
- `exists=false` when AWS returned `ImageNotFoundException`.
- An unsuccessful step exit when AWS returned an unexpected error.

The Docker publishing step was then conditioned on the image being absent:

`steps.check-image.outputs.exists == 'false'`

This prevented the workflow from attempting to publish an image that already existed.

The workflow was validated through successful runs covering both cases:

- A new commit whose image did not yet exist in ECR.
- A rerun of the same commit after its image had already been published.

Both completed successfully.

## Lesson

Immutable container image tags improve release traceability but require CI pipelines to handle repeated executions safely.

GitHub Actions steps execute independently unless their execution is explicitly controlled through conditions or job dependencies.

A successful exit from one step does not automatically skip subsequent steps.

AWS CLI errors should also be handled deliberately. An image-not-found response is an expected condition, while permission failures and other AWS errors should cause the workflow to fail rather than being silently treated as missing images.

The existence check makes sequential workflow reruns safe, but it does not fully eliminate race conditions if multiple workflows attempt to publish the same tag concurrently.