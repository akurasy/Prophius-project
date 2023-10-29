FROM openjdk:8
EXPOSE 8080

WORKDIR /app
COPY /src .

COPY pom.xml .

RUN mvn install

ENTRYPOINT ["java","-jar","/app/springboot-crud-k8s.jar"]