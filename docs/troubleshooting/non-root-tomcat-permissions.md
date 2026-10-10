# Non-Root Tomcat Container Permission Issues

## Problem

While configuring the vProfile application container to run as a non-root user, Tomcat encountered filesystem permission errors during startup.

The Dockerfile created a dedicated `tomcat` user and switched the container to that user instead of running as root.

However, the initial configuration did not grant the user sufficient permissions to write to directories required by Tomcat.

Startup logs showed `SEVERE` errors relating to the creation of `conf/Catalina/localhost` and the expansion of the application WAR into `webapps/ROOT`.

## Investigation

The container logs were inspected to identify which operations were failing during startup.

The errors indicated that Tomcat was attempting to write to directories that the non-root user did not have permission to modify.

The Dockerfile and directory permissions were reviewed to identify the required writable locations.

Tomcat needed to:

- Create configuration directories under `/usr/local/tomcat/conf/Catalina/localhost`.
- Extract the application's `ROOT.war` into `/usr/local/tomcat/webapps/ROOT`.

Rather than granting write access to the entire Tomcat installation, the required directories were identified individually.

## Fix

The Dockerfile was updated to grant the `tomcat` user ownership of the necessary directories:

- `/usr/local/tomcat/webapps`
- `/usr/local/tomcat/conf/Catalina/localhost`

The container continued running as the dedicated non-root user.

After rebuilding the image, the application started successfully and the login page was accessible at `http://localhost:8080`.

The runtime user was verified using:

`docker exec <container-name> id`

This confirmed that the application was running as the `tomcat` user rather than root.

## Lesson

Running a container as a non-root user requires more than adding a `USER` instruction to the Dockerfile.

Applications may need write access to specific filesystem locations during startup or runtime.

These requirements should be identified through application logs and behaviour rather than granting broad filesystem permissions.

Giving ownership only to the required directories allows the application to function while maintaining a more restrictive security configuration.