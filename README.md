# SpringBoot GraalVM Native Image and JVM Performance Comparison

## 1 Overview

This project was used to perform a brief and basic perfomance and viablity study of a Spring Boot REST API using a standard JVM Docker image and Docker images implementing the AOT GraalVM native compiler.

### 1.1 What is GraalVM and why do I care?

A standard Java Virtual Machine (JVM) uses a Just In Time (JIT) compiler to generate a program that can be run on any computer that can run a Java program. It works by generating byte code that is non-machine dependent at build time, and at run time it creates machine dependent code only where needed. It generates a lot of extra information in the JVM so that when the program is running, it can profile the program, find the bottlenecks, and make it run faster. The JIT compiler can improve peak performance of an application, but at the cost of a much slower startup times, slower initial run times, lower sustained performance, and greater memory usage.

The GraalVM Ahead of Time (AOT) compiler, like a C/C++ compiler, compiles a Java application into native bye code for the machine it is built on. For this reason it does not need a JVM to store all the information for classes that might be used, extra information for profiling, and other information. A GraalVM native image can be a fraction of the size of the JIT version of the same application, use far less memory, load far faster, and have a higher sustained speed, but at the cost of slower peak throughput. In addition, because it uses native code for the machine it is built on, it is not a true “write once run anywhere” image, but Docker solves that problem. The final caveat is build times may be much longer that when using the standard JIT compiler.

### 1.2 Scope

This project is not a comprehensive evaluation of a complex application. It is intended to be a quick evaluation of the potential of using a native image over a standard Java byte-code image. To this end it implements a database comprise of a single table and a limited number of database queries.

### 1.3 Application

The application is a Spring Boot application using a REST JSON interface, an embeded Tomcat application server, and Spring JPA and Hibernate database interfaces. Junit is used for build verification and validation testing of the resulting executable JAR.

### 1.4 Images

The project build results in four (4) images. The first image is the comparison image consisting of a basic Linux Docker image at its base with the standard JAR and database JDBC driver copied to the image for execution. The remaining three (3) images are built by Spring Boot plugins.

### 1.5 Development, Build, and Test Environment

- Intel i4770K 4.2GHz with 16GB DDR3
- Onboard Intel graphics
- 3TB SSD SATA Express storage
- 9TB SATA 2 HDD storage
- 1GB Ethernet
- CentOS 7, kernel 3.10.0+, Gnome desktop
- Firefox
- Postman
- Eclipse
- Oracle Data Modeler
- Oracle SQL Developer

## 2 Requirements

- [Amazon Linux Docker image](https://hub.docker.com/_/amazoncorretto)
- [SdkMan](https://sdkman.io/)
- Maven 3+
- Spring Boot 2.7.0
- PostgreSQL 9.2.24
- PostgreSQL [JDBC Driver 42.4.0](https://jdbc.postgresql.org/download/postgresql-42.4.0.jar) (including in the project)
- Docker 20.10.17
- OpenJDK Java 11.0.12 or equivalent
- GraalVM AOT 21.1.0.r11

### 2.1 Database

Though the application was initially developed using the H2 database, it was decided that a better evaluation could be had using a more common database. PostgreSQL support on CentOS 7 is now lacking so the GUI tools for it are lacking, but the DBMS itself works fine.

### 2.2 Docker

The version available at the time of this writing was 20.10.17. This project compares Docker images and the focus is micro service development so Docker is a must.

#### 2.2.1 Base Image

The Linux base image (Full JVM) is used to build a somewhat standard Docker images used to run a Java web application using the Java HotSpot compiler. While Linux images vary, for this comparison it was decided to select a base image that may be somewhat popular and support a cloud based micro service. The Amazon Linux image has active support, supports various Linux distributions, multiple Java versions, supports AWS services, and is a reasonable size. This image is only used for the base Java 11 JAR which is used for the comparison of the other images.

#### 2.2.2 Other Images

The three images compared to the base Full JVM image are as follows:

- Tiny JVM: Built using the Spring Boot OCI image builder
- Full Native: Built using the Spring Boot Native OCI compiler with full Java support.
- Tiny Native: Built using the Spring Boot Native OCI compiler with minimum Java support.

These three images provide a rounded comparison of the largest and smallest functional images that can be built using the Java HotSpot JIT compiler and the GraalVM AOT compiler.

### 2.3 Java

The GraalVM AOT compiler and VM was first implemented in Java 11 so a Java 11 JVM and GraalVM are the required minimum versions. SdkMan is required for managing the java versions during the build process. A GraalVM AOT Java compiler must be used for native image compiling and a Java JIT compiler must be used for standard JIT byte code compiling.

This project has not been validated and verified with compiler versions higher that those listed in the document.

### 2.4 Spring Boot

Spring Boot native image support is still in development with a first complete stable release slated for later this year (2022) or next year. The plugins and debugging tools are only just now in a state that makes Spring Boot native images viable for new development. The minimum version of Spring Boot is 2.7.0 without requiring additional configuration and debugging in order to make a native image operational.

## 3 Building

As with any Docker build process, verify that Docker is running and that you are logged in.

Building is best done using the ```mvnw``` script. It is possible to manually use Maven to builds the different profiles, but it is not advised to use an IDE to build the images. As mentioned above, the GraalVM images require a different build process and to this engineer’s knowledge IDE’s do not yet support the GraalVM AOT compiler and execution environment.

Docker and SdkMan are required to be installed. If the buld process fails due to a missing Java complier, use sdkMan on the command line to install the correct compiler versions locally:

```
sdk install java 21.1.0.r11-grl
sdk install java 11.0.12-open
```

The build script should select the correct compiler automatically.

### 3.1 Build Script

```mvnw``` supports the following commands:

```
help        | List commands
------------------------------------------------------------
prune       | Stops all running Docker containers.
            | Removes all Docker containers.
            | Prunes all Docker images.
            | WARNING: ALL Docker images will be deleted!
------------------------------------------------------------
clean       | Cleans generated files from the build folder.
------------------------------------------------------------
buildall    | Builds all four (4) images.
------------------------------------------------------------
install     | Runs prune, clean, buildall
------------------------------------------------------------
fulljvm     | Builds a Docker image using an Amazon Linux
            | Java 11 Docker image.
------------------------------------------------------------
tinyjvm     | Builds a small Docker image using a Java 11
            | HotSpot compiler.
------------------------------------------------------------
fullgraal   | Builds a Docker image using the full GraalVM
            | native image AOT compiler.
------------------------------------------------------------
tinygraal   | Builds a Docker image using the tiny GraalVM
            | native image AOT compiler.
------------------------------------------------------------
```

**WARNING: The prune command may be dangerous.** This command will stop all Docker containers, remove them, and then delete all Docker images. It should ask if you wish to actually delete the images (it uses ```docker system prune -a``` which asks for verification). This command was added to make development and testing easier and to quickly clean up Docker containers and images.

The ```fulljvm``` command is a multi-step build process. This process uses a “manual docker image process by pulling the Linux image, using it as a base image and copying the application JAR and JDBC driver, and putting the resulting image into the local repository.

### 3.2 POM Profiles

There are five (5) Maven profiles in the pom:

- h2db-jvm-image: Used for initial development and testing. Not used for the comparison
- pg-jvm: The ```fulljvm``` Jar build. It does not build a docker image, but only an executable JAR file.
- pg-native-tiny: The ```tinygraal``` Docker image build. Uses the Spring AOT plugins.
- pg-native-large: The ```fullgraal``` Docker image build. Uses the Spring AOT plugins.
- pg-jvm-image: The ```tinyjvm``` Docker image build. Uses the Spring JIT tiny plugins.
