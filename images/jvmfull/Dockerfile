FROM corretto/java-11:1.2

LABEL "com.randomlogic.perftest.author"="Paul Allen <pgallen@randomlogic.net>"

WORKDIR /

RUN yum -y update;yum clean all;rm -rf /var/cache/yum

ADD perftest-jvm-full-1.2.jar perftest-jvm-full-1.2.jar
ADD postgresql-42.4.0.jar /usr/java/lib/

ENV CLASSPATH /usr/java/lib

CMD ["usr/lib/jvm/java-11-amazon-corretto/bin/java", "-jar", "perftest-jvm-full-1.2.jar"]

EXPOSE 8000
