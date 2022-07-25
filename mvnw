#!/bin/bash

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Build author
AUTHOR="\"com.randomlogic.graaltest.author\"=\"Paul Allen <pgallen@randomlogic.net>\""

# Java versions to use
JVMJAVA="11.0.12-open"
GRAALJAVA="22.1.0.r11-grl"

# Base paths and references
BASEPATH="/usr/local/src/GraalVM/"
IMAGEPATH="images/"
LINUXIMAGE="corretto/java-11"
IMAGEBASE="perftest"
VERSION="1.2"

# Build JAR names
GRAALTINY="graal-tiny"
GRAALFULL="graal-full"
JVMTINY="jvm-tiny"
JVMFULL="jvm-full"

# Builr time report file name
BUILDTIME="buildtime.txt"

# Image paths
LINUXPATH="${BASEPATH}${IMAGEPATH}amzlinux/"
GRAALTINYPATH="${BASEPATH}${IMAGEPATH}graaltiny/"
GRAALFULLPATH="${BASEPATH}${IMAGEPATH}graalfull/"
JVMTINYPATH="${BASEPATH}${IMAGEPATH}jvmtiny/"
JVMFULLPATH="${BASEPATH}${IMAGEPATH}jvmfull/"

#Path to extra JAR files used in images
EXTRAS="${BASEPATH}${IMAGEPATH}external/"

# Used for calculating build times
BEGINTIME=0
ENDTIME=0
DIFFERENCE=0

# Exit status code
EXITNUM=0

# Docker image names (JVM Full image)
LINUXNAME="corretto/java-11:${VERSION}"
JVMFULLNAME="jvmfull"

# For future manual Docker build process
JVMTINYNAME="jvmtiny"
GRAALFULLNAME="graalfull"
GRAALTINYNAME="graaltiny"

# Docker port to expose (should be the same as in the Spring application. properties file)
DOCKERPORT="8000"


function timeDiff()
{
    echo >> $2
    echo "$1 buld time:" >> $2 echo "$(($ENDTIME-$BEGINTIME))ns" >> $2
    echo "$(($(($ENDTIME-$BEGINTIME))/1000))us" >> $2
    echo "$(($(($ENDTIME-$BEGINTIME))/1000000))ms" >> $2
    echo "$(($(($ENDTIME-$BEGINTIME))/1000000000))s" >> $2
    echo >> $2
}


function processHeader()
{
    echo
    echo "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
    echo "P          $1"
    echo "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
    echo
}


function createJvmTestDockerfile()
{
    echo "Creating Dockerfile in ${JVMFULLPATH}"
 
    echo "FROM ${LINUXNAME}" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "LABEL ${AUTHOR}" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "WORKDIR /" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "RUN yum -y update;yum clean all;rm -rf /var/cache/yum" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "ADD ${IMAGEBASE}-${JVMFULL}-${VERSION}.jar ${IMAGEBASE}-${JVMFULL}-${VERSION}.jar" >> ${JVMFULLPATH}Dockerfile
    echo "ADD postgresql-42.4.0.jar /usr/java/lib/" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "ENV CLASSPATH /usr/java/lib" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "CMD [\"usr/lib/jvm/java-11-amazon-corretto/bin/java\", \"-jar\", \"${IMAGEBASE}-${JVMFULL}-${VERSION}.jar\"]" >> ${JVMFULLPATH}Dockerfile
    echo  >> ${JVMFULLPATH}Dockerfile
    echo "EXPOSE ${DOCKERPORT}" >> ${JVMFULLPATH}Dockerfile
}


