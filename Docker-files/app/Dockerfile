FROM tomcat:10-jdk21

RUN rm -rf /usr/local/tomcat/webapps/*

RUN groupadd --system tomcat && \
    useradd --system --gid tomcat --no-create-home tomcat && \
    mkdir -p /usr/local/tomcat/conf/Catalina/localhost && \
    chown tomcat:tomcat \
        /usr/local/tomcat/webapps \
        /usr/local/tomcat/conf/Catalina/localhost

USER tomcat

COPY target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

USER tomcat

EXPOSE 8080
CMD ["catalina.sh", "run"]
WORKDIR /usr/local/tomcat/
VOLUME /usr/local/tomcat/webapps
