# ADR-001: Application Build Strategy

## Status
Accepted

## Context
The vProfile Java application must be tested, packaged as a WAR,
and built into a container image through GitHub Actions.

Two approaches were considered:
- Build the application inside a multi-stage Docker build.
- Build the WAR directly in CI and copy it into a Tomcat runtime image.

## Decision
Build and test the application directly in GitHub Actions using
Maven, then package the resulting WAR using a runtime-only
Tomcat Dockerfile.

## Reasons
- Clear visibility of test and quality-check stages in CI.
- Straightforward Maven dependency caching in GitHub Actions.
- Easier integration of test and code quality reporting.
- Final container still contains only the Tomcat runtime and WAR.

## Trade-offs
- CI runner requires the Java/Maven toolchain.
- The Java/Maven build environment is configured by the CI workflow rather than encapsulated within the Docker build, making the build somewhat more dependent on CI runner configuration.