function buildFullJVM()
{
    processHeader "Build full JVM JAR file..."
    sdk use java $JVMJAVA
    BEGINTIME=$(date +%s%N)
    mvn package -Ppg-jvm
    ENDTIME=$(date +%s%N)
    EXITNUM=$?

    if [[ $EXITNUM -eq 0 ]];
    then
        rm -f ${JVMFULLPATH}${BUILDTIME}
        timeDiff "Full JAR" ${JVMFULLPATH}${BUILDTIME}
        mv -f "${BASEPATH}target/hackerrank-app-1.2-SNAPSHOT.jar" "${JVMFULLPATH}${IMAGEBASE}-${JVMFULL}-${VERSION}.jar"
        cp "${EXTRAS}postgresql-42.4.0.jar" "${JVMFULLPATH}"

# Build full Docker image
        processHeader "Build Linux Docker image..."
        cd "${LINUXPATH}"
        BEGINTIME=$(date +%s%N)
        docker build -f Dockerfile -t ${LINUXNAME} .
        ENDTIME=$(date +%s%N)
        EXITNUM=$?

        if [[ $EXITNUM -eq 0 ]];
        then
            timeDiff "Docker Linux image" ${JVMFULLPATH}${BUILDTIME}
# Build Full JVM Docker image
            processHeader "Build full JVM Docker image..."
            cd ${JVMFULLPATH}
            createJvmTestDockerfile

            BEGINTIME=$(date +%s%N)
            docker build -f Dockerfile -t ${IMAGEBASE}-${JVMFULLNAME}:${VERSION} .
            ENDTIME=$(date +%s%N)
            EXITNUM=$?

            if [[ $EXITNUM -eq 0 ]];
            then
                timeDiff "Docker ${IMAGEBASE}-${JVMFULLNAME} image" ${JVMFULLPATH}${BUILDTIME}
            else
                echo "Build of JVM full Docker image failed with $EXITNUM"
                EXITNUM=3
            fi
        else
            echo "Build Docker Linux image failed with $EXITNUM"
            EXITNUM=2
        fi
    else
        echo "Build of JVM full JAR failed with $EXITNUM"
        EXITNUM=1
    fi
}


function buildTinyJVM()
{
    processHeader "Build tiny JVM image..."
    sdk use java $JVMJAVA
    BEGINTIME=$(date +%s%N)
    mvn spring-boot:build-image -Ppg-jvm-image -DskipTests
    ENDTIME=$(date +%s%N)
    EXITNUM=$?

    if [[ $EXITNUM -eq 0 ]];
    then
        rm -f ${JVMTINYPATH}${BUILDTIME}
        timeDiff "Full JAR" ${JVMTINYPATH}${BUILDTIME}
        mv -f "${BASEPATH}target/hackerrank-app-1.2-SNAPSHOT.jar" "${JVMTINYPATH}${IMAGEBASE}-${JVMTINY}-${VERSION}.jar"
    else
        echo "Build of JVM full JAR failed with $EXITNUM"
        EXITNUM=4
    fi
}


function buildfFullGraal()
{
    processHeader "Build Full GraalVM native image..."
    sdk use java $GRAALJAVA
    BEGINTIME=$(date +%s%N)
    mvn spring-boot:build-image -Ppg-native-large -DskipTests
    ENDTIME=$(date +%s%N)
    EXITNUM=$?

    if [[ $EXITNUM -eq 0 ]];
    then
        rm -f ${GRAALFULLPATH}${BUILDTIME}
        timeDiff "Full JAR" ${GRAALFULLPATH}${BUILDTIME}
        mv -f "${BASEPATH}target/hackerrank-app-1.2-SNAPSHOT.jar" "${GRAALFULLPATH}${IMAGEBASE}-${GRAALFULL}-${VERSION}.jar"
    else
        echo "Build of Full GraalVM native failed with $EXITNUM"
        EXITNUM=5
    fi
}


function buildTinyGraal()
{
    processHeader "Build Tiny GraalVM native image..."
    sdk use $GRAALJAVA
    BEGINTIME=$(date +%s%N)
    mvn spring-boot:build-image -Ppg-native-tiny -DskipTests
    ENDTIME=$(date +%s%N)
    EXITNUM=$?

    if [[ $EXITNUM -eq 0 ]];
    then
        rm -f ${GRAALTINYPATH}${BUILDTIME}
        timeDiff "Full JAR" ${GRAALTINYPATH}${BUILDTIME}
        mv -f "${BASEPATH}target/hackerrank-app-1.2-SNAPSHOT.jar" "${GRAALTINYPATH}${IMAGEBASE}-${GRAALTINY}-${VERSION}.jar"
    else
        echo "Build of Tiny GraalVM native failed with $EXITNUM"
        EXITNUM=5
    fi
}


