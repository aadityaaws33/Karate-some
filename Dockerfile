FROM maven:alpine

COPY ./ ./cucumber-jvm-template-master

WORKDIR ./cucumber-jvm-template-master


CMD [ "/bin/sh", "-c", "while sleep 3600; do :; done"]