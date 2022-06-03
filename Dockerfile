FROM openjdk:11-jdk-alpine

ARG JAR_FILE
ADD $JAR_FILE target/app.jar
ENV JAVA_OPTS=""

EXPOSE 8080

ENTRYPOINT ["java", "-jar","target/app.jar"]
