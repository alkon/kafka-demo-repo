# Dockerfile
# Use the official OpenJDK 21 image as a base
FROM openjdk:24-jdk-slim as build

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven wrapper files to enable building inside the container
COPY mvnw .
COPY .mvn .mvn

# Copy the pom.xml file to download dependencies first
COPY pom.xml .

# Download project dependencies. This step is cached if pom.xml doesn't change.
RUN ./mvnw dependency:go-offline

# Copy the rest of the application source code
COPY src src

# Build the Spring Boot application into a JAR file
RUN ./mvnw package -DskipTests

# --- Second stage: Create a smaller runtime image ---
FROM openjdk:24-jdk-slim

# Set the working directory
WORKDIR /app

# Copy the built JAR file from the build stage
# The JAR file will be named 'kafka-demo-0.0.1-SNAPSHOT.jar' based on pom.xml
COPY --from=build /app/target/kafka-demo-0.0.1-SNAPSHOT.jar app.jar

# Expose the port on which the Spring Boot application runs (default is 8080)
EXPOSE 8081

# Define the command to run the application
# Use 'java -jar' to execute the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]