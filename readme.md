# Damian O'Donnell - Jfrog Spring PetClinic Sample Application with Jenkins and Docker

This project is a demonstration of using Jenkins to build a Spring Boot application and build a docker image.

# Setup Jenkins Environment 

## Docker and Jenkins Container setup

This demo depends on a functional Docker environment. [Docker install](https://docs.docker.com/get-docker/).

Start a jenkins container with access to the docker socket to allow jenkins to build images.

`docker run -p 8080:8080 -p 50000:50000 -d -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts`

Login to the container and install docker.

`docker exec -it --user root <container id> bash`

`curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall`

Permission on the host `/var/run/docker.sock` may need to be updated to allow the child container to connect.

## Jenkins Setup and Configuration

Connect to Jenkins using the admin password which can be found in `/var/jenkins_home/secrets/initialAdminPassword` in the running container. Install all the default plugins.

Create a new admin user after the plugins have been installed and login with the new user.

Install the following plugins from _Manage Jenkins > Manage Plugins_:
* Artifactory
* Docker
* Docker Pipeline

After plugins have been installed restart Jenkins.

After the restart, login with the admin user and navigate to Jenkins System Configuration _Manage Jenkins > Configure System_.

In the JFrog section add a JFrog Platform Instance with the Instance Id of **Artifactory-test**, enable the use credentials plugin, set the JFrog Platform URL for the JFrog instance and in the credentials sub-section click the add button to add username and password.

Save the configuration.

Configure local docker as cloud, return to _Manage Jenkins > Configure System_ page and scroll to the end of the page and click Configure Clouds.

On the Configure Clouds page click _Add a new cloud_ and select `Docker`. Set the name of the cloud to be `docker` and Docker Host URI to `unix:///var/run/docker.sock`.

Save the configuration.

Configure the build tools via the Global Tool Configuration page,  _Manage Jenkins > Global Tool Configuration_.

#### JDK

Add JDK and set the Name to **JDK11** and the path to `/opt/java/openjdk` - this will use the JDK provided for Jenkins (this is not recommend for production).

#### Maven

Add Maven and set the Name to **3.8.5**, click install automatically and select version `3.8.5`.

Save the configuration

## Add the project to the Jenkins

On the home page click _New Item_ from the left menu, name your project (free text to identify the project). On the project configuration page add a Display Name and Description if required, with in the _Branch Sources_ section add and select GitHub and set the Repository HTTPS URL to be the https url of this project. (No credentials are required as it is a public project.)

Save the project configuration. Jenkins will scan the repository for Jenkinsfile in any branch and build as required. Once the build is successful the artifact will be available on the configured JFrog artifactory and the final docker image within the local docker repository of the host system.

# Work carried out

## Jenkinsfile

Creation of a simple Jenkinsfile to build and test the sample spring project. The first Jenkinsfile was created as single pipeline project, this caused checkout issues in Jenkins because it scanned the set branch but checked out the main branch for building, when the project was recreated as multi-branch project `env.BRANCH_NAME` variable was available correcting the problem.

After successful build the Jenkinsfile was updated to have multiple stages: **build**, **test** and **package**. The build stage creates the jar file for the project and stores it as an artifact (and later to JFrog artifactory). The second stage runs the test and stores the results in Jenkins, if the test fails the build continues. The final stage builds the Docker image.

## Dockerfile

The Dockerfile is a very simple example that uses a base OpenJDK 11 image, copies in the JAR_FILE that is passed as build argument and executes java with the installed jar as the Entry point.

The Dockerfile uses Debian Buster image as Alpine images are not available currently from the official OpenJDK source.

## Starting the image

To use the image once available on the host machine (the image is not published to hub.docker.io):

`# docker run -p 8080:8080 vcem.jfrog.io/default-docker-virtual/spring-petclinic-jfrog:<version>`

# Original Sample Project Reference

The original sample project Spring [petclinic](https://github.com/spring-projects/spring-petclinic).

# License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).

[spring-petclinic]: https://github.com/spring-projects/spring-petclinic
[spring-framework-petclinic]: https://github.com/spring-petclinic/spring-framework-petclinic
[spring-petclinic-angularjs]: https://github.com/spring-petclinic/spring-petclinic-angularjs 
[javaconfig branch]: https://github.com/spring-petclinic/spring-framework-petclinic/tree/javaconfig
[spring-petclinic-angular]: https://github.com/spring-petclinic/spring-petclinic-angular
[spring-petclinic-microservices]: https://github.com/spring-petclinic/spring-petclinic-microservices
[spring-petclinic-reactjs]: https://github.com/spring-petclinic/spring-petclinic-reactjs
[spring-petclinic-graphql]: https://github.com/spring-petclinic/spring-petclinic-graphql
[spring-petclinic-kotlin]: https://github.com/spring-petclinic/spring-petclinic-kotlin
[spring-petclinic-rest]: https://github.com/spring-petclinic/spring-petclinic-rest
