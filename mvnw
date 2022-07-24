#!/bin/bash


AUTHOR="\"com.randomlogic.graaltest.author\"=\"Paul Allen <pgallen@randomlogic.net>\""
BASEPATH="/usr/local/src/GraalVM/"
IMAGEPATH="images/"
LINUXIMAGE="corretto/java-11"
IMAGEBASE="perftest"
VERSION="1.2"
GRAALTINY="graal-tiny"
GRAALFULL="graal-full"
JVMTINY="jvm-tiny"
JVMFULL="jvm-full"
BUILDTIME="buildtime.txt"
LINUXPATH="${BASEPATH}${IMAGEPATH}amzlinux/"
GRAALTINYPATH="${BASEPATH}${IMAGEPATH}graaltiny/"
GRAALFULLPATH="${BASEPATH}${IMAGEPATH}graalfull/"
JVMTINYPATH="${BASEPATH}${IMAGEPATH}jvmtiny/"
JVMFULLPATH="${BASEPATH}${IMAGEPATH}jvmfull/"
EXTRAS="${BASEPATH}${IMAGEPATH}external/"
BEGINTIME=0
ENDTIME=0
DIFFERENCE=0
EXITNUM=0
LINUXNAME="corretto/java-11:${VERSION}"
JVMFULLNAME=""
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
    echo "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
    echo "P  $1"
    echo "PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP"
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


if [[ $1 == "prune" ]];
    then
        docker container stop $(docker ps -a -q)
        docker rm $(docker ps -a -q)
        docker system prune -a
elif [[ $1 == "build" ]];
    then
# Build Full JVM JAR
        
        processHeader "Build full JVM JAR file..."
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
                        docker build -f Dockerfile -t ${IMAGEBASE}:${VERSION} .
                        ENDTIME=$(date +%s%N)
                        EXITNUM=$?

                        if [[ $EXITNUM -eq 0 ]];
                            then
                                timeDiff "Docker ${IMAGEBASE} image" ${JVMFULLPATH}${BUILDTIME}
                            else
                                echo "Build of JVM full Docker image failed with $EXITNUM"
                        fi
                    else
                        echo "Build Docker Linux image failed with $EXITNUM"
                fi

#                mvn spring-boot:build-image -Ppg-native-large -DskipTests
        else
            echo "Build of JVM full JAR failed with $EXITNUM"
        fi
elif [[ $1 == "clean" ]];
    then
        mvn clean
#        rm -f ${GRAALTINYPATH}*
#        rm -f ${GRAALTINYPATH}${BUILDTIME}

#        rm -f ${GRAALFULLPATH}*
#        rm -f ${GRAALFULLPATH}${BUILDTIME}

#        rm -f ${JVMTINYPATH}*
#        rm -f ${JVMTINYPATH}${BUILDTIME}

        rm -f ${JVMFULLPATH}*
        rm -f ${JVMFULLPATH}${BUILDTIME}
fi

processHeader "Build Complete"
exit $EXITNUM
