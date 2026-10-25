## Prerequisites
- JDK 21
- Maven 3 
- MySQL 8.4

## Technologies 
- Spring MVC
- Spring Security
- Spring Data JPA
- Maven
- JSP
- Tomcat
- MySQL
- Memcached
- Rabbitmq

## Database

The application uses MySQL 8.4, with database schema changes managed through Flyway migrations.

Migration scripts are maintained in `db/migrations/` and packaged into a dedicated Flyway Docker image.

In the Kubernetes deployment, database initialisation is automated:

1. A bootstrap Job creates the application and migration database users with separate permissions.
2. A Flyway Job applies any outstanding schema migrations.
3. Argo CD coordinates the deployment order before the application starts.

Database credentials are stored in AWS Secrets Manager rather than being included in the repository.

The legacy SQL dump files under `src/main/resources/` are retained for reference and are not used by the current deployment process.

## Deployment & CI/CD

The application is deployed to Amazon EKS using a GitOps workflow built around GitHub Actions, Amazon ECR, Kustomize and Argo CD.

Application source code, deployment configuration and infrastructure are maintained in separate repositories:

- **[vprofile-app](https://github.com/AmmanSajid1/vprofile-app)** — Application source, Dockerfiles, Flyway migrations and CI/CD workflows.
- **[vprofile-gitops](https://github.com/AmmanSajid1/vprofile-gitops)** — Kubernetes manifests, Kustomize overlays and Argo CD application definitions.
- **[vprofile-infra](https://github.com/AmmanSajid1/vprofile-infra)** — Terraform infrastructure and platform configuration.

The release process follows a **build-once, promote-the-same-artifact** approach:

1. A push to `main` triggers GitHub Actions to test and build the application and Flyway images.
2. Images are published to Amazon ECR using immutable Git commit SHA tags.
3. CI creates a pull request updating the development image versions in the GitOps repository.
4. Once reviewed and merged, Argo CD reconciles the development environment when the cluster is running.
5. Staging promotion is triggered manually through GitHub Actions. The workflow verifies the existing images in ECR and creates a separate GitOps pull request for approval.
6. Once merged, Argo CD reconciles staging without rebuilding the images.

AWS authentication uses GitHub Actions OIDC, while cross-repository GitOps changes are authenticated using a GitHub App.

For the full workflow, see [CI/CD and GitOps Release Pipeline](docs/release-pipeline.md).

## Documentation

### Architecture Decision Records

- [ADR 001 — Application Build Strategy](docs/adr/001-application-build-strategy.md)
- [ADR 002 — GitHub Actions AWS Authentication](docs/adr/002-github-actions-aws-authentication.md)
- [ADR 003 — Immutable Container Image Publishing](docs/adr/003-immutable-container-image-publishing.md)
- [ADR 004 — Manual Staging Promotion](docs/adr/004-manual-staging-promotion.md)

### Troubleshooting

- [ECR Image Publishing](docs/troubleshooting/ecr-image-publishing.md)
- [JUnit Test Discovery](docs/troubleshooting/junit-test-discovery.md)
- [Non-Root Tomcat Permissions](docs/troubleshooting/non-root-tomcat-permissions.md)
- [GitHub OIDC Authentication Failure](docs/troubleshooting/github-oidc-authentication-failure.md)
- [Staging Promotion Image Parsing](docs/troubleshooting/staging-promotion-image-parsing.md)
