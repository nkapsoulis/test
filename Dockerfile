FROM openjdk:jdk-alpine

COPY target/microservice-1.0-SNAPSHOT.jar /deployments/

WORKDIR /deployments/

EXPOSE 8080

CMD java -jar /deployments/microservice-1.0-SNAPSHOT.jar