function prune()
{
    processHeader "Prune Docker images..."
    docker container stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker system prune -a
}

function clean()
{
    processHeader "Clean build folder..."
    mvn clean
    rm -f ${GRAALTINYPATH}*
    rm -f ${GRAALTINYPATH}${BUILDTIME}

    rm -f ${GRAALFULLPATH}*
    rm -f ${GRAALFULLPATH}${BUILDTIME}

    rm -f ${JVMTINYPATH}*
    rm -f ${JVMTINYPATH}${BUILDTIME}

    rm -f ${JVMFULLPATH}*
    rm -f ${JVMFULLPATH}${BUILDTIME}
}


function buildAll()
{
    processHeader "Build all images..."
    if [[ $EXITNUM -eq 0 ]];
    then
# Build Full JVM JAR
        cd $BASEPATH
        buildFullJVM
    fi

# Build Tiny JVM Image
    if [[ $EXITNUM -eq 0 ]];
    then
        cd $BASEPATH
        buildTinyJVM
    fi

# Build Full Native Image
    if [[ $EXITNUM -eq 0 ]];
    then
        cd $BASEPATH
        buildfFullGraal
    fi

# Build Tiny Native Image
    if [[ $EXITNUM -eq 0 ]];
    then
        cd $BASEPATH
        buildTinyGraal
    fi
}

function _help()
{
    processheader "mvnw commands"
    echo "help        | List commands"
    echo "------------------------------------------------------------"
    echo "prune       | Stops all running Docker containers."
    echo "            | Removes all Docker containers."
    echo "            | Prunes all Docker images."
    echo "            | WARNING: ALL Docker images will be deleted!"
    echo "------------------------------------------------------------"
    echo "clean       | Cleans generated files from the build folder."
    echo "------------------------------------------------------------"
    echo "buildall    | Builds all four (4) images."
    echo "------------------------------------------------------------"
    echo "install     | Runs prune, clean, buildall"
    echo "------------------------------------------------------------"
    echo "fulljvm     | Builds a Docker image using an Amazon Linux"
    echo "            | Java 11 Docker image."
    echo "------------------------------------------------------------"
    echo "tinyjvm     | Builds a small Docker image using a Java 11"
    echo "            | HotSpot compiler."
    echo "------------------------------------------------------------"
    echo "fullgraal   | Builds a Docker image using a the full GraalVM"
    echo "            | native image AOT compiler."
    echo "------------------------------------------------------------"
    echo ""
}

if [[ $# -eq 0 ]];
then
    _help
fi

if [[ $1 == "prune" ]];
then
    prune
elif [[ $1 == "buildall" ]];
then
    buildAll
elif [[ $1 == "fulljvm" ]];
then
    cd $BASEPATH
    buildFullJVM
elif [[ $1 == "tinyjvm" ]];
then
    cd $BASEPATH
    buildTinyJVM
elif [[ $1 == "fullgraal" ]];
then
    cd $BASEPATH
    buildfFullGraal
elif [[ $1 == "tinygraal" ]];
then
    cd $BASEPATH
    buildTinyGraal
elif [[ $1 == "clean" ]];
then
    clean
elif [[ $1 == "install" ]];
then
    processHeader "Installing a fesh build. This may take several munites."
    prune
    clean
    buildAll
elif [[ $1 == "help" ]];
then
    _help
else
    _help
fi

if [[ $EXITNUM -eq 0 ]];
then
    processHeader "Process complete"
else
    processHeader "Process FAILED with exit status ${EXITNUM}"
fi
exit $EXITNUM
