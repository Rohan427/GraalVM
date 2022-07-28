#!/bin/bash







newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Full_JVM.postman_environment.json -n 20 -r cli,htmlextra --reporter-htmlextra-export newman/jvmfull.html
newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Tiny_JVM.postman_environment.json -n 20 -r cli,htmlextra --reporter-htmlextra-export newman/jvmtiny.html
newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Full_GraalVM.postman_environment.json -n 20 -r cli,htmlextra --reporter-htmlextra-export newman/graalfull.html
newman run postman/GraalVM_Test_API.postman_collection.json -e postman/Docker_Tiny_GraalVM.postman_environment.json -n 20 -r cli,htmlextra --reporter-htmlextra-export newman/graaltiny.html
