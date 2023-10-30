FROM maven:alpine as builder

WORKDIR /java-app

COPY  /src /java-app/
COPY pom.xml /java-app

RUN mvn install

FROM openjdk:8

WORKDIR /app

COPY --from=builder /java-app .

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/springboot-crud-k8s.jar"]
