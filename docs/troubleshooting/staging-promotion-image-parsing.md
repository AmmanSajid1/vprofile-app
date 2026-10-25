# Staging Promotion Fails Due to Kustomize Image Parsing

## Problem

The manually triggered staging promotion workflow failed during the `Read development image versions` step with the error:

```text
Development and staging image names differ
Error: Process completed with exit code 1.
```

The failure occurred even though both environments referenced the same application and Flyway ECR repositories.

## Root Cause

The workflow used a Python script to extract image names and tags from the development and staging `kustomization.yaml` files.

Initially, the script searched the entire file for lines beginning with `- name:` rather than restricting parsing to the `images:` section.

Other Kustomize configuration entries could therefore be incorrectly interpreted as container images, causing the image-name comparison to fail.

The development overlay also included `newName` fields, while staging only specified `name` and `newTag`. This difference was valid Kustomize configuration and was not itself the cause of the failure.

## Resolution

Updated the workflow's Python parsing logic to:

1. Locate the top-level `images:` section.
2. Process image entries only within that section.
3. Stop parsing when the next top-level configuration section begins.
4. Validate that development and staging reference the same two images.
5. Confirm that both development images use the same Git SHA tag.

Applied the same section-scoping approach to the ECR image verification and staging image update steps.

## Verification

After committing the fix:

- The CI pipeline completed successfully.
- The updated development image versions were merged into GitOps.
- The staging promotion workflow completed successfully.
- A staging promotion PR was created with the correct image tags.
- After merging the PR, rerunning the workflow succeeded without creating another PR.

## Lessons Learned

Parsing YAML using broad string matching can produce incorrect results when identical field names appear in different sections.

For this project's limited Kustomize structure, section-aware parsing was sufficient. For more complex manifests, using a YAML parser or Kustomize-aware tooling would provide a more robust solution.