# ADR 004: Manual Staging Promotion Using Immutable Images

**Status:** Accepted

## Context

The vProfile CI pipeline builds and publishes application and Flyway images to Amazon ECR using immutable Git commit SHA tags.

Development image updates are proposed through pull requests to the GitOps repository, where Argo CD manages deployment reconciliation.

A release process was needed to promote tested development versions to staging while maintaining control over when staging changes occur.

## Decision

Use a manually triggered GitHub Actions workflow to promote the existing development image versions to staging.

The workflow:

- Reads the application and Flyway image tags from the development Kustomize overlay.
- Confirms both images reference the same Git commit.
- Verifies the images exist in Amazon ECR.
- Updates the staging overlay without rebuilding or republishing images.
- Creates a pull request in the GitOps repository for review and approval.
- Exits without creating a PR when staging already matches development.

The GitOps repository remains the source of truth for deployed image versions.

## Alternatives Considered

### Automatic promotion to staging

Automatically update staging after development changes are merged.

**Rejected:** This would remove the explicit approval point between development and staging.

### Rebuild images for staging

Build new application and Flyway images during the staging deployment process.

**Rejected:** Separate builds could introduce differences between environments and weaken artifact traceability.

### Direct deployment from GitHub Actions

Use GitHub Actions to update Kubernetes workloads directly.

**Rejected:** This would bypass the GitOps review process and reduce the value of Git as the authoritative record of deployment configuration.

## Consequences

**Benefits:**

- Explicit approval before staging changes.
- Consistent image artifacts across environments.
- Traceability through Git SHAs and pull requests.
- No requirement for direct Kubernetes access from GitHub Actions.
- Repeatable, idempotent promotion.

**Trade-offs:**

- Promotion requires manual intervention and PR approval.
- Staging releases may be delayed while awaiting review.
- The workflow depends on access to GitOps, ECR and GitHub App authentication.

## Validation

The workflow successfully created a staging promotion PR containing the approved development image tags.

After merging the PR, a second workflow run completed successfully without creating another PR because development and staging already matched.