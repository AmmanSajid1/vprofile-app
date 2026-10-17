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
