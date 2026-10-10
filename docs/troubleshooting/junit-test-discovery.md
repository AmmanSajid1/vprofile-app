# Maven and JUnit Test Discovery Issues

## Problem

While configuring the GitHub Actions CI pipeline, the local Maven build appeared to complete successfully, but the test results were inconsistent with those produced by GitHub Actions.

Running `mvn clean verify` locally initially reported zero tests executed.

However, the GitHub Actions workflow discovered and executed nine tests, two of which failed.

This meant that a successful local build did not necessarily indicate that the application's tests had passed.

## Investigation

The Maven test output was compared between the local environment and GitHub Actions.

The project contained tests written using JUnit 4, while the Maven test environment was using the JUnit Platform with JUnit 5 support.

The local configuration was not correctly discovering the existing JUnit 4 tests.

The project's `pom.xml` was inspected to review its testing dependencies.

After identifying the test discovery issue, the JUnit Vintage engine was considered to provide compatibility with the existing JUnit 4 tests.

The failing controller tests were also reviewed against the actual Spring MVC controller mappings.

Two outdated expectations were identified:

- A test expected `GET /login` to return HTTP 200, although the controller served the login view through `GET /`.
- Another test expected `GET /` to return the `welcome` view, although the controller returned the `login` view.

The application already had a separate test covering the `/welcome` endpoint.

## Fix

The JUnit Vintage engine dependency was added to `pom.xml`, allowing the existing JUnit 4 tests to be discovered through the JUnit Platform.

The outdated controller tests were then corrected:

- The login-view test was updated to use `GET /` with the appropriate error query parameter.
- The redundant test expecting the welcome view at `/` was removed.

The Maven build was rerun locally:

`mvn clean verify`

All eight remaining tests were discovered and passed.

The GitHub Actions workflow was also rerun successfully.

## Lesson

A successful Maven build does not necessarily mean that application tests have executed.

CI pipelines should be checked for both test results and the number of tests discovered.

Mixing JUnit 4 tests with JUnit 5 tooling requires appropriate compatibility support, such as the JUnit Vintage engine.

Existing tests should also be checked against actual application behaviour, particularly when working with an inherited codebase where controller mappings or functionality may have changed over time.