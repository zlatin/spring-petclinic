FROM maven:3-jdk-8-alpine
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar"]
CMD [ "--server.port=8080" ]